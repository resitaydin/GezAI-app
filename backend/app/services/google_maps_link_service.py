from typing import List
from urllib.parse import quote
from app.schemas.map_link import RoutePlace, TravelMode


class GoogleMapsLinkService:
    """Google Maps deep link generator"""

    BASE_URL = "https://www.google.com/maps/dir/"

    def generate_root_link(
            self,
            places: List[RoutePlace],
            travel_mode: TravelMode = TravelMode.WALKING
    ) -> str:
        """
        Create Google Maps URL for given places and travel mode

        Args:
            places: Ordered list of places
            travel_mode: Travel mode (walking, driving, transit)

        Returns:
            Google Maps URL
        """
        if len(places) < 2:
            raise ValueError("At least two places are required to generate a route link.")

        # First place
        origin = self._format_location(places[0])

        # Destination place
        destination = self._format_location(places[-1])

        # Waypoints (intermediate places)
        waypoints = ""
        if len(places) > 2:
            middle_places = places[1:-1]
            waypoints_list = [self._format_location(place) for place in middle_places]
            waypoints = "|".join(waypoints_list)

        # Construct URL
        url = f"{self.BASE_URL}?api=1" #  api=1 indicates using version 1 of the API
        url += f"&origin={quote(origin)}" #  quote() is from urllib.parse — it URL-encodes the string, converting special characters (spaces, &, #, etc.) into safe URL format
        url += f"&destination={quote(destination)}"

        if waypoints:
            url += f"&waypoints={quote(waypoints)}"

        url += f"&travelmode={travel_mode.value}"

        return url


    def _format_location(self, place: RoutePlace) -> str:
        """
        Convert place to location string for Google Maps URL
        If lat/lng available, use them; otherwise use name + region
        """
        if place.lat and place.lng:
            return f"{place.lat},{place.lng}"

        # İsim + region ile ara
        return f"{place.name}, üsküdar, Istanbul, Turkey"

google_maps_link_service = GoogleMapsLinkService()
