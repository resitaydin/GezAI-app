from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime, date

class SavedRouteCreate(BaseModel):
    """POST /saved-routes request"""
    route_id: str  # Sadece route_id referansı
    custom_title: str
    custom_notes: Optional[str] = None
    planned_date: Optional[date] = None
    planned_start_time: Optional[str] = None


class SavedRouteUpdate(BaseModel):
    """PUT /saved-routes/{id} request"""
    custom_title: Optional[str] = None
    custom_notes: Optional[str] = None
    planned_date: Optional[date] = None
    planned_start_time: Optional[str] = None
    user_rating: Optional[int] = Field(None, ge=1, le=5)
    user_review: Optional[str] = None

# Saved Route DB Schema
class SavedRouteDB(BaseModel):
    """Firebase'de kaydedilen yapı"""
    saved_route_id: str
    user_id: str
    route_id: str  # → routes/{route_id} referansı

    # User Customizations
    custom_title: Optional[str] = None
    custom_notes: Optional[str] = None
    planned_date: Optional[str] = None  # ISO format
    planned_start_time: Optional[str] = None

    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None

    # User Feedback
    user_rating: Optional[int] = None
    user_review: Optional[str] = None

    # Metadata
    saved_at: datetime
    updated_at: datetime


# ===== RESPONSE MODELS (Route data ile birlikte) =====

class PlaceInRoute(BaseModel):
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


class RouteDetail(BaseModel):
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
    places: List[PlaceInRoute] = []
    summary: Optional[dict] = None
    is_featured: bool = False
    created_at: Optional[datetime] = None

# ===== FULL RESPONSE MODEL (Route data ile birlikte) =====

class SavedRouteResponse(BaseModel):
    """GET /saved-routes/{id} response - Full detail"""
    saved_route_id: str
    user_id: str
    route_id: str

    # Route data (joined)
    route: RouteDetail

    # User customizations
    custom_title: Optional[str] = None
    custom_notes: Optional[str] = None
    planned_date: Optional[date] = None
    planned_start_time: Optional[str] = None

    # Status
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None

    # User feedback
    user_rating: Optional[int] = None
    user_review: Optional[str] = None

    # Metadata
    saved_at: datetime
    updated_at: datetime

    # Computed
    # google_maps_url: Optional[str] = None  Decide logic of google_maps_url later
    display_title: str  # custom_title or route.title


# class SavedRouteListItem(BaseModel):
#     """GET /saved-routes response item - Light version"""
#     saved_route_id: str
#     route_id: str
#     display_title: str
#     places_count: int
#     duration_hours: float
#     transport_type: str
#     region: List[str]
#     planned_date: Optional[date] = None
#     saved_at: datetime
#
#
# class SavedRouteListResponse(BaseModel):
#     routes: List[SavedRouteListItem]
#     total: int

# ======== RESPONSE MODELS (Route detayı olmadan) =====

class SavedRouteListItem(BaseModel):
    """Liste için hafif model - route detayı YOK"""
    saved_route_id: str
    route_id: str

    # Display info
    display_title: str

    # Route özet (sadece gerekli alanlar)
    places_count: int
    duration_hours: Optional[float] = None
    transport_type: Optional[str] = None
    region: Optional[List[str]] = None
    thumbnail_url: Optional[str] = None  # İlk place'in fotoğrafı

    # User customizations
    planned_date: Optional[date] = None
    planned_start_time: Optional[str] = None

    # Timestamps
    saved_at: datetime


class SavedRouteListResponse(BaseModel):
    """GET /saved-routes response"""
    routes: List[SavedRouteListItem]
    total: int
