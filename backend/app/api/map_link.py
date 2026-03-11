from fastapi import APIRouter, HTTPException
from app.schemas.map_link import (
    GoogleMapsLinkRequest,
    GoogleMapsLinkResponse,
)
from app.services.google_maps_link_service import google_maps_link_service

router = APIRouter(prefix="/map_link", tags=["Map Link"])


@router.post(
    "/google-maps-link",
    response_model=GoogleMapsLinkResponse,
    summary="Generate Google Maps deep link"
)
async def generate_google_maps_link(request: GoogleMapsLinkRequest):
    """
    Create Google Maps deep link for given places and travel mode
    Kullanıcı "Start Route" dediğinde bu URL'e yönlendir
    """
    if len(request.places) < 2:
        raise HTTPException(400, "Least two places are required to generate a route link.")

    if len(request.places) > 10:
        raise HTTPException(400, "Maximum 10 places are allowed to generate a route link.")

    url = google_maps_link_service.generate_root_link(
        places=request.places,
        travel_mode=request.travel_mode
    )

    return GoogleMapsLinkResponse(
        google_maps_url=url,
        travel_mode=request.travel_mode,
        total_stops=len(request.places)
    )