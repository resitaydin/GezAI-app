from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum

class SyncStatus(str, Enum):
    FRESH = "fresh"
    STALE = "stale"
    ERROR = "error"

class Location(BaseModel):
    lat: float
    lng: float

class Photo(BaseModel):
    photo_reference: str
    url: Optional[str] = None
    width: int
    height: int
    attribution: Optional[str] = None

class PlaceBase(BaseModel):
    name: str
    region: str
    about: Optional[str] = None

class PlaceCreate(PlaceBase):
    pass

class PlaceResponse(BaseModel):
    place_id: str
    google_place_id: Optional[str] = None

    name: str
    name_en: Optional[str] = None
    description: Optional[str] = None
    description_en: Optional[str] = None

    location: Location
    formatted_address: str
    region: str
    city: str

    category: Optional[str] = None

    rating: Optional[float] = None
    total_ratings: Optional[int] = None

    photos: List[Photo] = []

    about: Optional[str] = None

    google_last_synced_at: Optional[datetime] = None
    google_sync_status: SyncStatus = SyncStatus.FRESH
    created_at: datetime
    updated_at: datetime

class PhotoResponse(BaseModel):
    place_id: str
    photos: List[Photo]
