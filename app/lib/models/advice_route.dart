import 'route_result.dart';
import 'place.dart';

/// Model for curated/recommended advice routes (List item - lightweight)
class AdviceRouteListItem {
  final String adviceRouteId;
  final String routeId;
  final String displayTitle;
  final int placesCount;
  final double? durationHours;
  final String? transportType;
  final List<String> region;
  final String? thumbnailUrl;
  final List<String> category;
  final List<String> mood;
  final DateTime createdAt;

  AdviceRouteListItem({
    required this.adviceRouteId,
    required this.routeId,
    required this.displayTitle,
    required this.placesCount,
    this.durationHours,
    this.transportType,
    required this.region,
    this.thumbnailUrl,
    this.category = const [],
    this.mood = const [],
    required this.createdAt,
  });

  factory AdviceRouteListItem.fromJson(Map<String, dynamic> json) {
    return AdviceRouteListItem(
      adviceRouteId: json['advice_route_id'] as String,
      routeId: json['route_id'] as String,
      displayTitle: json['display_title'] as String,
      placesCount: json['places_count'] as int,
      durationHours: (json['duration_hours'] as num?)?.toDouble(),
      transportType: json['transport_type'] as String?,
      region: (json['region'] as List<dynamic>?)?.cast<String>() ?? [],
      thumbnailUrl: json['thumbnail_url'] as String?,
      category: (json['category'] as List<dynamic>?)?.cast<String>() ?? [],
      mood: (json['mood'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'advice_route_id': adviceRouteId,
        'route_id': routeId,
        'display_title': displayTitle,
        'places_count': placesCount,
        if (durationHours != null) 'duration_hours': durationHours,
        if (transportType != null) 'transport_type': transportType,
        'region': region,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
        'category': category,
        'mood': mood,
        'created_at': createdAt.toIso8601String(),
      };

  String get formattedDuration {
    if (durationHours == null) return '-';
    if (durationHours! < 1) {
      return '${(durationHours! * 60).round()} dk';
    }
    final hours = durationHours!.floor();
    final mins = ((durationHours! - hours) * 60).round();
    if (mins == 0) {
      return '$hours sa';
    }
    return '${hours} sa ${mins} dk';
  }

  String get regionDisplay {
    if (region.isEmpty) return '';
    return region.map((r) => _capitalizeFirst(r)).join(', ');
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  String get transportLabel {
    switch (transportType?.toLowerCase()) {
      case 'driving':
        return 'Araç';
      case 'transit':
        return 'Toplu Taşıma';
      default:
        return 'Yürüyüş';
    }
  }

  /// Get first two tags for display (from mood or category)
  List<String> get displayTags {
    final tags = <String>[];
    // Add mood tags first
    for (final m in mood.take(2)) {
      tags.add(_capitalizeFirst(m));
    }
    // Fill remaining with categories
    if (tags.length < 2) {
      for (final c in category.take(2 - tags.length)) {
        tags.add(_capitalizeFirst(c));
      }
    }
    return tags;
  }
}

/// Place within an advice route detail
class AdviceRoutePlace {
  final String placeId;
  final int order;
  final String name;
  final String? nameEn;
  final Location? location;
  final String? formattedAddress;
  final String? category;
  final String? photoUrl;
  final int? durationMinutes;
  final String? notes;
  final String? notesEn;
  final TravelToNextInfo? travelToNext;

  AdviceRoutePlace({
    required this.placeId,
    required this.order,
    required this.name,
    this.nameEn,
    this.location,
    this.formattedAddress,
    this.category,
    this.photoUrl,
    this.durationMinutes,
    this.notes,
    this.notesEn,
    this.travelToNext,
  });

  factory AdviceRoutePlace.fromJson(Map<String, dynamic> json) {
    return AdviceRoutePlace(
      placeId: json['place_id'] as String,
      order: json['order'] as int,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      location: json['location'] != null
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      formattedAddress: json['formatted_address'] as String?,
      category: json['category'] as String?,
      photoUrl: json['photo_url'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      notes: json['notes'] as String?,
      notesEn: json['notes_en'] as String?,
      travelToNext: json['travel_to_next'] != null
          ? TravelToNextInfo.fromJson(json['travel_to_next'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'place_id': placeId,
        'order': order,
        'name': name,
        if (nameEn != null) 'name_en': nameEn,
        if (location != null) 'location': location!.toJson(),
        if (formattedAddress != null) 'formatted_address': formattedAddress,
        if (category != null) 'category': category,
        if (photoUrl != null) 'photo_url': photoUrl,
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
        if (notes != null) 'notes': notes,
        if (notesEn != null) 'notes_en': notesEn,
        if (travelToNext != null) 'travel_to_next': travelToNext!.toJson(),
      };

  /// Convert to RouteStop for route result screen
  RouteStop toRouteStop() {
    return RouteStop(
      order: order,
      placeId: placeId,
      name: name,
      description: notes ?? notesEn,
      durationMinutes: durationMinutes ?? 30,
      category: category,
      photoUrl: photoUrl,
      location: location,
      travelToNext: travelToNext?.toTravelSegment(),
    );
  }
}

/// Travel information to next stop
class TravelToNextInfo {
  final int? durationMinutes;
  final double? distanceKm;
  final String? polyline;

  TravelToNextInfo({
    this.durationMinutes,
    this.distanceKm,
    this.polyline,
  });

  factory TravelToNextInfo.fromJson(Map<String, dynamic> json) {
    return TravelToNextInfo(
      durationMinutes: json['duration_minutes'] as int?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      polyline: json['polyline'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
        if (distanceKm != null) 'distance_km': distanceKm,
        if (polyline != null) 'polyline': polyline,
      };

  /// Convert to TravelSegment for route result
  TravelSegment toTravelSegment() {
    return TravelSegment(
      mode: TravelMode.walking, // Default, could be enhanced
      durationMinutes: durationMinutes ?? 0,
      distanceKm: distanceKm,
    );
  }
}

/// Route summary info
class AdviceRouteSummary {
  final int totalVisitMinutes;
  final int totalPlaces;
  final int totalTransportMinutes;

  AdviceRouteSummary({
    required this.totalVisitMinutes,
    required this.totalPlaces,
    required this.totalTransportMinutes,
  });

  factory AdviceRouteSummary.fromJson(Map<String, dynamic> json) {
    return AdviceRouteSummary(
      totalVisitMinutes: json['total_visit_minutes'] as int? ?? 0,
      totalPlaces: json['total_places'] as int? ?? 0,
      totalTransportMinutes: json['total_transport_minutes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_visit_minutes': totalVisitMinutes,
        'total_places': totalPlaces,
        'total_transport_minutes': totalTransportMinutes,
      };
}

/// Route detail within advice route response
class AdviceRouteDetail {
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
  final List<AdviceRoutePlace> places;
  final AdviceRouteSummary? summary;
  final bool isFeatured;
  final DateTime? createdAt;

  AdviceRouteDetail({
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

  factory AdviceRouteDetail.fromJson(Map<String, dynamic> json) {
    return AdviceRouteDetail(
      routeId: json['route_id'] as String,
      title: json['title'] as String,
      titleEn: json['title_en'] as String?,
      description: json['description'] as String?,
      descriptionEn: json['description_en'] as String?,
      region: (json['region'] as List<dynamic>?)?.cast<String>() ?? [],
      durationHours: (json['duration_hours'] as num).toDouble(),
      transportType: json['transport_type'] as String,
      totalDistanceKm: (json['total_distance_km'] as num?)?.toDouble(),
      categories: (json['categories'] as List<dynamic>?)?.cast<String>() ?? [],
      moodTags: (json['mood_tags'] as List<dynamic>?)?.cast<String>() ?? [],
      bestTime: json['best_time'] as String?,
      places: (json['places'] as List<dynamic>?)
              ?.map((p) => AdviceRoutePlace.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      summary: json['summary'] != null
          ? AdviceRouteSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
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
        if (summary != null) 'summary': summary!.toJson(),
        'is_featured': isFeatured,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  /// Convert to RouteResult for route results screen
  RouteResult toRouteResult() {
    return RouteResult(
      routeId: routeId,
      title: title,
      subtitle: titleEn,
      description: description ?? descriptionEn,
      region: region,
      totalDistanceKm: totalDistanceKm ?? 0,
      totalDurationHours: durationHours,
      stops: places.map((p) => p.toRouteStop()).toList(),
      transportType: transportType,
      createdAt: createdAt,
    );
  }
}

/// Full advice route response (with route details)
class AdviceRouteResponse {
  final String adviceRouteId;
  final String routeId;
  final AdviceRouteDetail route;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdviceRouteResponse({
    required this.adviceRouteId,
    required this.routeId,
    required this.route,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdviceRouteResponse.fromJson(Map<String, dynamic> json) {
    return AdviceRouteResponse(
      adviceRouteId: json['advice_route_id'] as String,
      routeId: json['route_id'] as String,
      route: AdviceRouteDetail.fromJson(json['route'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'advice_route_id': adviceRouteId,
        'route_id': routeId,
        'route': route.toJson(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  /// Convert to RouteResult for navigation
  RouteResult toRouteResult() => route.toRouteResult();
}

/// Response model for list advice routes endpoint
class AdviceRouteListResponse {
  final List<AdviceRouteListItem> routes;
  final int total;

  AdviceRouteListResponse({
    required this.routes,
    required this.total,
  });

  factory AdviceRouteListResponse.fromJson(Map<String, dynamic> json) {
    return AdviceRouteListResponse(
      routes: (json['routes'] as List<dynamic>)
          .map((r) => AdviceRouteListItem.fromJson(r as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );
  }

  bool get isEmpty => routes.isEmpty;
  bool get isNotEmpty => routes.isNotEmpty;
}
