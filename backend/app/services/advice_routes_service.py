from typing import Optional, List
from app.schemas.advice_routes import (
    AdviceRouteCreate,
    AdviceRouteDetail,
    AdviceRouteResponse,
    PlaceInAdviceRoute,
    AdviceRouteListResponse,
    AdviceRouteListItem
)
from app.repository.advice_routes_repository import advice_routes_repository
from app.repository.route_repository import route_repository
from app.repository.place_repository import place_repository
import logging
import asyncio

logger = logging.getLogger(__name__)

class AdviceRoutesService:
    """Business logic for advice routes"""

    async def create_advice_route(
            self,
            data: AdviceRouteCreate
    ) -> AdviceRouteResponse:
        """Create a new advice route - OPTIMIZED with parallel checks"""

        # PARALLEL: Check route exists AND check if already created
        route_task = route_repository.get_by_id(data.route_id)
        exist_task = advice_routes_repository.find_by_route(data.route_id)

        route, exist_advice_route = await asyncio.gather(route_task, exist_task)

        if not route:
            raise ValueError("Route not found: {}".format(data.route_id))
        if exist_advice_route:
            raise ValueError("Advice route already exists for this route")

        # Create advice route
        save_data = {**data.__dict__}

        advice_route = await advice_routes_repository.create(save_data)
        return await self._build_response(advice_route, route)


    async def get_advice_route(
            self,
            advice_route_id: str
    ) -> Optional[AdviceRouteResponse]:
        """Get advice route by ID"""

        # 1. Get advice route
        advice_route = await advice_routes_repository.get_by_id(advice_route_id)
        if not advice_route:
            raise ValueError("Advice route not found: {}".format(advice_route_id))

        # 2. Get route details
        route = await route_repository.get_by_id(advice_route["route_id"])
        if not route:
            raise ValueError("Route not found for advice route: {}".format(advice_route_id))

        return await self._build_response(advice_route, route)

    async def list_advice_routes(self) -> AdviceRouteListResponse:
        """List all advice routes with summary info"""

        advice_routes = await advice_routes_repository.get_all_advice_routes()

        if not advice_routes:
            return AdviceRouteListResponse(routes=[], total=0)

        # Collect all route_ids and fetch summaries in one call
        route_ids = [advice["route_id"] for advice in advice_routes]
        route_summaries = await route_repository.get_summary_multiple(route_ids)

        list_items = []
        for advice in advice_routes:
            route_id = advice["route_id"]
            route_summary = route_summaries.get(route_id)

            if not route_summary:
                logger.warning("Route not found for advice route: {}".format(advice["advice_route_id"]))
                continue

            list_item = AdviceRouteListItem(
                advice_route_id=advice["advice_route_id"],
                route_id=route_id,
                display_title=route_summary.get("title", "Unnamed"),
                places_count=route_summary.get("places_count", 0),
                duration_hours=route_summary.get("duration_hours"),
                transport_type=route_summary.get("transport_type"),
                region=route_summary.get("region", []),
                thumbnail_url=route_summary.get("thumbnail_url"),
                category=route_summary.get("categories", []),
                mood=route_summary.get("mood_tags", []),
                created_at=advice["created_at"]
            )
            list_items.append(list_item)

        return AdviceRouteListResponse(
            routes=list_items,
            total=len(list_items)
        )


    async def delete_advice_route(
            self,
            advice_route_id: str
    ) -> None:
        """Delete advice route by ID"""

        deleted = await advice_routes_repository.delete(advice_route_id)
        if not deleted:
            raise ValueError("Advice route not found: {}".format(advice_route_id))
        return None

    async def _build_response(
            self,
            advice_route: dict,
            route: dict
    ) -> AdviceRouteResponse:
        """Build full response with route details"""
        # Get all place_ids from route
        route_places = route.get("places", [])
        place_ids = [p.get("place_id") for p in route_places if p.get("place_id")]

        # Fetch place details from places collection
        place_details = await place_repository.get_multiple(place_ids)

        # Parse route places - enrich with place data from places collection
        places = []
        for place in route_places:
            place_id = place.get("place_id")
            place_data = place_details.get(place_id, {})

            place_in_route = PlaceInAdviceRoute(
                place_id=place_id,
                order=place.get("order", 0),
                name=place_data.get("name") or place.get("name") or "Unknown Place",
                name_en=place_data.get("name_en") or place.get("name_en"),
                location=place_data.get("location") or place.get("location"),
                formatted_address=place_data.get("formatted_address") or place.get("formatted_address") or "",
                category=place_data.get("category") or place.get("category"),
                photo_url=place_data.get("photo_url") or place.get("photo_url"),
                duration_minutes=place.get("duration_minutes"),
                notes=place.get("notes"),
                notes_en=place.get("notes_en"),
                travel_to_next=place.get("travel_to_next")
            )
            places.append(place_in_route)

        # Build route detail
        route_detail = AdviceRouteDetail(
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

        return AdviceRouteResponse(
            advice_route_id=advice_route["advice_route_id"],
            route_id=advice_route["route_id"],
            route=route_detail,
            created_at=advice_route["created_at"],
            updated_at=advice_route["updated_at"],
        )


advice_routes_service = AdviceRoutesService()