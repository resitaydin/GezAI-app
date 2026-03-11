import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/advice_route.dart';
import '../models/route_result.dart';
import '../services/api_service.dart';

/// API service singleton for advice routes
final _apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Provider for fetching advice/curated routes list
final adviceRoutesProvider =
    AsyncNotifierProvider<AdviceRoutesNotifier, List<AdviceRouteListItem>>(
      AdviceRoutesNotifier.new,
    );

/// Provider for fetching a single advice route detail
/// Uses keepAlive to cache route details after first fetch
final adviceRouteDetailProvider =
    FutureProvider.family<AdviceRouteResponse, String>((
      ref,
      adviceRouteId,
    ) async {
      // Keep this provider alive to cache route details
      ref.keepAlive();

      final apiService = ref.read(_apiServiceProvider);
      return apiService.getAdviceRoute(adviceRouteId);
    });

/// State for selected advice route (for navigation)
class AdviceRouteSelectionState {
  final bool isLoading;
  final RouteResult? routeResult;
  final String? error;

  const AdviceRouteSelectionState({
    this.isLoading = false,
    this.routeResult,
    this.error,
  });

  AdviceRouteSelectionState copyWith({
    bool? isLoading,
    RouteResult? routeResult,
    String? error,
    bool clearRouteResult = false,
    bool clearError = false,
  }) {
    return AdviceRouteSelectionState(
      isLoading: isLoading ?? this.isLoading,
      routeResult: clearRouteResult ? null : (routeResult ?? this.routeResult),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifier for advice route selection (handles loading and navigation)
class AdviceRouteSelectionNotifier extends Notifier<AdviceRouteSelectionState> {
  @override
  AdviceRouteSelectionState build() {
    return const AdviceRouteSelectionState();
  }

  /// Fetch advice route detail and convert to RouteResult for navigation
  Future<RouteResult?> selectAdviceRoute(String adviceRouteId) async {
    state = state.copyWith(isLoading: true, clearError: true, clearRouteResult: true);

    try {
      final apiService = ref.read(_apiServiceProvider);
      final response = await apiService.getAdviceRoute(adviceRouteId);
      final routeResult = response.toRouteResult();

      state = state.copyWith(
        isLoading: false,
        routeResult: routeResult,
      );

      return routeResult;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  void clearSelection() {
    state = const AdviceRouteSelectionState();
  }
}

/// Provider for advice route selection state
final adviceRouteSelectionProvider =
    NotifierProvider<AdviceRouteSelectionNotifier, AdviceRouteSelectionState>(
      AdviceRouteSelectionNotifier.new,
    );

/// Notifier for advice routes - fetches once on app launch, no manual refresh needed.
/// Advice routes are admin-curated content that rarely changes.
/// Uses keepAlive to persist data in memory and prevent re-fetching.
class AdviceRoutesNotifier extends AsyncNotifier<List<AdviceRouteListItem>> {
  @override
  Future<List<AdviceRouteListItem>> build() async {
    // Keep this provider alive so it doesn't re-fetch when navigating between tabs
    ref.keepAlive();

    final apiService = ref.read(_apiServiceProvider);
    final response = await apiService.getAdviceRoutes();
    return response.routes;
  }
}
