/// LLM route generation output models.
///
/// These models mirror the backend schemas for parsing Gemini JSON responses.
library;

class LLMRouteOutput {
  final String title;
  final String titleEn;
  final String description;
  final List<String> region;
  final double durationHours;
  final String transportType;
  final List<String> categories;
  final List<String> moodTags;
  final String bestTime;
  final List<LLMPlaceOutput> places;

  LLMRouteOutput({
    required this.title,
    required this.titleEn,
    required this.description,
    required this.region,
    required this.durationHours,
    required this.transportType,
    required this.categories,
    required this.moodTags,
    required this.bestTime,
    required this.places,
  });

  factory LLMRouteOutput.fromJson(Map<String, dynamic> json) {
    return LLMRouteOutput(
      title: json['title'] as String,
      titleEn: json['title_en'] as String,
      description: json['description'] as String,
      region: List<String>.from(json['region'] ?? ['uskudar']),
      durationHours: (json['duration_hours'] as num).toDouble(),
      transportType: json['transport_type'] as String,
      categories: List<String>.from(json['categories'] ?? []),
      moodTags: List<String>.from(json['mood_tags'] ?? []),
      bestTime: json['best_time'] as String? ?? 'anytime',
      places:
          (json['places'] as List).map((p) => LLMPlaceOutput.fromJson(p)).toList(),
    );
  }

  /// Convert to RouteCreateRequest JSON for backend API
  Map<String, dynamic> toRouteCreateRequest(String? userId) {
    return {
      if (userId != null) 'user_id': userId,
      'title': title,
      'title_en': titleEn,
      'description': description,
      'region': region,
      'duration_hours': durationHours,
      'transport_type': transportType,
      'categories': categories,
      'mood_tags': moodTags,
      'best_time': bestTime,
      'places': places.map((p) => p.toJson()).toList(),
    };
  }
}

class LLMPlaceOutput {
  final String name;
  final String region;
  final int order;
  final int durationMinutes;
  final String notes;
  final LLMTravelInfo? travelToNext;

  LLMPlaceOutput({
    required this.name,
    required this.region,
    required this.order,
    required this.durationMinutes,
    required this.notes,
    this.travelToNext,
  });

  factory LLMPlaceOutput.fromJson(Map<String, dynamic> json) {
    return LLMPlaceOutput(
      name: json['name'] as String,
      region: json['region'] as String? ?? 'uskudar',
      order: json['order'] as int,
      durationMinutes: json['duration_minutes'] as int,
      notes: json['notes'] as String,
      travelToNext: json['travel_to_next'] != null
          ? LLMTravelInfo.fromJson(json['travel_to_next'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'region': region,
        'order': order,
        'duration_minutes': durationMinutes,
        'notes': notes,
        if (travelToNext != null) 'travel_to_next': travelToNext!.toJson(),
      };
}

class LLMTravelInfo {
  final double? distanceKm;
  final int? durationMinutes;

  LLMTravelInfo({this.distanceKm, this.durationMinutes});

  factory LLMTravelInfo.fromJson(Map<String, dynamic> json) {
    return LLMTravelInfo(
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      durationMinutes: json['duration_minutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (distanceKm != null) 'distance_km': distanceKm,
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
      };
}
