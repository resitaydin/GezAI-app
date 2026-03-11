from pydantic import BaseModel
from typing import List, Optional
from enum import Enum

class TravelMode(str, Enum):
    WALKING = "walking"
    DRIVING = "driving"
    TRANSIT = "transit"

class RoutePlace(BaseModel):
    name: str
    lat: Optional[float] = None
    lng: Optional[float] = None

class GoogleMapsLinkRequest(BaseModel):
    """Google Maps link oluşturmak için request"""
    places: List[RoutePlace]  # Sıralı liste
    travel_mode: TravelMode = TravelMode.WALKING

class GoogleMapsLinkResponse(BaseModel):
    """Response with deep link"""
    google_maps_url: str
    travel_mode: TravelMode
    total_stops: int