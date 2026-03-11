# services/route_service.py

import asyncio
from typing import List, Tuple, Optional
from app.schemas.route import (
    RouteCreateRequest,
    RouteResponse,
    RouteCreateResponse,
    PlaceInRouteResponse,
    PlaceInRouteDB,
    TravelToNext,
    RouteSummary,
    RouteGeneration
)
from app.schemas.place import PlaceCreate
from app.repository.route_repository import route_repository
from app.repository.place_repository import place_repository
from app.services.google_place_service import google_places_service, GooglePlacesError
import logging

logger = logging.getLogger(__name__)


class RouteService:
    """Service for route operations"""

    async def create_route(self, request: RouteCreateRequest) -> RouteCreateResponse:
        """
        Create a new route

        Flow:
        1. Process each place - create if not exists, get place_id if exists
        2. Build route document with place_ids
        3. Store route in Firestore
        4. Return response with place details

        Args:
            request: RouteCreateRequest with places as names

        Returns:
            RouteCreateResponse with full route data and place details
        """
        logger.info(f"Creating route: {request.title}")

        # Process places and get place_ids (now parallel)
        processed_places, places_created, places_existing = await self._process_places(
            request.places
        )

        # Calculate summary if not provided
        summary = self._calculate_summary(request, processed_places)

        # Calculate total_distance_km: use request value if provided, otherwise sum travel_to_next distances
        total_distance_km = request.total_distance_km
        if total_distance_km is None:
            total_distance_km = sum(
                p.travel_to_next.distance_km
                for p in processed_places
                if p.travel_to_next and p.travel_to_next.distance_km
            ) or None  # Return None if sum is 0

        # Build route data for Firestore
        route_data = {
            "user_id": request.user_id,
            "title": request.title,
            "title_en": request.title_en,
            "description": request.description,
            "description_en": request.description_en,
            "region": request.region,
            "duration_hours": request.duration_hours,
            "transport_type": request.transport_type.value,
            "total_distance_km": total_distance_km,
            "categories": request.categories,
            "mood_tags": request.mood_tags,
            "best_time": request.best_time.value,
            "places": [p.model_dump() for p in processed_places],
            "summary": summary.model_dump() if summary else None,
            "generation": request.generation.model_dump() if request.generation else None,
            "is_featured": request.is_featured
        }

        # Create route in Firestore
        created_route = await route_repository.create(route_data)

        # Build response with place details (now parallel)
        response = await self._build_response(created_route)

        return RouteCreateResponse(
            route=response,
            places_created=places_created,
            places_existing=places_existing,
            message=f"Route created successfully with {len(processed_places)} places"
        )

    async def _process_places(
        self,
        places_input: List
    ) -> Tuple[List[PlaceInRouteDB], int, int]:
        """
        Process places from input in parallel - create if not exists, get place_id if exists

        Args:
            places_input: List of PlaceInput from request

        Returns:
            Tuple of (processed_places, places_created_count, places_existing_count)
        """
        # Process all places in parallel
        tasks = [
            self._process_single_place(place_input)
            for place_input in places_input
        ]

        results = await asyncio.gather(*tasks, return_exceptions=True)

        # Collect results and handle errors
        processed_places = []
        places_created = 0
        places_existing = 0
        errors = []

        for i, result in enumerate(results):
            if isinstance(result, Exception):
                place_name = places_input[i].name if i < len(places_input) else "unknown"
                errors.append(f"Failed to process place '{place_name}': {result}")
                logger.error(f"Failed to process place {place_name}: {result}")
            else:
                place_db, was_created = result
                processed_places.append(place_db)
                if was_created:
                    places_created += 1
                else:
                    places_existing += 1

        # If any places failed, raise error with all failures
        if errors:
            raise RouteServiceError("; ".join(errors))

        # Sort by order to maintain original sequence
        processed_places.sort(key=lambda p: p.order)

        return processed_places, places_created, places_existing

    async def _process_single_place(self, place_input) -> Tuple[PlaceInRouteDB, bool]:
        """
        Process a single place - find existing or create new

        Args:
            place_input: PlaceInput from request

        Returns:
            Tuple of (PlaceInRouteDB, was_created)
        """
        was_created = False

        # Try to find existing place by name and region
        existing_place = await place_repository.find_by_name_and_region(
            place_input.name,
            place_input.region.lower()
        )

        if existing_place:
            # Use existing place
            place_id = existing_place["place_id"]
            logger.info(f"Using existing place: {place_input.name} ({place_id})")
        else:
            # Create new place via Google Places API
            place_id = await self._create_place(
                place_input.name,
                place_input.region
            )
            was_created = True
            logger.info(f"Created new place: {place_input.name} ({place_id})")

        # Build PlaceInRouteDB
        travel_to_next = None
        if place_input.travel_to_next:
            travel_to_next = TravelToNext(
                distance_km=place_input.travel_to_next.distance_km,
                duration_minutes=place_input.travel_to_next.duration_minutes,
                polyline=place_input.travel_to_next.polyline
            )

        place_db = PlaceInRouteDB(
            place_id=place_id,
            order=place_input.order,
            duration_minutes=place_input.duration_minutes,
            notes=place_input.notes,
            notes_en=place_input.notes_en,
            travel_to_next=travel_to_next
        )

        return place_db, was_created

    async def _create_place(self, name: str, region: str) -> str:
        """
        Create a new place using Google Places API

        Args:
            name: Place name
            region: Region name

        Returns:
            place_id of created place
        """
        region = region.lower()

        # Search in Google Places API
        google_data = await google_places_service.search_place(name, region)

        if not google_data:
            raise RouteServiceError(f"Place not found in Google: {name} in {region}")

        # Check if this Google Place ID already exists (deduplication)
        google_place_id = google_data.get("id")
        if google_place_id:
            existing = await place_repository.find_by_google_place_id(google_place_id)
            if existing:
                return existing["place_id"]

        # Parse and save to Firestore
        parsed_place = google_places_service.parse_place_response(
            google_data,
            region=region,
            city="istanbul"
        )

        created_place = await place_repository.create(parsed_place)
        return created_place["place_id"]

    def _calculate_summary(
        self,
        request: RouteCreateRequest,
        processed_places: List[PlaceInRouteDB]
    ) -> RouteSummary:
        """Calculate route summary"""
        if request.summary:
            return RouteSummary(**request.summary.model_dump())

        total_places = len(processed_places)
        total_visit_minutes = sum(
            p.duration_minutes or 0 for p in processed_places
        )
        total_transport_minutes = sum(
            p.travel_to_next.duration_minutes or 0
            for p in processed_places
            if p.travel_to_next
        )

        return RouteSummary(
            total_places=total_places,
            total_transport_minutes=total_transport_minutes if total_transport_minutes > 0 else None,
            total_visit_minutes=total_visit_minutes if total_visit_minutes > 0 else None
        )

    async def _build_response(self, route_data: dict) -> RouteResponse:
        """
        Build RouteResponse with place details - OPTIMIZED with batch fetch

        Args:
            route_data: Route data from Firestore

        Returns:
            RouteResponse with full place details
        """
        route_places = route_data.get("places", [])

        # BATCH FETCH: Get all place details in one parallel call
        place_ids = [p.get("place_id") for p in route_places if p.get("place_id")]
        place_details = await place_repository.get_multiple(place_ids)

        # Build places response
        places_response = []
        for place_in_route in route_places:
            place_id = place_in_route.get("place_id")
            place_data = place_details.get(place_id, {})

            # Build travel_to_next
            travel_to_next = None
            if place_in_route.get("travel_to_next"):
                travel_to_next = TravelToNext(**place_in_route["travel_to_next"])

            places_response.append(PlaceInRouteResponse(
                place_id=place_id,
                order=place_in_route.get("order", 0),
                name=place_data.get("name", ""),
                name_en=place_data.get("name_en"),
                location=place_data.get("location"),
                formatted_address=place_data.get("formatted_address"),
                category=place_data.get("category"),
                photo_url=place_data.get("photo_url"),
                duration_minutes=place_in_route.get("duration_minutes"),
                notes=place_in_route.get("notes"),
                notes_en=place_in_route.get("notes_en"),
                travel_to_next=travel_to_next
            ))

        # Build summary
        summary = None
        if route_data.get("summary"):
            summary = RouteSummary(**route_data["summary"])

        # Build generation info
        generation = None
        if route_data.get("generation"):
            generation = RouteGeneration(**route_data["generation"])

        return RouteResponse(
            route_id=route_data["route_id"],
            user_id=route_data.get("user_id"),
            title=route_data.get("title", ""),
            title_en=route_data.get("title_en"),
            description=route_data.get("description"),
            description_en=route_data.get("description_en"),
            region=route_data.get("region", []),
            duration_hours=route_data.get("duration_hours", 0),
            transport_type=route_data.get("transport_type", "walking"),
            total_distance_km=route_data.get("total_distance_km"),
            categories=route_data.get("categories", []),
            mood_tags=route_data.get("mood_tags", []),
            best_time=route_data.get("best_time", "anytime"),
            places=places_response,
            summary=summary,
            generation=generation,
            is_featured=route_data.get("is_featured", False),
            created_at=route_data.get("created_at"),
            updated_at=route_data.get("updated_at")
        )

    async def get_route(self, route_id: str) -> RouteResponse:
        """
        Get route by ID with full place details

        Args:
            route_id: Route ID

        Returns:
            RouteResponse with full place details

        Raises:
            RouteServiceError if route not found
        """
        route_data = await route_repository.get_by_id(route_id)

        if not route_data:
            raise RouteServiceError(f"Route not found: {route_id}")

        return await self._build_response(route_data)


class RouteServiceError(Exception):
    """Custom exception for route service errors"""
    pass


# Singleton instance
route_service = RouteService()
