import 'place.dart';
import 'route.dart';

/// Transport mode for travel between stops
enum TravelMode { walking, transit, driving }

/// Travel segment between two stops
class TravelSegment {
  final TravelMode mode;
  final int durationMinutes;
  final double? distanceKm;
  final String? transitLine;

  TravelSegment({
    required this.mode,
    required this.durationMinutes,
    this.distanceKm,
    this.transitLine,
  });

  factory TravelSegment.fromJson(Map<String, dynamic> json) {
    return TravelSegment(
      mode: _parseTravelMode(json['mode'] as String?),
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      transitLine: json['transit_line'] as String?,
    );
  }

  static TravelMode _parseTravelMode(String? mode) {
    switch (mode?.toLowerCase()) {
      case 'transit':
      case 'bus':
        return TravelMode.transit;
      case 'driving':
      case 'car':
        return TravelMode.driving;
      default:
        return TravelMode.walking;
    }
  }

  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        'duration_minutes': durationMinutes,
        if (distanceKm != null) 'distance_km': distanceKm,
        if (transitLine != null) 'transit_line': transitLine,
      };

  String get formattedDuration {
    if (durationMinutes < 60) {
      return '$durationMinutes dk';
    }
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (mins == 0) {
      return '$hours sa';
    }
    return '$hours sa $mins dk';
  }

  String get modeLabel {
    switch (mode) {
      case TravelMode.transit:
        return transitLine != null ? '$transitLine' : 'otobüs';
      case TravelMode.driving:
        return 'araç';
      case TravelMode.walking:
        return 'yürüyüş';
    }
  }
}

/// A stop in the route itinerary
class RouteStop {
  final int order;
  final String placeId;
  final String name;
  final String? description;
  final int durationMinutes;
  final double? rating;
  final String? category;
  final String? photoUrl;
  final Location? location;
  final TravelSegment? travelToNext;

  RouteStop({
    required this.order,
    required this.placeId,
    required this.name,
    this.description,
    required this.durationMinutes,
    this.rating,
    this.category,
    this.photoUrl,
    this.location,
    this.travelToNext,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      order: json['order'] as int,
      placeId: json['place_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      durationMinutes: json['duration_minutes'] as int? ?? 30,
      rating: (json['rating'] as num?)?.toDouble(),
      category: json['category'] as String?,
      photoUrl: json['photo_url'] as String?,
      location: json['location'] != null
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      travelToNext: json['travel_to_next'] != null
          ? TravelSegment.fromJson(json['travel_to_next'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'order': order,
        'place_id': placeId,
        'name': name,
        if (description != null) 'description': description,
        'duration_minutes': durationMinutes,
        if (rating != null) 'rating': rating,
        if (category != null) 'category': category,
        if (photoUrl != null) 'photo_url': photoUrl,
        if (location != null) 'location': location!.toJson(),
        if (travelToNext != null) 'travel_to_next': travelToNext!.toJson(),
      };

  String get formattedDuration {
    if (durationMinutes < 60) {
      return '$durationMinutes dk';
    }
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (mins == 0) {
      return '$hours sa';
    }
    return '$hours sa $mins dk';
  }
}

/// AI-generated route result
class RouteResult {
  final String? routeId;
  final String title;
  final String? subtitle;
  final String? description;
  final List<String> region;
  final double totalDistanceKm;
  final double totalDurationHours;
  final List<RouteStop> stops;
  final String transportType;
  final DateTime? createdAt;

  RouteResult({
    this.routeId,
    required this.title,
    this.subtitle,
    this.description,
    required this.region,
    required this.totalDistanceKm,
    required this.totalDurationHours,
    required this.stops,
    required this.transportType,
    this.createdAt,
  });

  factory RouteResult.fromJson(Map<String, dynamic> json) {
    return RouteResult(
      routeId: json['route_id'] as String?,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      region: (json['region'] as List<dynamic>?)?.cast<String>() ?? [],
      totalDistanceKm: (json['total_distance_km'] as num?)?.toDouble() ?? 0,
      totalDurationHours: (json['total_duration_hours'] as num?)?.toDouble() ?? 0,
      stops: (json['stops'] as List<dynamic>?)
              ?.map((s) => RouteStop.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      transportType: json['transport_type'] as String? ?? 'walking',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert TravelRoute (backend model) to RouteResult (UI model)
  factory RouteResult.fromTravelRoute(TravelRoute travelRoute) {
    // Convert RoutePlace to RouteStop
    final stops = travelRoute.places.map((place) {
      // Get first photo URL if available
      String? photoUrl;
      if (place.placeDetails != null && place.placeDetails!.photos.isNotEmpty) {
        photoUrl = place.placeDetails!.photos.first.url;
      }

      return RouteStop(
        order: place.order,
        placeId: place.placeId,
        name: place.placeDetails?.name ?? 'Unknown Place',
        description: place.notes,
        durationMinutes: place.durationMinutes,
        rating: place.placeDetails?.rating,
        category: place.placeDetails?.category,
        photoUrl: photoUrl,
        location: place.placeDetails?.location,
        travelToNext: place.travelToNext != null
            ? TravelSegment(
                mode: _convertTransportType(travelRoute.transportType),
                durationMinutes: place.travelToNext!.durationMinutes,
                distanceKm: place.travelToNext!.distanceKm,
              )
            : null,
      );
    }).toList();

    // Calculate total distance from travel segments
    double totalDistanceKm = 0;
    for (final stop in stops) {
      if (stop.travelToNext != null && stop.travelToNext!.distanceKm != null) {
        totalDistanceKm += stop.travelToNext!.distanceKm!;
      }
    }

    return RouteResult(
      routeId: travelRoute.routeId,
      title: travelRoute.title,
      subtitle: null, // Not in TravelRoute
      description: travelRoute.description ?? '',
      region: travelRoute.region,
      totalDistanceKm: totalDistanceKm,
      totalDurationHours: travelRoute.durationHours,
      stops: stops,
      transportType: travelRoute.transportType.name,
      createdAt: travelRoute.createdAt,
    );
  }

  /// Convert TransportType enum to TravelMode enum
  static TravelMode _convertTransportType(TransportType type) {
    switch (type) {
      case TransportType.driving:
        return TravelMode.driving;
      case TransportType.transit:
        return TravelMode.transit;
      case TransportType.walking:
        return TravelMode.walking;
    }
  }

  Map<String, dynamic> toJson() => {
        if (routeId != null) 'route_id': routeId,
        'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        if (description != null) 'description': description,
        'region': region,
        'total_distance_km': totalDistanceKm,
        'total_duration_hours': totalDurationHours,
        'stops': stops.map((s) => s.toJson()).toList(),
        'transport_type': transportType,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  int get stopsCount => stops.length;

  String get formattedDistance {
    if (totalDistanceKm < 1) {
      return '${(totalDistanceKm * 1000).round()} m';
    }
    return '${totalDistanceKm.toStringAsFixed(1)} km';
  }

  String get formattedDuration {
    if (totalDurationHours < 1) {
      return '${(totalDurationHours * 60).round()} dk';
    }
    final hours = totalDurationHours.floor();
    final mins = ((totalDurationHours - hours) * 60).round();
    if (mins == 0) {
      return '$hours sa';
    }
    return '$hours.$mins sa';
  }

  String get regionDisplay {
    if (region.isEmpty) return '';
    return region.join(', ');
  }

  /// Creates sample data for development/preview
  /// Uses real coordinates from Üsküdar district, Istanbul
  static RouteResult sampleData() {
    return RouteResult(
      routeId: 'sample-route-001',
      title: 'Your Itinerary',
      subtitle: 'Day 1 - Asian Side',
      region: ['Uskudar'],
      totalDistanceKm: 4.2,
      totalDurationHours: 3.5,
      transportType: 'walking',
      stops: [
        RouteStop(
          order: 1,
          placeId: 'ChIJH5mjvYy5yhQRqC6bYV5FgCg',
          name: 'Uskudar Square',
          description: 'Historic ferry landing with beautiful mosques and sea views.',
          durationMinutes: 30,
          rating: 4.5,
          category: 'attraction',
          photoUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB64iZ3cPMNRAOoPOhuT9kXvCb5hD5H_0Pp2trZ5dkDvs3pezOuEk2JohCuGmuGJ1_L0sZDWEQYsBDRs4nwxoYdQXCvuxjgaaXo-XC8gooxMVTvwyLGliYSwpWgm_8wHzLFvheOicvD_tTsLrMvDFbKSF0PzgmfOyiQ1GBJ-kSxXIC20Qfey-MrQNhnWsZd0LSpcj0FIbI8aiq-GAvMCroR6Md8kqFW4dK3d2fNnm4gopS-BDigzwWS8sIe3AJZbUmio_dM6fDrxZix',
          // Üsküdar Meydanı - real coordinates
          location: Location(lat: 41.0262, lng: 29.0159),
          travelToNext: TravelSegment(
            mode: TravelMode.walking,
            durationMinutes: 15,
            distanceKm: 0.8,
          ),
        ),
        RouteStop(
          order: 2,
          placeId: 'ChIJYVJYrpG5yhQR3UbL7b-WNkk',
          name: 'Fethi Pasa Korusu',
          description: 'Scenic park offering panoramic views of the Bosphorus.',
          durationMinutes: 60,
          rating: 4.7,
          category: 'park',
          photoUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBrRZS4L3KpOWghzm7-nj0IAQTWQftBJYFJgmqP9svgpOj0aBFlq9vLELv0QqL5F0_6odkipGS6OYZbGHLBQ1hUe4_1o5-cZFGTHAPJ0Dixa5F8TjUVfqamPcP0qr0zu5rNRvv9_FF1wtHZgU93Ip-hnS9x1HWGUJFL594IbUIUDABNzoCzd2U0CnJzjQI6bNXVgy7xy4JASOdcRwqSeLnY_JUA3mXfOuqEBJeYB-ySia5jCwIeqpIGc6ogxUHsLJhSuxlv8TXcrc9i',
          // Fethi Paşa Korusu - real coordinates
          location: Location(lat: 41.0289, lng: 29.0234),
          travelToNext: TravelSegment(
            mode: TravelMode.transit,
            durationMinutes: 10,
            distanceKm: 1.2,
            transitLine: 'Bus 15',
          ),
        ),
        RouteStop(
          order: 3,
          placeId: 'ChIJYxzDCYu5yhQRVHn7nHJwqlI',
          name: 'Kuzguncuk',
          description: 'Charming neighborhood with colorful wooden houses.',
          durationMinutes: 45,
          rating: 4.6,
          category: 'historical',
          photoUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAYNHZ4tsIOMJngokEv1-p5e0n8uIcncE6NdPOh0gTcQGfQHnh43YWBNZuQn45IFn-LmNoTRozldUzl3vJknUuFtj-5rtYZFc8I_Tqj8hTUinsOlR_D7swLxDs7_kJKqNakFoA78fgkGapK6O1voLhkxYR1uWznzk_ZWtTwgBadQdPGBQGOzSURfG_utfsOuiCpCRYS8a-Fc5UqVzWwjzyHGBqI7oWByUB3EaNQhLT33yOIMHF79Zs9uyi0-C9N3hVQ2cG-NLMBwOEi',
          // Kuzguncuk neighborhood center - real coordinates
          location: Location(lat: 41.0340, lng: 29.0280),
          travelToNext: TravelSegment(
            mode: TravelMode.walking,
            durationMinutes: 20,
            distanceKm: 1.5,
          ),
        ),
        RouteStop(
          order: 4,
          placeId: 'ChIJG-sZ0Im5yhQRbKkOLxT_W2E',
          name: 'Beylerbeyi Palace',
          description: 'Imperial summer residence with stunning Ottoman architecture.',
          durationMinutes: 60,
          rating: 4.8,
          category: 'museum',
          photoUrl: null,
          // Beylerbeyi Sarayı - real coordinates
          location: Location(lat: 41.0428, lng: 29.0393),
          travelToNext: TravelSegment(
            mode: TravelMode.transit,
            durationMinutes: 15,
            distanceKm: 2.5,
            transitLine: 'Bus 15F',
          ),
        ),
        RouteStop(
          order: 5,
          placeId: 'ChIJnzPQJpe4yhQRpMxr7K8PvSo',
          name: 'Camlica Mosque',
          description: "Turkey's largest mosque with panoramic city views.",
          durationMinutes: 45,
          rating: 4.9,
          category: 'mosque',
          photoUrl: null,
          // Çamlıca Camii - real coordinates
          location: Location(lat: 41.0275, lng: 29.0710),
          travelToNext: null,
        ),
      ],
    );
  }
}
