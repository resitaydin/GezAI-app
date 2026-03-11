import httpx
from typing import Any, Dict, Optional, List
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

class GooglePlacesService:
    """Google Places API (New) service"""

    # https://places.googleapis.com/v1/places/PLACE_ID
    BASE_URL = "https://places.googleapis.com/v1/places"

    # https://places.googleapis.com/v1/places:searchText
    TEXT_SEARCH_URL = "https://places.googleapis.com/v1/places:searchText"

    # https://places.googleapis.com/v1/NAME/media?key=API_KEY&PARAMETERS
    PHOTO_BASE_URL = "https://places.googleapis.com/v1"

    def __init__(self):
        self.api_key = settings.GOOGLE_PLACES_API_KEY
        self.client = httpx.AsyncClient(timeout=30.0)

    async def search_place(
            self,
            name: str,
            region: str,
            language: str = "tr",
    ) -> Optional[Dict[str, Any]]:

        """
         Search for a place using Text Search (New)

         Args:
             name: Place name (e.g., "Kız Kulesi")
             region: Region name (e.g., "uskudar")
             language: Language code

         Returns:
             Place data dict or None
        """
        query = f"{name}, {region} , Istanbul, Turkey" # Later change Istanbul, Turkey dynamically

        headers = {
            "Content-Type": "application/json", # Tells the server we expect JSON response
            "X-Goog-Api-Key": self.api_key,
            "X-Goog-FieldMask": ",".join([
                "places.id",
                "places.displayName",
                "places.formattedAddress",
                "places.location",
                "places.rating",
                "places.userRatingCount",
                "places.photos",
                "places.types",
                "places.editorialSummary"
            ])
        }
        """
        This is a Field Mask that specifies exactly which fields you want returned from the API. It's a performance and cost optimization feature.
        How it works:
        Google Places API charges based on which fields you request
        Instead of returning ALL place data (expensive), you only get the fields you need
        Fields are comma-separated in a single string
        """

        payload = {
            "textQuery": query,
            "languageCode": language,
            "maxResultCount": 1,
            "locationBias": {
                "circle": {
                    "center": {
                        "latitude": 41.0082,  # Istanbul center later make dynamic
                        "longitude": 28.9784
                    },
                    "radius": 50000.0  # 50km radius
                }
            }
        }

        try:
            response = await self.client.post( # POST request for Text Search from Google Places API
                self.TEXT_SEARCH_URL,
                headers=headers,
                json=payload
            )
            response.raise_for_status()
            data = response.json()

            places = data.get("places", [])
            if not places:
                logger.warning(f"No places found for query: {query}")
                return None

            return places[0]

        except httpx.HTTPError as e:
            logger.error(f"Google Places API error: {e}")
            raise GooglePlacesError(f"Failed to search place: {e}")


    async def get_place_details(
            self,
            place_id: str,
            language: str = "tr"
    ) -> Optional[Dict[str, Any]]:

        """
        Get detailed place information using Place Details (New)

        Args:
            place_id: Google Place ID
            language: Language code

        Returns:
            Place details dict or None
        """

        url = f"{self.BASE_URL}/{place_id}"

        headers = {
            "X-Goog-Api-Key": self.api_key,
            "X-Goog-FieldMask": ",".join([
                "id",
                "displayName",
                "formattedAddress",
                "location",
                "rating",
                "userRatingCount",
                "photos",
                "types",
                "editorialSummary",
                "reviews"
            ])
        }

        params = {
            "languageCode": language
        }

        try:
            response = await self.client.get( # GET request for Place Details from Google Places API
                url,
                headers=headers,
                params=params
            )
            response.raise_for_status()
            return response.json()

        except httpx.HTTPError as e:
            logger.error(f"Google Place Details error: {e}")
            raise GooglePlacesError(f"Failed to get place details: {e}")


    def generate_photo_url(
            self,
            photo_name: str,
            max_width: int = 800,
            max_height: int = 600
    ) -> str:
        """
        Generate photo URL for Places API (New
        Args:
            photo_name: Photo resource name from API
            max_width: Maximum width
            max_height: Maximum heigh
        Returns:
            Photo URL string
        """

        return (
            f"{self.PHOTO_BASE_URL}/{photo_name}/media"
            f"?maxWidthPx={max_width}"
            f"&maxHeightPx={max_height}"
            f"&key={self.api_key}"
        )

    def parse_place_response(
            self,
            google_data: Dict[str, Any],
            region: str,
            city: str = "istanbul"
    ) -> Dict[str, Any]:
        """
        Parse Google Places API response to our schema

        Args:
            google_data: Raw Google API response
            region: Region name
            city: City name

        Returns:
            Parsed place dict matching our schema
        """
        # Extract photos
        photos = []
        for photo in google_data.get("photos", [])[:5]:  # Max 5 photos
            photo_name = photo.get("name", "")
            photos.append({
                "photo_reference": photo_name,
                "url": self.generate_photo_url(photo_name),
                "width": photo.get("widthPx", 0),
                "height": photo.get("heightPx", 0),
                "attribution": self._get_attribution(photo)
            })

        # Map Google types to our categories
        # Some types couldn't  correct or appropriate control mapping.
        # If category name is not correctly assigned, get category from llm...
        google_types = google_data.get("types", [])
        category = self._map_category(google_types)

        # Get location
        location = google_data.get("location", {})

        # Get display name
        display_name = google_data.get("displayName", {})

        return {
            "google_place_id": google_data.get("id"),
            "name": display_name.get("text", ""),
            "name_en": None,  # Can fetch with language="en" separately
            "description": google_data.get("editorialSummary", {}).get("text"),
            "description_en": None,
            "location": {
                "lat": location.get("latitude"),
                "lng": location.get("longitude")
            },
            "formatted_address": google_data.get("formattedAddress", ""),
            "region": region,
            "city": city,
            "category": category,
            "rating": google_data.get("rating"),
            "total_ratings": google_data.get("userRatingCount"),
            "photos": photos,
            "google_sync_status": "fresh"
        }

    def _map_category(self, google_types: List[str]) -> str:
        """Map Google place types to our categories"""
        type_mapping = {
            "mosque": "mosque",
            "church": "church",
            "museum": "museum",
            "park": "park",
            "restaurant": "restaurant",
            "cafe": "cafe",
            "tourist_attraction": "attraction",
            "historical_landmark": "historical",
            "point_of_interest": "poi"
        }

        for gtype in google_types:
            if gtype in type_mapping:
                return type_mapping[gtype]

        return "other"

    def _get_attribution(self, photo: Dict) -> Optional[str]:
        """Extract photo attribution"""
        attributions = photo.get("authorAttributions", [])
        if attributions:
            return attributions[0].get("displayName")
        return None

    async def close(self):
        """Close HTTP client"""
        await self.client.aclose()

class GooglePlacesError(Exception):
    """Custom exception for Google Places API errors"""
    pass


# Singleton instance
google_places_service = GooglePlacesService()


