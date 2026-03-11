from fastapi import APIRouter, HTTPException, status
from app.schemas.route import (
    RouteCreateRequest,
    RouteCreateResponse,
    RouteResponse,
)
from app.services.route_service import route_service, RouteServiceError
from app.services.google_place_service import GooglePlacesError
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/routes", tags=["Routes"])


@router.post(
    "/",
    response_model=RouteCreateResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new route"
)
async def create_route(request: RouteCreateRequest):
    """
    POST /routes - Create a new route

    Flow:
    1. Receive route data with place names (from LLM or client)
    2. For each place:
       - Check if exists in Firestore by name+region
       - If exists → use existing place_id
       - If not exists → create via Google Places API
    3. Build route document with place_ids
    4. Store route in Firestore
    5. Return route with full place details

    Request body example:
    ```json
    {
        "title": "Üsküdar Tarihi Tur",
        "title_en": "Üsküdar Historical Tour",
        "description": "Üsküdar'ın tarihi mekanlarını keşfedin",
        "region": ["uskudar"],
        "duration_hours": 4,
        "transport_type": "walking",
        "categories": ["mosque", "historical"],
        "mood_tags": ["cultural", "spiritual"],
        "best_time": "morning",
        "places": [
            {
                "name": "Mihrimah Sultan Camii",
                "region": "uskudar",
                "order": 1,
                "duration_minutes": 45,
                "notes": "Mimar Sinan'ın eşsiz eseri"
            },
            {
                "name": "Kız Kulesi",
                "region": "uskudar",
                "order": 2,
                "duration_minutes": 60,
                "notes": "İstanbul'un simgesi",
                "travel_to_next": {
                    "distance_km": 1.5,
                    "duration_minutes": 20
                }
            }
        ]
    }
    ```
    """
    try:
        result = await route_service.create_route(request)
        logger.info(f"Route created: {result.route.route_id}")
        return result

    except RouteServiceError as e:
        logger.error(f"Route service error: {e}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

    except GooglePlacesError as e:
        logger.error(f"Google Places API error: {e}")
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Failed to fetch place from Google: {str(e)}"
        )


@router.get(
    "/{route_id}",
    response_model=RouteResponse,
    summary="Get route by ID"
)
async def get_route(route_id: str):
    """
    GET /routes/{route_id} - Get route with full place details

    Returns the route with all place information including:
    - Place details (name, location, address, category, photo)
    - Route-specific notes
    - Travel information between places
    """
    try:
        route = await route_service.get_route(route_id)
        return route

    except RouteServiceError as e:
        logger.error(f"Route not found: {route_id}")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
