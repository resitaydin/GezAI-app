class AppConstants {
  AppConstants._();

  static const String appName = 'GezAI';
  static const String appTagline = 'Discover Üsküdar with AI';

  // API
  static const String apiBaseUrl = 'API_BASE_URL';

  // Route constraints
  static const int minRoutePlaces = 2;
  static const int maxRoutePlaces = 10;

  // Transport modes
  static const String walkingMode = 'walking';
  static const String drivingMode = 'driving';
  static const String transitMode = 'transit';

  // Place categories
  static const List<String> placeCategories = [
    'mosque',
    'museum',
    'park',
    'restaurant',
    'cafe',
    'attraction',
    'historical',
    'poi',
    'other',
  ];
}
