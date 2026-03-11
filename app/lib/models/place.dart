enum SyncStatus { fresh, stale, error }

class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

class PlacePhoto {
  final String photoReference;
  final String? url;
  final int width;
  final int height;
  final String? attribution;

  PlacePhoto({
    required this.photoReference,
    this.url,
    required this.width,
    required this.height,
    this.attribution,
  });

  factory PlacePhoto.fromJson(Map<String, dynamic> json) {
    return PlacePhoto(
      photoReference: json['photo_reference'] as String,
      url: json['url'] as String?,
      width: json['width'] as int,
      height: json['height'] as int,
      attribution: json['attribution'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'photo_reference': photoReference,
        'url': url,
        'width': width,
        'height': height,
        'attribution': attribution,
      };
}

class Place {
  final String placeId;
  final String? googlePlaceId;
  final String name;
  final String? nameEn;
  final String? description;
  final String? descriptionEn;
  final Location? location;
  final String? formattedAddress;
  final String? region;
  final String? city;
  final String? category;
  final double? rating;
  final int? totalRatings;
  final List<PlacePhoto> photos;
  final String? about;
  final DateTime? googleLastSyncedAt;
  final SyncStatus googleSyncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  Place({
    required this.placeId,
    this.googlePlaceId,
    required this.name,
    this.nameEn,
    this.description,
    this.descriptionEn,
    this.location,
    this.formattedAddress,
    this.region,
    this.city,
    this.category,
    this.rating,
    this.totalRatings,
    this.photos = const [],
    this.about,
    this.googleLastSyncedAt,
    this.googleSyncStatus = SyncStatus.fresh,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeId: json['place_id'] as String,
      googlePlaceId: json['google_place_id'] as String?,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      description: json['description'] as String?,
      descriptionEn: json['description_en'] as String?,
      location: json['location'] != null
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      formattedAddress: json['formatted_address'] as String?,
      region: json['region'] as String?,
      city: json['city'] as String?,
      category: json['category'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalRatings: json['total_ratings'] as int?,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((p) => PlacePhoto.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      about: json['about'] as String?,
      googleLastSyncedAt: json['google_last_synced_at'] != null
          ? DateTime.parse(json['google_last_synced_at'] as String)
          : null,
      googleSyncStatus: _parseSyncStatus(json['google_sync_status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static SyncStatus _parseSyncStatus(String? status) {
    switch (status) {
      case 'stale':
        return SyncStatus.stale;
      case 'error':
        return SyncStatus.error;
      default:
        return SyncStatus.fresh;
    }
  }

  Map<String, dynamic> toJson() => {
        'place_id': placeId,
        'google_place_id': googlePlaceId,
        'name': name,
        'name_en': nameEn,
        'description': description,
        'description_en': descriptionEn,
        if (location != null) 'location': location!.toJson(),
        if (formattedAddress != null) 'formatted_address': formattedAddress,
        if (region != null) 'region': region,
        if (city != null) 'city': city,
        'category': category,
        'rating': rating,
        'total_ratings': totalRatings,
        'photos': photos.map((p) => p.toJson()).toList(),
        'about': about,
        'google_last_synced_at': googleLastSyncedAt?.toIso8601String(),
        'google_sync_status': googleSyncStatus.name,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
