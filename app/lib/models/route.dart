import 'place.dart';

class TravelToNext {
  final double distanceKm;
  final int durationMinutes;

  TravelToNext({
    required this.distanceKm,
    required this.durationMinutes,
  });

  factory TravelToNext.fromJson(Map<String, dynamic> json) {
    return TravelToNext(
      distanceKm: (json['distance_km'] as num).toDouble(),
      durationMinutes: json['duration_minutes'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'distance_km': distanceKm,
        'duration_minutes': durationMinutes,
      };
}

class RoutePlace {
  final String placeId;
  final int order;
  final int durationMinutes;
  final String? notes;
  final TravelToNext? travelToNext;
  final Place? placeDetails;

  RoutePlace({
    required this.placeId,
    required this.order,
    required this.durationMinutes,
    this.notes,
    this.travelToNext,
    this.placeDetails,
  });

  factory RoutePlace.fromJson(Map<String, dynamic> json) {
    // Backend may return place_details nested OR place data directly
    Place? placeDetails;

    if (json['place_details'] != null) {
      // Place data is nested under 'place_details'
      placeDetails = Place.fromJson(json['place_details'] as Map<String, dynamic>);
    } else if (json.containsKey('name')) {
      // Place data is embedded directly (backend /api/v1/routes/ format)
      // Construct a Place object from the embedded fields
      placeDetails = Place(
        placeId: json['place_id'] as String,
        name: json['name'] as String,
        nameEn: json['name_en'] as String?,
        location: json['location'] != null
            ? Location.fromJson(json['location'] as Map<String, dynamic>)
            : null,
        formattedAddress: json['formatted_address'] as String?,
        region: json['region'] as String?,
        city: json['city'] as String?,
        category: json['category'] as String?,
        rating: (json['rating'] as num?)?.toDouble(),
        totalRatings: json['total_ratings'] as int?,
        photos: json['photo_url'] != null
            ? [
                PlacePhoto(
                  photoReference: '',
                  url: json['photo_url'] as String,
                  width: 0,
                  height: 0,
                )
              ]
            : [],
        description: json['description'] as String?,
        about: json['about'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
      );
    }

    return RoutePlace(
      placeId: json['place_id'] as String,
      order: json['order'] as int,
      durationMinutes: json['duration_minutes'] as int? ?? 30,
      notes: json['notes'] as String?,
      travelToNext: json['travel_to_next'] != null
          ? TravelToNext.fromJson(json['travel_to_next'] as Map<String, dynamic>)
          : null,
      placeDetails: placeDetails,
    );
  }

  Map<String, dynamic> toJson() => {
        'place_id': placeId,
        'order': order,
        'duration_minutes': durationMinutes,
        'notes': notes,
        'travel_to_next': travelToNext?.toJson(),
      };
}

class RouteSummary {
  final int totalPlaces;
  final int totalTransportMinutes;
  final int totalVisitMinutes;

  RouteSummary({
    required this.totalPlaces,
    required this.totalTransportMinutes,
    required this.totalVisitMinutes,
  });

  int get totalMinutes => totalTransportMinutes + totalVisitMinutes;

  factory RouteSummary.fromJson(Map<String, dynamic> json) {
    return RouteSummary(
      totalPlaces: json['total_places'] as int,
      totalTransportMinutes: json['total_transport_minutes'] as int,
      totalVisitMinutes: json['total_visit_minutes'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_places': totalPlaces,
        'total_transport_minutes': totalTransportMinutes,
        'total_visit_minutes': totalVisitMinutes,
      };
}

enum TransportType { walking, driving, transit }

class TravelRoute {
  final String routeId;
  final String? userId;
  final String title;
  final String? description;
  final List<String> region;
  final double durationHours;
  final TransportType transportType;
  final List<RoutePlace> places;
  final RouteSummary? summary;
  final bool isFeatured;
  final DateTime createdAt;

  TravelRoute({
    required this.routeId,
    this.userId,
    required this.title,
    this.description,
    required this.region,
    required this.durationHours,
    required this.transportType,
    required this.places,
    this.summary,
    this.isFeatured = false,
    required this.createdAt,
  });

  factory TravelRoute.fromJson(Map<String, dynamic> json) {
    return TravelRoute(
      routeId: json['route_id'] as String,
      userId: json['user_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      region: (json['region'] as List<dynamic>).cast<String>(),
      durationHours: (json['duration_hours'] as num).toDouble(),
      transportType: _parseTransportType(json['transport_type'] as String),
      places: (json['places'] as List<dynamic>)
          .map((p) => RoutePlace.fromJson(p as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] != null
          ? RouteSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static TransportType _parseTransportType(String type) {
    switch (type) {
      case 'driving':
        return TransportType.driving;
      case 'transit':
        return TransportType.transit;
      default:
        return TransportType.walking;
    }
  }

  Map<String, dynamic> toJson() => {
        'route_id': routeId,
        'user_id': userId,
        'title': title,
        'description': description,
        'region': region,
        'duration_hours': durationHours,
        'transport_type': transportType.name,
        'places': places.map((p) => p.toJson()).toList(),
        'summary': summary?.toJson(),
        'is_featured': isFeatured,
        'created_at': createdAt.toIso8601String(),
      };
}

class SavedRoute {
  final String savedRouteId;
  final String userId;
  final String routeId;
  final String? customTitle;
  final String? customNotes;
  final DateTime? plannedDate;
  final double? userRating;
  final DateTime savedAt;
  final TravelRoute? route;

  SavedRoute({
    required this.savedRouteId,
    required this.userId,
    required this.routeId,
    this.customTitle,
    this.customNotes,
    this.plannedDate,
    this.userRating,
    required this.savedAt,
    this.route,
  });

  factory SavedRoute.fromJson(Map<String, dynamic> json) {
    return SavedRoute(
      savedRouteId: json['saved_route_id'] as String,
      userId: json['user_id'] as String,
      routeId: json['route_id'] as String,
      customTitle: json['custom_title'] as String?,
      customNotes: json['custom_notes'] as String?,
      plannedDate: json['planned_date'] != null
          ? DateTime.parse(json['planned_date'] as String)
          : null,
      userRating: (json['user_rating'] as num?)?.toDouble(),
      savedAt: DateTime.parse(json['saved_at'] as String),
      route: json['route'] != null
          ? TravelRoute.fromJson(json['route'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'saved_route_id': savedRouteId,
        'user_id': userId,
        'route_id': routeId,
        'custom_title': customTitle,
        'custom_notes': customNotes,
        'planned_date': plannedDate?.toIso8601String(),
        'user_rating': userRating,
        'saved_at': savedAt.toIso8601String(),
      };
}
