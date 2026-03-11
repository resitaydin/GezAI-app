import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_provider.dart' show aiServiceProvider;

/// Parameters for place about generation
class PlaceAboutParams {
  final String name;
  final String region;

  const PlaceAboutParams({required this.name, required this.region});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceAboutParams &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          region == other.region;

  @override
  int get hashCode => name.hashCode ^ region.hashCode;
}

/// Provider for generating place about text on-demand using Firebase AI
///
/// Usage:
/// ```dart
/// final aboutAsync = ref.watch(
///   placeAboutProvider(PlaceAboutParams(name: 'Kız Kulesi', region: 'Üsküdar')),
/// );
/// ```
final placeAboutProvider =
    FutureProvider.family<String, PlaceAboutParams>((ref, params) async {
  final aiService = ref.read(aiServiceProvider);
  return aiService.generatePlaceAbout(params.name, params.region);
});

/// State notifier for caching generated place about texts
/// Maps "name|region" to the generated about text
class PlaceAboutCacheNotifier extends StateNotifier<Map<String, String>> {
  PlaceAboutCacheNotifier() : super({});

  String _key(String name, String region) => '$name|$region';

  void cacheAbout(String name, String region, String about) {
    state = {...state, _key(name, region): about};
  }

  String? getAbout(String name, String region) => state[_key(name, region)];

  bool hasAbout(String name, String region) =>
      state.containsKey(_key(name, region));

  void clear() => state = {};
}

/// Provider for place about cache
final placeAboutCacheProvider =
    StateNotifierProvider<PlaceAboutCacheNotifier, Map<String, String>>(
  (ref) => PlaceAboutCacheNotifier(),
);

/// Provider that returns cached about text or null
final cachedPlaceAboutProvider =
    Provider.family<String?, PlaceAboutParams>((ref, params) {
  final cache = ref.watch(placeAboutCacheProvider);
  final key = '${params.name}|${params.region}';
  return cache[key];
});
