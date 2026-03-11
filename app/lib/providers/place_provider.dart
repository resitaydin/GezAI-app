import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/place.dart';
import '../services/api_service.dart';

/// Provider for ApiService singleton
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

/// Parameters for fetching place details
class PlaceDetailParams {
  final String name;
  final String region;

  PlaceDetailParams({required this.name, required this.region});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceDetailParams &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          region == other.region;

  @override
  int get hashCode => name.hashCode ^ region.hashCode;
}

/// Provider to fetch full place details by name and region
/// Uses POST endpoint which creates/retrieves place from cache or Google API
/// Uses family modifier to create separate providers for each name+region combo
final placeDetailProvider =
    FutureProvider.family<Place, PlaceDetailParams>((ref, params) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.createOrGetPlace(
    name: params.name,
    region: params.region,
  );
});

/// Provider to fetch place details by place_id
/// Uses GET endpoint which returns place with about (generates if missing)
/// This is used for parallel prefetching on route screen
final placeByIdProvider =
    FutureProvider.family<Place, String>((ref, placeId) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getPlace(placeId);
});

/// Cache state for prefetched places
/// Maps place_id to Place object for quick access
class PlaceCacheNotifier extends StateNotifier<Map<String, Place>> {
  PlaceCacheNotifier() : super({});

  void addPlace(Place place) {
    state = {...state, place.placeId: place};
  }

  void addPlaces(List<Place> places) {
    final newState = Map<String, Place>.from(state);
    for (final place in places) {
      newState[place.placeId] = place;
    }
    state = newState;
  }

  Place? getPlace(String placeId) => state[placeId];

  bool hasPlace(String placeId) => state.containsKey(placeId);

  void clear() => state = {};
}

/// Provider for place cache
final placeCacheProvider =
    StateNotifierProvider<PlaceCacheNotifier, Map<String, Place>>(
  (ref) => PlaceCacheNotifier(),
);

/// Provider to get a cached place or null
final cachedPlaceProvider = Provider.family<Place?, String>((ref, placeId) {
  final cache = ref.watch(placeCacheProvider);
  return cache[placeId];
});
