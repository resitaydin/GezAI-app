from typing import List, Optional
from datetime import datetime, timedelta, timezone
import asyncio
from app.core.firebase import firebase
from app.core.async_utils import run_sync
from google.cloud.firestore_v1 import FieldFilter
from app.core.config import settings
from app.schemas.place import PlaceResponse, SyncStatus
import logging
import asyncio

logger = logging.getLogger(__name__)

class PlaceRepository:
    """Firebase Firestore repository for places"""

    def __init__(self):
        self._collection = None

    @property
    def collection(self):
        """Lazy initialization - access Firebase only when first needed"""
        if self._collection is None:
            self._collection = firebase.places
        return self._collection

    async def find_by_name_and_region(
            self,
            name: str,
            region: str
    ) -> Optional[dict]:
        """
        Find place by name and region
        Args:
            name: Place name
            region: Region name
        Returns:
            Place dict or None
        """
        query = (
            self.collection
            .where(filter = FieldFilter('name', '==', name))
            .where(filter = FieldFilter('region', '==', region.lower()))
            .limit(1)
        )

        # Run blocking stream() in thread pool
        docs = await run_sync(lambda: list(query.stream()))
        for doc in docs:
            return {"place_id": doc.id, **doc.to_dict()}

        return None

    async def find_by_google_place_id(
            self,
            google_place_id: str
    ) -> Optional[dict]:
        """
        Find place by Google Place ID
        Args:
            google_place_id: Google Place ID
        Returns:
            Place dict or None
        """
        query = (
            self.collection
            .where(filter = FieldFilter('google_place_id', '==', google_place_id))
            .limit(1)
        )

        # Run blocking stream() in thread pool
        docs = await run_sync(lambda: list(query.stream()))
        for doc in docs:
            return {"place_id": doc.id, **doc.to_dict()}

        return None

    async def get_by_id(
            self,
            place_id: str
    ) -> Optional[dict]:
        """
        Get place by ID
        Args:
            place_id: Place ID
        Returns:
            Place dict or None
        """
        # Run blocking get() in thread pool
        doc = await run_sync(self.collection.document(place_id).get)

        if doc.exists:
            return {"place_id": doc.id, **doc.to_dict()}

        return None

    async def create(
            self,
            place_data: dict
    ) -> dict:
        """
        Create new place
        Args:
            place_data: Place data dict
        Returns:
            Created place with ID
        """
        now = datetime.now(timezone.utc)

        place_data.update({
            "created_at": now,
            "updated_at": now,
            "google_last_synced_at": now,
            "google_sync_status": SyncStatus.FRESH.value
        })

        # Use Google Place ID as document ID if available
        doc_id = place_data.get("google_place_id")

        if doc_id:
            # Use Google Place ID as document ID
            doc_ref = self.collection.document(doc_id)
            await run_sync(doc_ref.set, place_data)
        else:
            # Auto-generate ID
            result = await run_sync(self.collection.add, place_data)
            doc_ref = result[1]
            doc_id = doc_ref.id

        logger.info(f"Created new place: {doc_id}")

        return {"place_id": doc_id, **place_data}

    async def get_photos(self, place_id: str) -> Optional[List[dict]]:
        """Get photos for a place"""
        place = await self.get_by_id(place_id)
        if place:
            return place.get("photos", [])
        return None

    async def update_about(self, place_id: str, about: str) -> bool:
        """
        Update the about field for a place
        Args:
            place_id: Place ID
            about: About text to set
        Returns:
            True if updated successfully
        """
        now = datetime.now(timezone.utc)
        doc_ref = self.collection.document(place_id)

        # Run blocking get() in thread pool
        doc = await run_sync(doc_ref.get)
        if not doc.exists:
            logger.warning(f"Place not found for update_about: {place_id}")
            return False

        # Run blocking update() in thread pool
        await run_sync(doc_ref.update, {
            "about": about,
            "updated_at": now
        })

        logger.info(f"Updated about for place: {place_id}")
        return True

    async def get_multiple(self, place_ids: List[str]) -> dict[str, dict]:
        """
        Get multiple places by IDs in parallel
        Args:
            place_ids: List of place IDs
        Returns:
            Dict mapping place_id to place data
        """
        if not place_ids:
            return {}

        async def fetch_single(place_id: str) -> tuple[str, Optional[dict]]:
            """Fetch a single place and return (place_id, data) tuple"""
            doc = await run_sync(self.collection.document(place_id).get)
            if doc.exists:
                data = doc.to_dict()
                return (place_id, {
                    "place_id": place_id,
                    "name": data.get("name", ""),
                    "name_en": data.get("name_en"),
                    "location": data.get("location"),
                    "formatted_address": data.get("formatted_address"),
                    "category": data.get("category"),
                    "photo_url": self._get_first_photo_url(data),
                })
            return (place_id, None)

        # Fetch all places in parallel
        results = await asyncio.gather(*[fetch_single(pid) for pid in place_ids])

        # Build result dict, excluding None values
        return {pid: data for pid, data in results if data is not None}

    async def get_multiple_full(self, place_ids: List[str]) -> dict[str, dict]:
        """
        Get multiple places by IDs in parallel with full data
        Args:
            place_ids: List of place IDs
        Returns:
            Dict mapping place_id to full place data
        """
        if not place_ids:
            return {}

        async def fetch_single(place_id: str) -> tuple[str, Optional[dict]]:
            """Fetch a single place and return (place_id, data) tuple"""
            doc = await run_sync(self.collection.document(place_id).get)
            if doc.exists:
                return (place_id, {"place_id": doc.id, **doc.to_dict()})
            return (place_id, None)

        # Fetch all places in parallel
        results = await asyncio.gather(*[fetch_single(pid) for pid in place_ids])

        # Build result dict, excluding None values
        return {pid: data for pid, data in results if data is not None}

    def _get_first_photo_url(self, place_data: dict) -> Optional[str]:
        """Get first photo URL from place data"""
        photos = place_data.get("photos", [])
        if photos and len(photos) > 0:
            return photos[0].get("url")
        return None



    """
    is_cache_stale Method Explanation
    This method checks whether a place's cached data in Firestore needs to be refreshed from Google API.
    Purpose
    Google Places API calls are paid and rate-limited. Instead of hitting the API every time:
    1. You cache the data in Firestore
    2. After a certain period, you mark it as stale and re-fetch
    """

    def is_cache_stale(self, place: dict) -> bool:
        """Check if place cache is stale"""
        last_synced = place.get("google_last_synced_at")
        if not last_synced:
            return True

        if isinstance(last_synced, datetime):
            sync_date = last_synced
        else:
            # Handle Firestore timestamp
            sync_date = last_synced.datetime()

        stale_threshold = datetime.now(timezone.utc) - timedelta(days=settings.GOOGLE_CACHE_DAYS)
        return sync_date < stale_threshold

place_repository = PlaceRepository()
