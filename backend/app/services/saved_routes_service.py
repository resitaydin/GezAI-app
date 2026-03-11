from typing import Optional, List
from app.schemas.saved_routes import (
    SavedRouteCreate,
    SavedRouteUpdate,
    SavedRouteResponse,
    SavedRouteListItem,
    SavedRouteListResponse,
    RouteDetail,
    PlaceInRoute
)
from app.repository.saved_routes_repository import saved_routes_repository
from app.repository.route_repository import route_repository
from app.repository.place_repository import place_repository
from app.services.route_service import route_service
import logging
import asyncio

logger = logging.getLogger(__name__)

class SavedRoutesService:
    """Business logic for saved routes"""

    async def save_route(
            self,
            user_id: str,
            data: SavedRouteCreate
    ) -> SavedRouteResponse:
        """Save a route for user - OPTIMIZED with parallel checks"""

        # 1. PARALLEL: Check route exists AND check if already saved
        route_task = route_repository.get_by_id(data.route_id)
        exist_task = saved_routes_repository.find_by_route_and_user(user_id, data.route_id)

        route, exist_saved_route = await asyncio.gather(route_task, exist_task)

        if not route:
            raise ValueError("Route not found: {}".format(data.route_id))
        if exist_saved_route:
            raise ValueError("Route already saved by user")

        # 2. Create saved route - convert date to string for Firestore
        save_data = {**data.__dict__}

        # Convert datetime.date to ISO string for Firestore compatibility
        if save_data.get("planned_date") and hasattr(save_data["planned_date"], "isoformat"):
            save_data["planned_date"] = save_data["planned_date"].isoformat()

        saved_route = await saved_routes_repository.create(
            user_id, save_data
        )
        return await self._build_response(saved_route, route)

    async def get_saved_route(
            self,
            user_id: str,
            saved_route_id: str
    ) -> Optional[SavedRouteResponse]:
        """Get saved route by ID for user"""

        # 1. Get saved route
        saved_route = await saved_routes_repository.get_by_id_and_user(
            user_id, saved_route_id
        )
        if not saved_route:
            raise ValueError("Saved route not found")

        # 2. Get route details
        route = await route_service.get_route(saved_route["route_id"])
        if not route:
            raise ValueError("Route not found: {}".format(saved_route["route_id"]))

        # Convert RouteResponse to dict for _build_response
        route_dict = route.model_dump()
        return await self._build_response(saved_route, route_dict)

    async def list_saved_routes(
            self,
            user_id: str
    ) -> SavedRouteListResponse:
        """Kayıtlı rotaları listele - SADECE ÖZET"""

        # 1. Saved routes çek
        saved_routes = await saved_routes_repository.list_by_user(user_id=user_id)

        # 2. Total count
        total = len(saved_routes)

        # 3. Route özetlerini çek (hafif!)
        route_ids = [s["route_id"] for s in saved_routes]
        route_summaries = await route_repository.get_summary_multiple(route_ids)

        # 4. List items oluştur
        items = []
        for saved in saved_routes:
            route_summary = route_summaries.get(saved["route_id"])
            if route_summary:
                items.append(self._build_list_item(saved, route_summary))

        return SavedRouteListResponse(
            routes=items,
            total=total
        )

    async def update_saved_route(
            self,
            user_id: str,
            saved_route_id: str,
            data: SavedRouteUpdate
    ) -> Optional[SavedRouteResponse]:
        """Update saved route for user"""

        saved_route = await saved_routes_repository.get_by_id_and_user(
            user_id, saved_route_id
        )
        if not saved_route:
            return None

        update_data = {k: v for k, v in data.__dict__.items() if v is not None}

        updated_saved_route = await saved_routes_repository.update(
            saved_route_id, update_data
        )
        if not updated_saved_route:
            return None

        route = await route_repository.get_by_id(updated_saved_route["route_id"])

        return await self._build_response(updated_saved_route, route)

    async def delete_saved_route(
            self,
            user_id: str,
            saved_route_id: str
    ) -> bool:
        """Delete saved route for user"""

        existing = await saved_routes_repository.get_by_id_and_user(
            user_id, saved_route_id
        )
        if not existing:
            return False

        return await saved_routes_repository.delete(saved_route_id)

    def _build_list_item(self, saved: dict, route_summary: dict) -> SavedRouteListItem:
        """Liste için hafif item oluştur"""

        display_title = saved.get("custom_title") or route_summary.get("title", "Unnamed")

        return SavedRouteListItem(
            saved_route_id=saved["saved_route_id"],
            route_id=saved["route_id"],
            display_title=display_title,
            places_count=route_summary.get("places_count", 0),
            duration_hours=route_summary.get("duration_hours"),
            transport_type=route_summary.get("transport_type"),
            region=route_summary.get("region", []),
            thumbnail_url=route_summary.get("thumbnail_url"),
            planned_date=saved.get("planned_date"),
            planned_start_time=saved.get("planned_start_time"),
            saved_at=saved.get("saved_at")
        )


    async def _build_response(
            self,
            saved_route: dict,
            route: dict
    ) -> SavedRouteResponse:
        """Build full response with route details - OPTIMIZED with batch fetch"""
        route_places = route.get("places", [])

        # Collect place_ids that need fetching (missing name)
        place_ids_to_fetch = [
            p.get("place_id") for p in route_places
            if not p.get("name") and p.get("place_id")
        ]

        # BATCH FETCH: Get all missing places in one parallel call
        fetched_places = {}
        if place_ids_to_fetch:
            fetched_places = await place_repository.get_multiple(place_ids_to_fetch)

        # Build places list
        places = []
        for place in route_places:
            place_id = place.get("place_id")

            # Use existing data or fetched data
            name = place.get("name")
            name_en = place.get("name_en")
            location = place.get("location")
            formatted_address = place.get("formatted_address")
            category = place.get("category")
            photo_url = place.get("photo_url")

            if not name and place_id and place_id in fetched_places:
                place_data = fetched_places[place_id]
                name = place_data.get("name", "Unknown Place")
                name_en = place_data.get("name_en")
                location = place_data.get("location")
                formatted_address = place_data.get("formatted_address", "")
                category = place_data.get("category")
                photo_url = place_data.get("photo_url")

            place_in_route = PlaceInRoute(
                place_id=place_id,
                order=place.get("order", 0),
                name=name or "Unknown Place",
                name_en=name_en,
                location=location,
                formatted_address=formatted_address or "",
                category=category,
                photo_url=photo_url,
                duration_minutes=place.get("duration_minutes"),
                notes=place.get("notes"),
                notes_en=place.get("notes_en"),
                travel_to_next=place.get("travel_to_next")
            )
            places.append(place_in_route)

        # Build route detail
        route_detail = RouteDetail(
            route_id=route["route_id"],
            title=route["title"],
            title_en=route.get("title_en"),
            description=route.get("description"),
            description_en=route.get("description_en"),
            region=route.get("region", []),
            duration_hours=route.get("duration_hours", 0),
            transport_type=route.get("transport_type", ""),
            total_distance_km=route.get("total_distance_km"),
            categories=route.get("categories", []),
            mood_tags=route.get("mood_tags", []),
            best_time=route.get("best_time"),
            places=places,
            summary=route.get("summary"),
            is_featured=route.get("is_featured", False),
            created_at=route.get("created_at")
        )

        display_title = saved_route.get("custom_title") or route.get("title", "Unnamed Route")

        return SavedRouteResponse(
            saved_route_id=saved_route["saved_route_id"],
            user_id=saved_route["user_id"],
            route_id=saved_route["route_id"],
            route=route_detail,
            custom_title=saved_route.get("custom_title"),
            custom_notes=saved_route.get("custom_notes"),
            planned_date=saved_route.get("planned_date"),
            planned_start_time=saved_route.get("planned_start_time"),
            started_at=saved_route.get("started_at"),
            completed_at=saved_route.get("completed_at"),
            user_rating=saved_route.get("user_rating"),
            user_review=saved_route.get("user_review"),
            saved_at=saved_route["saved_at"],
            updated_at=saved_route["updated_at"],
            display_title=display_title
        )


saved_routes_service = SavedRoutesService()







