/// Travel mode options for Google Maps routing
enum TravelMode {
  walking('walking'),
  driving('driving'),
  transit('transit');

  const TravelMode(this.value);
  final String value;

  static TravelMode fromString(String value) {
    return TravelMode.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TravelMode.walking,
    );
  }
}

/// Represents a place in the route
class RoutePlaceMaplink {
  final String name;
  final double? lat;
  final double? lng;

  const RoutePlaceMaplink({
    required this.name,
    this.lat,
    this.lng,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    };
  }

  factory RoutePlaceMaplink.fromJson(Map<String, dynamic> json) {
    return RoutePlaceMaplink(
      name: json['name'] as String,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }
}

/// Request model for generating Google Maps link
class GoogleMapsLinkRequest {
  final List<RoutePlaceMaplink> places;
  final TravelMode travelMode;

  const GoogleMapsLinkRequest({
    required this.places,
    this.travelMode = TravelMode.walking,
  });

  Map<String, dynamic> toJson() {
    return {
      'places': places.map((p) => p.toJson()).toList(),
      'travel_mode': travelMode.value,
    };
  }

  factory GoogleMapsLinkRequest.fromJson(Map<String, dynamic> json) {
    return GoogleMapsLinkRequest(
      places: (json['places'] as List)
          .map((p) => RoutePlaceMaplink.fromJson(p as Map<String, dynamic>))
          .toList(),
      travelMode: TravelMode.fromString(json['travel_mode'] as String? ?? 'walking'),
    );
  }
}

/// Response model with Google Maps deep link
class GoogleMapsLinkResponse {
  final String googleMapsUrl;
  final TravelMode travelMode;
  final int totalStops;

  const GoogleMapsLinkResponse({
    required this.googleMapsUrl,
    required this.travelMode,
    required this.totalStops,
  });

  factory GoogleMapsLinkResponse.fromJson(Map<String, dynamic> json) {
    return GoogleMapsLinkResponse(
      googleMapsUrl: json['google_maps_url'] as String,
      travelMode: TravelMode.fromString(json['travel_mode'] as String),
      totalStops: json['total_stops'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'google_maps_url': googleMapsUrl,
      'travel_mode': travelMode.value,
      'total_stops': totalStops,
    };
  }
}
