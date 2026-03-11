import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/route_model.dart';
import '../services/saved_route_service.dart';
import 'auth_provider.dart';

/// Saved route service singleton
final savedRouteServiceProvider = Provider<SavedRouteService>((ref) {
  return SavedRouteService();
});

/// Provider for fetching saved routes list
final savedRoutesProvider =
    AsyncNotifierProvider<SavedRoutesNotifier, List<SavedRouteListItem>>(
      SavedRoutesNotifier.new,
    );

/// Provider for fetching a single saved route details
final savedRouteDetailProvider =
    FutureProvider.family<SavedRouteResponse, String>((
      ref,
      savedRouteId,
    ) async {
      final authService = ref.read(authServiceProvider);
      final savedRouteService = ref.read(savedRouteServiceProvider);

      final token = await authService.getIdToken();
      if (token == null) {
        throw SavedRouteException('Not authenticated');
      }

      savedRouteService.setAuthToken(token);
      return savedRouteService.getSavedRoute(savedRouteId);
    });

class SavedRoutesNotifier extends AsyncNotifier<List<SavedRouteListItem>> {
  @override
  Future<List<SavedRouteListItem>> build() async {
    return _fetchSavedRoutes();
  }

  Future<List<SavedRouteListItem>> _fetchSavedRoutes() async {
    final authService = ref.read(authServiceProvider);
    final savedRouteService = ref.read(savedRouteServiceProvider);

    // Get the auth token
    final token = await authService.getIdToken();
    if (token == null) {
      throw SavedRouteException('Not authenticated');
    }

    // Set the token on the service
    savedRouteService.setAuthToken(token);

    // Fetch saved routes
    final response = await savedRouteService.listSavedRoutes();

    // Sort by savedAt descending (newest first)
    final sortedRoutes = response.routes.toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));

    return sortedRoutes;
  }

  /// Refresh the saved routes list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSavedRoutes());
  }

  /// Delete a saved route with optimistic UI update
  Future<void> deleteSavedRoute(String savedRouteId) async {
    final currentList = state.valueOrNull;
    if (currentList == null) return;

    // Optimistic update - remove from UI immediately
    final updatedList = currentList
        .where((item) => item.savedRouteId != savedRouteId)
        .toList();
    state = AsyncValue.data(updatedList);

    try {
      final authService = ref.read(authServiceProvider);
      final savedRouteService = ref.read(savedRouteServiceProvider);

      final token = await authService.getIdToken();
      if (token == null) {
        throw SavedRouteException('Not authenticated');
      }

      savedRouteService.setAuthToken(token);
      await savedRouteService.deleteSavedRoute(savedRouteId);
      // Success - UI already updated
    } catch (e) {
      // Rollback on failure - restore original list
      state = AsyncValue.data(currentList);
      rethrow;
    }
  }

  /// Save a route for the current user - OPTIMIZED: no full refresh
  Future<SavedRouteResponse> saveRoute({
    required String routeId,
    required String customTitle,
    String? customNotes,
    DateTime? plannedDate,
    String? plannedStartTime,
    // Optional route info for optimistic update
    int? placesCount,
    double? durationHours,
    String? transportType,
    List<String>? region,
    String? thumbnailUrl,
  }) async {
    final authService = ref.read(authServiceProvider);
    final savedRouteService = ref.read(savedRouteServiceProvider);

    final token = await authService.getIdToken();
    if (token == null) {
      throw SavedRouteException('Not authenticated');
    }

    savedRouteService.setAuthToken(token);

    final data = SavedRouteCreate(
      routeId: routeId,
      customTitle: customTitle,
      customNotes: customNotes,
      plannedDate: plannedDate,
      plannedStartTime: plannedStartTime,
    );

    final response = await savedRouteService.saveRoute(data);

    // Add to list directly instead of full refresh
    final currentList = state.valueOrNull ?? [];
    final newItem = SavedRouteListItem(
      savedRouteId: response.savedRouteId,
      routeId: response.routeId,
      displayTitle: response.displayTitle,
      placesCount: placesCount ?? response.route.places.length,
      durationHours: durationHours ?? response.route.durationHours,
      transportType: transportType ?? response.route.transportType,
      region: region ?? response.route.region,
      thumbnailUrl: thumbnailUrl ?? response.route.places.firstOrNull?.photoUrl,
      plannedDate: plannedDate,
      plannedStartTime: plannedStartTime,
      savedAt: response.savedAt,
    );
    state = AsyncValue.data([newItem, ...currentList]);

    return response;
  }

  /// Check if a route is already saved by route ID
  bool isRouteSaved(String routeId) {
    final currentState = state.valueOrNull;
    if (currentState == null) return false;
    return currentState.any((item) => item.routeId == routeId);
  }

  /// Get saved route ID by route ID (for deletion)
  String? getSavedRouteId(String routeId) {
    final currentState = state.valueOrNull;
    if (currentState == null) return null;
    try {
      return currentState.firstWhere((item) => item.routeId == routeId).savedRouteId;
    } catch (_) {
      return null;
    }
  }
}
