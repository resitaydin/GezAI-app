from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime, date

class AdviceRouteCreate(BaseModel):
    """POST /advice-routes request"""
    route_id: str

class AdviceRouteDB(BaseModel):
    """Firebase'de kaydedilen yapı"""
    advice_route_id: str
    route_id: str

    created_at: datetime
    updated_at: datetime

class PlaceInAdviceRoute(BaseModel):
    """Route içindeki place bilgisi"""
    place_id: str
    order: int

    name: str
    name_en: Optional[str] = None

    location: Optional[dict] = None
    formatted_address: Optional[str] = None
    category: Optional[str] = None
    photo_url: Optional[str] = None

    duration_minutes: Optional[int] = None
    notes: Optional[str] = None
    notes_en: Optional[str] = None
    travel_to_next: Optional[dict] = None


class AdviceRouteDetail(BaseModel):
    """Route detay bilgisi"""
    route_id: str
    title: str
    title_en: Optional[str] = None
    description: Optional[str] = None
    description_en: Optional[str] = None
    region: List[str]
    duration_hours: float
    transport_type: str
    total_distance_km: Optional[float] = None
    categories: List[str] = []
    mood_tags: List[str] = []
    best_time: Optional[str] = None
    places: List[PlaceInAdviceRoute] = []
    summary: Optional[dict] = None
    is_featured: bool = False
    created_at: Optional[datetime] = None

class AdviceRouteResponse(BaseModel):
    """GET /advice-routes/{id} response - Full detail"""
    advice_route_id: str
    route_id: str

    # Route data (joined)
    route: AdviceRouteDetail

    # Metadata
    created_at: datetime
    updated_at: datetime

class AdviceRouteListItem(BaseModel):
    """Liste için hafif model - route detayı YOK"""
    advice_route_id: str
    route_id: str

    # Display info
    display_title: str

    # Route özet (sadece gerekli alanlar)
    places_count: int
    duration_hours: Optional[float] = None
    transport_type: Optional[str] = None
    region: Optional[List[str]] = None
    thumbnail_url: Optional[str] = None  # İlk place'in fotoğrafı
    category: Optional[List[str]] = None
    mood: Optional[List[str]] = None
    # Timestamps
    created_at: datetime


class AdviceRouteListResponse(BaseModel):
    """GET /saved-routes response"""
    routes: List[AdviceRouteListItem]
    total: int
