from typing import Optional, List
from datetime import datetime, timezone
import asyncio
from app.core.firebase import firebase
from app.core.async_utils import run_sync
import logging
import asyncio

logger = logging.getLogger(__name__)


class RouteRepository:
    """Firebase repository for routes"""

    COLLECTION = "routes"

    def __init__(self):
        self._collection = None

    @property
    def collection(self):
        """Lazy initialization - access Firebase only when first needed"""
        if self._collection is None:
            self._collection = firebase.routes
        return self._collection

    async def create(self, route_data: dict) -> dict:
        """
        Create new route in Firestore

        Args:
            route_data: Route data dict

        Returns:
            Created route with route_id
        """
        now = datetime.now(timezone.utc)

        route_data.update({
            "created_at": now,
            "updated_at": now
        })

        # Auto-generate document ID (run in thread pool)
        result = await run_sync(self.collection.add, route_data)
        doc_ref = result[1]
        route_id = doc_ref.id

        logger.info(f"Created new route: {route_id}")

        return {"route_id": route_id, **route_data}

    async def get_by_id(self, route_id: str) -> Optional[dict]:
        """Get route by ID"""
        doc = await run_sync(self.collection.document(route_id).get)
        if doc.exists:
            return {"route_id": doc.id, **doc.to_dict()}
        return None

    async def update(self, route_id: str, update_data: dict) -> Optional[dict]:
        """
        Update route by ID

        Args:
            route_id: Route ID
            update_data: Fields to update

        Returns:
            Updated route or None if not found
        """
        doc_ref = self.collection.document(route_id)
        doc = await run_sync(doc_ref.get)

        if not doc.exists:
            return None

        update_data["updated_at"] = datetime.now(timezone.utc)
        await run_sync(doc_ref.update, update_data)

        logger.info(f"Updated route: {route_id}")

        # Return updated document
        updated_doc = await run_sync(doc_ref.get)
        return {"route_id": route_id, **updated_doc.to_dict()}

    async def delete(self, route_id: str) -> bool:
        """
        Delete route by ID

        Args:
            route_id: Route ID

        Returns:
            True if deleted, False if not found
        """
        doc_ref = self.collection.document(route_id)
        doc = await run_sync(doc_ref.get)

        if not doc.exists:
            return False

        await run_sync(doc_ref.delete)
        logger.info(f"Deleted route: {route_id}")
        return True

    async def get_summary_multiple(self, route_ids: List[str]) -> dict[str, dict]:
        """
        Get summary info for multiple routes in parallel
        Light version for list endpoint
        """
        if not route_ids:
            return {}

        async def fetch_single(route_id: str) -> tuple[str, Optional[dict]]:
            """Fetch a single route summary"""
            doc = await run_sync(self.collection.document(route_id).get)
            if doc.exists:
                data = doc.to_dict()
                thumbnail = await self._get_thumbnail(data)
                return (route_id, {
                    "route_id": route_id,
                    "title": data.get("title", ""),
                    "duration_hours": data.get("duration_hours"),
                    "transport_type": data.get("transport_type"),
                    "region": data.get("region", []),
                    "places_count": len(data.get("places", [])),
                    "thumbnail_url": thumbnail,
                    "categories": data.get("categories", []),
                    "mood_tags": data.get("mood_tags", [])
                })
            return (route_id, None)

        # Fetch all routes in parallel
        results = await asyncio.gather(*[fetch_single(rid) for rid in route_ids])

        # Build result dict, excluding None values
        return {rid: data for rid, data in results if data is not None}

    async def _get_thumbnail(self, route_data: dict) -> Optional[str]:
        """Get first place's photo"""
        places = route_data.get("places", [])

        if not places:
            return None

        first_place = sorted(places, key=lambda x: x.get("order", 0))[0]
        # If places contains full data with photos
        photos = first_place.get("photos", [])
        if photos:
            return photos[0].get("url")

        # If places only contains place_id, fetch from places collection
        place_id = first_place.get("place_id")
        if place_id:
            place_doc = await run_sync(firebase.places.document(place_id).get)
            if place_doc.exists:
                place_data = place_doc.to_dict()
                photos = place_data.get("photos", [])
                if photos:
                    return photos[0].get("url")

        return None


route_repository = RouteRepository()
