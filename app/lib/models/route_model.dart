import 'place.dart';

/// Request model for creating a saved route
class SavedRouteCreate {
  final String routeId;
  final String customTitle;
  final String? customNotes;
  final DateTime? plannedDate;
  final String? plannedStartTime;

  SavedRouteCreate({
    required this.routeId,
    required this.customTitle,
    this.customNotes,
    this.plannedDate,
    this.plannedStartTime,
  });

  Map<String, dynamic> toJson() => {
        'route_id': routeId,
        'custom_title': customTitle,
        if (customNotes != null) 'custom_notes': customNotes,
        if (plannedDate != null)
          'planned_date': plannedDate!.toIso8601String().split('T').first,
        if (plannedStartTime != null) 'planned_start_time': plannedStartTime,
      };
}

/// Request model for updating a saved route
class SavedRouteUpdate {
  final String? customTitle;
  final String? customNotes;
  final DateTime? plannedDate;
  final String? plannedStartTime;
  final int? userRating;
  final String? userReview;

  SavedRouteUpdate({
    this.customTitle,
    this.customNotes,
    this.plannedDate,
    this.plannedStartTime,
    this.userRating,
    this.userReview,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (customTitle != null) map['custom_title'] = customTitle;
    if (customNotes != null) map['custom_notes'] = customNotes;
    if (plannedDate != null) {
      map['planned_date'] = plannedDate!.toIso8601String().split('T').first;
    }
    if (plannedStartTime != null) map['planned_start_time'] = plannedStartTime;
    if (userRating != null) map['user_rating'] = userRating;
    if (userReview != null) map['user_review'] = userReview;
    return map;
  }
}

/// Travel information between two places
class TravelToNext {
  final double? distanceKm;
  final int? durationMinutes;
  final String? polyline;

  TravelToNext({
    this.distanceKm,
    this.durationMinutes,
    this.polyline,
  });

  factory TravelToNext.fromJson(Map<String, dynamic> json) {
    return TravelToNext(
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      durationMinutes: json['duration_minutes'] as int?,
      polyline: json['polyline'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (distanceKm != null) 'distance_km': distanceKm,
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
        if (polyline != null) 'polyline': polyline,
      };
}

/// Place within a route
class PlaceInRoute {
  final String placeId;
  final int order;
  final String name;
  final String? nameEn;
  final Location location;
  final String formattedAddress;
  final String? category;
  final String? photoUrl;
  final int? durationMinutes;
  final String? notes;
  final String? notesEn;
  final TravelToNext? travelToNext;

  PlaceInRoute({
    required this.placeId,
    required this.order,
    required this.name,
    this.nameEn,
    required this.location,
    required this.formattedAddress,
    this.category,
    this.photoUrl,
    this.durationMinutes,
    this.notes,
    this.notesEn,
    this.travelToNext,
  });

  factory PlaceInRoute.fromJson(Map<String, dynamic> json) {
    return PlaceInRoute(
      placeId: json['place_id'] as String,
      order: json['order'] as int,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      formattedAddress: json['formatted_address'] as String,
      category: json['category'] as String?,
      photoUrl: json['photo_url'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      notes: json['notes'] as String?,
      notesEn: json['notes_en'] as String?,
      travelToNext: json['travel_to_next'] != null
          ? TravelToNext.fromJson(json['travel_to_next'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'place_id': placeId,
        'order': order,
        'name': name,
        if (nameEn != null) 'name_en': nameEn,
        'location': location.toJson(),
        'formatted_address': formattedAddress,
        if (category != null) 'category': category,
        if (photoUrl != null) 'photo_url': photoUrl,
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
        if (notes != null) 'notes': notes,
        if (notesEn != null) 'notes_en': notesEn,
        if (travelToNext != null) 'travel_to_next': travelToNext!.toJson(),
      };
}

/// Route detail model
class RouteDetail {
  final String routeId;
  final String title;
  final String? titleEn;
  final String? description;
  final String? descriptionEn;
  final List<String> region;
  final double durationHours;
  final String transportType;
  final double? totalDistanceKm;
  final List<String> categories;
  final List<String> moodTags;
  final String? bestTime;
  final List<PlaceInRoute> places;
  final Map<String, dynamic>? summary;
  final bool isFeatured;
  final DateTime? createdAt;

  RouteDetail({
    required this.routeId,
    required this.title,
    this.titleEn,
    this.description,
    this.descriptionEn,
    required this.region,
    required this.durationHours,
    required this.transportType,
    this.totalDistanceKm,
    this.categories = const [],
    this.moodTags = const [],
    this.bestTime,
    this.places = const [],
    this.summary,
    this.isFeatured = false,
    this.createdAt,
  });

  factory RouteDetail.fromJson(Map<String, dynamic> json) {
    return RouteDetail(
      routeId: json['route_id'] as String,
      title: json['title'] as String,
      titleEn: json['title_en'] as String?,
      description: json['description'] as String?,
      descriptionEn: json['description_en'] as String?,
      region: (json['region'] as List<dynamic>).cast<String>(),
      durationHours: (json['duration_hours'] as num).toDouble(),
      transportType: json['transport_type'] as String,
      totalDistanceKm: (json['total_distance_km'] as num?)?.toDouble(),
      categories: (json['categories'] as List<dynamic>?)?.cast<String>() ?? [],
      moodTags: (json['mood_tags'] as List<dynamic>?)?.cast<String>() ?? [],
      bestTime: json['best_time'] as String?,
      places: (json['places'] as List<dynamic>?)
              ?.map((p) => PlaceInRoute.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      summary: json['summary'] as Map<String, dynamic>?,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'route_id': routeId,
        'title': title,
        if (titleEn != null) 'title_en': titleEn,
        if (description != null) 'description': description,
        if (descriptionEn != null) 'description_en': descriptionEn,
        'region': region,
        'duration_hours': durationHours,
        'transport_type': transportType,
        if (totalDistanceKm != null) 'total_distance_km': totalDistanceKm,
        'categories': categories,
        'mood_tags': moodTags,
        if (bestTime != null) 'best_time': bestTime,
        'places': places.map((p) => p.toJson()).toList(),
        if (summary != null) 'summary': summary,
        'is_featured': isFeatured,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  int get placesCount => places.length;
}

/// Full saved route response model
class SavedRouteResponse {
  final String savedRouteId;
  final String userId;
  final String routeId;
  final RouteDetail route;
  final String? customTitle;
  final String? customNotes;
  final DateTime? plannedDate;
  final String? plannedStartTime;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? userRating;
  final String? userReview;
  final DateTime savedAt;
  final DateTime updatedAt;
  final String displayTitle;

  SavedRouteResponse({
    required this.savedRouteId,
    required this.userId,
    required this.routeId,
    required this.route,
    this.customTitle,
    this.customNotes,
    this.plannedDate,
    this.plannedStartTime,
    this.startedAt,
    this.completedAt,
    this.userRating,
    this.userReview,
    required this.savedAt,
    required this.updatedAt,
    required this.displayTitle,
  });

  factory SavedRouteResponse.fromJson(Map<String, dynamic> json) {
    return SavedRouteResponse(
      savedRouteId: json['saved_route_id'] as String,
      userId: json['user_id'] as String,
      routeId: json['route_id'] as String,
      route: RouteDetail.fromJson(json['route'] as Map<String, dynamic>),
      customTitle: json['custom_title'] as String?,
      customNotes: json['custom_notes'] as String?,
      plannedDate: json['planned_date'] != null
          ? DateTime.parse(json['planned_date'] as String)
          : null,
      plannedStartTime: json['planned_start_time'] as String?,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      userRating: json['user_rating'] as int?,
      userReview: json['user_review'] as String?,
      savedAt: DateTime.parse(json['saved_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      displayTitle: json['display_title'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'saved_route_id': savedRouteId,
        'user_id': userId,
        'route_id': routeId,
        'route': route.toJson(),
        if (customTitle != null) 'custom_title': customTitle,
        if (customNotes != null) 'custom_notes': customNotes,
        if (plannedDate != null)
          'planned_date': plannedDate!.toIso8601String().split('T').first,
        if (plannedStartTime != null) 'planned_start_time': plannedStartTime,
        if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
        if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
        if (userRating != null) 'user_rating': userRating,
        if (userReview != null) 'user_review': userReview,
        'saved_at': savedAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'display_title': displayTitle,
      };

  /// Formatted duration string for display
  String get formattedDuration {
    final hours = route.durationHours;
    if (hours < 1) {
      return '${(hours * 60).round()} min';
    }
    return '${hours.toStringAsFixed(1)} Hours';
  }

  /// Formatted planned date for display
  String get formattedPlannedDate {
    if (plannedDate == null) return 'Not planned';
    return '${plannedDate!.day}/${plannedDate!.month}/${plannedDate!.year}';
  }

  /// Formatted saved date for display
  String get formattedSavedDate {
    return '${savedAt.day}/${savedAt.month}/${savedAt.year}';
  }

  /// Region display string
  String get regionDisplay {
    if (route.region.isEmpty) return '';
    return route.region.join(', ');
  }
}

/// Saved route list item (light version)
class SavedRouteListItem {
  final String savedRouteId;
  final String routeId;
  final String displayTitle;
  final int placesCount;
  final double? durationHours;
  final String? transportType;
  final List<String>? region;
  final String? thumbnailUrl;
  final DateTime? plannedDate;
  final String? plannedStartTime;
  final DateTime savedAt;

  SavedRouteListItem({
    required this.savedRouteId,
    required this.routeId,
    required this.displayTitle,
    required this.placesCount,
    this.durationHours,
    this.transportType,
    this.region,
    this.thumbnailUrl,
    this.plannedDate,
    this.plannedStartTime,
    required this.savedAt,
  });

  factory SavedRouteListItem.fromJson(Map<String, dynamic> json) {
    return SavedRouteListItem(
      savedRouteId: json['saved_route_id'] as String,
      routeId: json['route_id'] as String,
      displayTitle: json['display_title'] as String,
      placesCount: json['places_count'] as int,
      durationHours: (json['duration_hours'] as num?)?.toDouble(),
      transportType: json['transport_type'] as String?,
      region: json['region'] != null
          ? (json['region'] as List<dynamic>).cast<String>()
          : null,
      thumbnailUrl: json['thumbnail_url'] as String?,
      plannedDate: json['planned_date'] != null
          ? DateTime.parse(json['planned_date'] as String)
          : null,
      plannedStartTime: json['planned_start_time'] as String?,
      savedAt: DateTime.parse(json['saved_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'saved_route_id': savedRouteId,
        'route_id': routeId,
        'display_title': displayTitle,
        'places_count': placesCount,
        if (durationHours != null) 'duration_hours': durationHours,
        if (transportType != null) 'transport_type': transportType,
        if (region != null) 'region': region,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
        if (plannedDate != null)
          'planned_date': plannedDate!.toIso8601String().split('T').first,
        if (plannedStartTime != null) 'planned_start_time': plannedStartTime,
        'saved_at': savedAt.toIso8601String(),
      };

  /// Formatted duration string for display
  String get formattedDuration {
    if (durationHours == null) return '-';
    if (durationHours! < 1) {
      return '${(durationHours! * 60).round()} min';
    }
    return '${durationHours!.toStringAsFixed(1)} Hours';
  }

  /// Formatted date string for display
  String get formattedPlannedDate {
    if (plannedDate == null) return 'Not planned';
    return '${plannedDate!.day}/${plannedDate!.month}/${plannedDate!.year}';
  }

  /// Formatted saved date for display
  String get formattedSavedDate {
    return '${savedAt.day}/${savedAt.month}/${savedAt.year}';
  }

  /// Region display string
  String get regionDisplay {
    if (region == null || region!.isEmpty) return '';
    return region!.join(', ');
  }
}

/// Response model for list saved routes endpoint
class SavedRouteListResponse {
  final List<SavedRouteListItem> routes;
  final int total;

  SavedRouteListResponse({
    required this.routes,
    required this.total,
  });

  factory SavedRouteListResponse.fromJson(Map<String, dynamic> json) {
    return SavedRouteListResponse(
      routes: (json['routes'] as List<dynamic>)
          .map((r) => SavedRouteListItem.fromJson(r as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'routes': routes.map((r) => r.toJson()).toList(),
        'total': total,
      };

  bool get isEmpty => routes.isEmpty;
  bool get isNotEmpty => routes.isNotEmpty;
}