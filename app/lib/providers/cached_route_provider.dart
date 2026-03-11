import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/route_result.dart';
import '../services/cached_route_service.dart';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// Provider for CachedRouteService
final cachedRouteServiceProvider = Provider<CachedRouteService?>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.whenOrNull(
    data: (prefs) => CachedRouteService(prefs),
  );
});

/// State for cached route
class CachedRouteState {
  final RouteResult? route;
  final bool isLoading;
  final bool hasCheckedCache;

  const CachedRouteState({
    this.route,
    this.isLoading = true,
    this.hasCheckedCache = false,
  });

  CachedRouteState copyWith({
    RouteResult? route,
    bool? isLoading,
    bool? hasCheckedCache,
    bool clearRoute = false,
  }) {
    return CachedRouteState(
      route: clearRoute ? null : (route ?? this.route),
      isLoading: isLoading ?? this.isLoading,
      hasCheckedCache: hasCheckedCache ?? this.hasCheckedCache,
    );
  }

  bool get hasRoute => route != null;
  bool get isEmpty => !isLoading && hasCheckedCache && route == null;
}

/// Notifier for cached route state
class CachedRouteNotifier extends Notifier<CachedRouteState> {
  @override
  CachedRouteState build() {
    // Load cached route on initialization
    _loadCachedRoute();
    return const CachedRouteState();
  }

  CachedRouteService? get _service => ref.read(cachedRouteServiceProvider);

  /// Load cached route from storage
  Future<void> _loadCachedRoute() async {
    // Wait for SharedPreferences to be ready
    await ref.read(sharedPreferencesProvider.future);

    final service = _service;
    if (service == null) {
      state = state.copyWith(isLoading: false, hasCheckedCache: true);
      return;
    }

    final cachedRoute = service.getCachedRoute();
    state = CachedRouteState(
      route: cachedRoute,
      isLoading: false,
      hasCheckedCache: true,
    );
  }

  /// Cache a new route (replaces existing)
  Future<void> cacheRoute(RouteResult route) async {
    final service = _service;
    if (service == null) return;

    await service.cacheRoute(route);
    state = state.copyWith(route: route);
  }

  /// Clear the cached route
  Future<void> clearCache() async {
    final service = _service;
    if (service == null) return;

    await service.clearCache();
    state = state.copyWith(clearRoute: true);
  }

  /// Refresh from cache
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadCachedRoute();
  }
}

/// Provider for cached route state
final cachedRouteProvider = NotifierProvider<CachedRouteNotifier, CachedRouteState>(
  CachedRouteNotifier.new,
);
