from fastapi import APIRouter, HTTPException, status
from app.schemas.place import PlaceResponse, PlaceCreate, PhotoResponse
from app.services.google_place_service import (
    google_places_service,
    GooglePlacesError
)
from app.repository.place_repository import place_repository
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/places", tags=["Places"])

@router.post("/", response_model=PlaceResponse, status_code=status.HTTP_201_CREATED,summary="Create or get place")
async def create_place(place_data: PlaceCreate):
    """
        POST /places - Create Place

        Flow:
        1. Take name + region ("Kız Kulesi", "uskudar")
        2. Check Firebase - if exists, return it
        3. If not exists - fetch from Google
        4. Save to Firebase
        5. Return
    """

    name = place_data.name
    region = place_data.region.lower()

    logger.info(f"Creating place: {name}, {region}")

    # Check if place already exists
    existing_place = await place_repository.find_by_name_and_region(name, region)

    if existing_place:
        logger.info(f"Place found in DB: {existing_place['place_id']}")
        """
        # Optional: Check if cache is stale
        if place_repository.is_cache_stale(existing_place):
            logger.info("Cache is stale, but returning cached version (MVP)")
            # In MVP, we don't re-sync. Could add this later.
            # May be we can re-sycn abouth a month later think it later
        """
        return PlaceResponse(**existing_place)

    # Fetch from Google Places API
    try:
        google_data = await google_places_service.search_place(name, region)

        if not google_data:
            logger.error(f"Place not found in Google Places: {name} in {region}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Place not found: {name} in {region}"
            )

        # Check if this Google Place ID already exists
        google_place_id = google_data.get("id")
        if google_place_id:
            existing_by_google_id = await place_repository.find_by_google_place_id(
                google_place_id
            )
            if existing_by_google_id:
                logger.info(f"Found by Google Place ID: {google_place_id}")
                return PlaceResponse(**existing_by_google_id)

        parsed_place = google_places_service.parse_place_response(
            google_data,
            region =region,
            city = "istanbul"
        )
        parsed_place["about"] = place_data.about

        created_place = await place_repository.create(parsed_place)

        logger.info(f"Created new place: {created_place['place_id']}")

        return PlaceResponse(**created_place)

    except GooglePlacesError as e:
        logger.error(f"Google API error: {e}")
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Failed to fetch from Google: {str(e)}"
        )


@router.get("/{place_id}",response_model=PlaceResponse,summary="Get place by ID")
async def get_place(place_id: str):
    """
    GET /places/{place_id}

    Flow:
    1. Get from Firebase
    2. If not exists - return 404
    3. Return place (about generation moved to Flutter frontend)
    """
    place = await place_repository.get_by_id(place_id)

    if not place:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Place not found: {place_id}"
        )

    return PlaceResponse(**place)


@router.get("/{place_id}/photos",response_model=PhotoResponse,summary="Get place photos by ID")
async def get_place_photos(place_id: str):
    """
    GET /places/{place_id}/photos

    Flow:
    1. Get place from Firebase
    2. If not exists - return 404
    3. If exists - return photos
    """
    photos = await place_repository.get_photos(place_id)

    if photos is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Place not found: {place_id}"
        )

    return PhotoResponse(place_id=place_id, photos=photos)



