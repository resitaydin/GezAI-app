from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum


class TransportType(str, Enum):
    WALKING = "walking"
    DRIVING = "driving"
    TRANSIT = "transit"


class BestTime(str, Enum):
    MORNING = "morning"
    AFTERNOON = "afternoon"
    EVENING = "evening"
    ANYTIME = "anytime"


class GenerationSource(str, Enum):
    LLM = "llm"
    TEMPLATE = "template"


# ===== REQUEST SCHEMAS =====

class TravelToNextInput(BaseModel):
    """Travel info to next place (input)"""
    distance_km: Optional[float] = None
    duration_minutes: Optional[int] = None
    polyline: Optional[str] = None


class PlaceInput(BaseModel):
    """Place input from LLM or client"""
    name: str = Field(..., description="Place name (will be searched in Google Places)")
    region: str = Field(..., description="Region name (e.g., 'uskudar')")
    order: int = Field(..., ge=1, description="Order in route")
    duration_minutes: Optional[int] = Field(default=30, description="Suggested visit duration")
    notes: Optional[str] = Field(default=None, description="Notes about this place (Turkish)")
    notes_en: Optional[str] = Field(default=None, description="Notes about this place (English)")
    travel_to_next: Optional[TravelToNextInput] = Field(default=None, description="Travel info to next place")


class RouteSummaryInput(BaseModel):
    """Route summary input"""
    total_places: int
    total_transport_minutes: Optional[int] = None
    total_visit_minutes: Optional[int] = None


class RouteGenerationInput(BaseModel):
    """Generation metadata input"""
    source: GenerationSource = GenerationSource.LLM
    llm_model: Optional[str] = None
    completion_tokens: Optional[int] = None
    generation_time_ms: Optional[int] = None


class RouteCreateRequest(BaseModel):
    """POST /routes request - Create a new route"""
    # Optional user context
    user_id: Optional[str] = Field(default=None, description="Creator's UID")

    # Basic info
    title: str = Field(..., description="Route title (Turkish)")
    title_en: Optional[str] = Field(default=None, description="Route title (English)")
    description: Optional[str] = Field(default=None, description="Route description (Turkish)")
    description_en: Optional[str] = Field(default=None, description="Route description (English)")

    # Route parameters
    region: List[str] = Field(..., min_length=1, description="Regions covered")
    duration_hours: float = Field(..., ge=0.5, le=24, description="Total duration in hours")
    transport_type: TransportType = Field(default=TransportType.WALKING)
    total_distance_km: Optional[float] = Field(default=None, ge=0, description="Total distance in km")

    # Categories and tags
    categories: List[str] = Field(default=[], description="Place categories")
    mood_tags: List[str] = Field(default=[], description="Mood tags")
    best_time: BestTime = Field(default=BestTime.ANYTIME)

    # Places (from LLM - will be processed to get place_ids)
    places: List[PlaceInput] = Field(..., min_length=1, description="Places in the route")

    # Summary (optional - can be calculated)
    summary: Optional[RouteSummaryInput] = None

    # Generation info (from LLM)
    generation: Optional[RouteGenerationInput] = None

    # Status
    is_featured: bool = Field(default=False)


# ===== DATABASE SCHEMAS =====

class TravelToNext(BaseModel):
    """Travel info to next place"""
    distance_km: Optional[float] = None
    duration_minutes: Optional[int] = None
    polyline: Optional[str] = None


class PlaceInRouteDB(BaseModel):
    """Place embedded in route document"""
    place_id: str  # Reference to places/{place_id}
    order: int

    # Route-specific info (can vary per route)
    duration_minutes: Optional[int] = None
    notes: Optional[str] = None
    notes_en: Optional[str] = None

    # Travel to next place
    travel_to_next: Optional[TravelToNext] = None


class RouteSummary(BaseModel):
    """Route summary statistics"""
    total_places: int
    total_transport_minutes: Optional[int] = None
    total_visit_minutes: Optional[int] = None


class RouteGeneration(BaseModel):
    """LLM generation metadata"""
    source: GenerationSource = GenerationSource.LLM
    llm_model: Optional[str] = None
    completion_tokens: Optional[int] = None
    generation_time_ms: Optional[int] = None


class RouteDB(BaseModel):
    """Route document in Firestore"""
    route_id: str
    user_id: Optional[str] = None  # Creator's UID (null for system-generated)

    # Basic info
    title: str
    title_en: Optional[str] = None
    description: Optional[str] = None
    description_en: Optional[str] = None

    # Route parameters
    region: List[str]
    duration_hours: float
    transport_type: str
    total_distance_km: Optional[float] = None

    # Categories and tags
    categories: List[str] = []
    mood_tags: List[str] = []
    best_time: str = "anytime"

    # Places
    places: List[PlaceInRouteDB] = []

    # Summary
    summary: Optional[RouteSummary] = None

    # Generation info
    generation: Optional[RouteGeneration] = None

    # Status and metadata
    is_featured: bool = False
    created_at: datetime
    updated_at: datetime


# ===== API RESPONSE SCHEMAS =====

class PlaceInRouteResponse(BaseModel):
    """Place in route response (with place details)"""
    place_id: str
    order: int

    # Place details (from places collection)
    name: str
    name_en: Optional[str] = None
    location: Optional[dict] = None
    formatted_address: Optional[str] = None
    category: Optional[str] = None
    photo_url: Optional[str] = None

    # Route-specific info
    duration_minutes: Optional[int] = None
    notes: Optional[str] = None
    notes_en: Optional[str] = None

    # Travel to next
    travel_to_next: Optional[TravelToNext] = None


class RouteResponse(BaseModel):
    """Route response"""
    route_id: str
    user_id: Optional[str] = None

    # Basic info
    title: str
    title_en: Optional[str] = None
    description: Optional[str] = None
    description_en: Optional[str] = None

    # Route parameters
    region: List[str]
    duration_hours: float
    transport_type: str
    total_distance_km: Optional[float] = None

    # Categories and tags
    categories: List[str] = []
    mood_tags: List[str] = []
    best_time: str = "anytime"

    # Places with details
    places: List[PlaceInRouteResponse] = []

    # Summary
    summary: Optional[RouteSummary] = None

    # Generation info
    generation: Optional[RouteGeneration] = None

    # Metadata
    is_featured: bool = False
    created_at: datetime
    updated_at: Optional[datetime] = None


class RouteCreateResponse(BaseModel):
    """POST /routes response"""
    route: RouteResponse
    places_created: int = Field(description="Number of new places created")
    places_existing: int = Field(description="Number of existing places used")
    message: str = "Route created successfully"
