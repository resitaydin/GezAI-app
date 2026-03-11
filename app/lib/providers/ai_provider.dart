import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/llm_route_output.dart';
import '../models/route.dart';
import '../models/route_result.dart';
import '../services/ai_service.dart';
import 'place_provider.dart' show apiServiceProvider;

/// Tracks the current phase of route generation
enum RouteGenerationPhase {
  /// Initial state, not generating
  idle,
  /// LLM is generating the route structure
  llmGenerating,
  /// Backend is processing the route (resolving places, etc.)
  backendProcessing,
  /// Route generation complete
  complete,
  /// An error occurred
  error,
}

/// Provider for Firebase AI service singleton
final aiServiceProvider = Provider<FirebaseAIService>((ref) {
  return FirebaseAIService();
});

/// State for route generation
class RouteGenerationState {
  final LLMRouteOutput? llmRoute;
  final RouteResult? finalRoute;
  final int? generationTimeMs;
  final RouteGenerationPhase phase;
  final String? error;

  const RouteGenerationState({
    this.llmRoute,
    this.finalRoute,
    this.generationTimeMs,
    this.phase = RouteGenerationPhase.idle,
    this.error,
  });

  /// Whether route generation is in progress
  bool get isLoading =>
      phase == RouteGenerationPhase.llmGenerating ||
      phase == RouteGenerationPhase.backendProcessing;

  /// Whether route generation completed successfully
  bool get isComplete => phase == RouteGenerationPhase.complete;

  /// Whether there was an error
  bool get hasError => phase == RouteGenerationPhase.error;

  RouteGenerationState copyWith({
    LLMRouteOutput? llmRoute,
    RouteResult? finalRoute,
    int? generationTimeMs,
    RouteGenerationPhase? phase,
    String? error,
    bool clearError = false,
  }) {
    return RouteGenerationState(
      llmRoute: llmRoute ?? this.llmRoute,
      finalRoute: finalRoute ?? this.finalRoute,
      generationTimeMs: generationTimeMs ?? this.generationTimeMs,
      phase: phase ?? this.phase,
      error: clearError ? null : (error ?? this.error),
    );
  }

  static const initial = RouteGenerationState();
}

/// Controller for route generation operations
class RouteGenerationController extends StateNotifier<RouteGenerationState> {
  final Ref _ref;

  RouteGenerationController(this._ref) : super(RouteGenerationState.initial);

  /// Generate a route from natural language prompt
  ///
  /// This method performs the full route generation flow:
  /// 1. Call FirebaseAIService to generate route structure (LLM)
  /// 2. Send to backend to resolve place names and enrich data
  /// 3. Return final RouteResult
  ///
  /// [prompt] User's request in Turkish
  /// [transportType] Transport mode: walking, driving, transit
  /// [maxPlaces] Maximum number of places (default 5)
  /// [userId] Optional user ID for associating the route
  Future<void> generateRoute(
    String prompt,
    String transportType, {
    int maxPlaces = 5,
    String? userId,
  }) async {
    // Phase 1: LLM Generation
    state = state.copyWith(
      phase: RouteGenerationPhase.llmGenerating,
      clearError: true,
    );

    try {
      final aiService = _ref.read(aiServiceProvider);
      final (llmResult, generationTimeMs) = await aiService.generateRoute(
        prompt,
        transportType,
        maxPlaces: maxPlaces,
      );

      state = state.copyWith(
        llmRoute: llmResult,
        generationTimeMs: generationTimeMs,
        phase: RouteGenerationPhase.backendProcessing,
      );

      // Phase 2: Backend Processing
      final apiService = _ref.read(apiServiceProvider);

      TravelRoute travelRoute;
      try {
        travelRoute = await apiService.createRoute(
          llmOutput: llmResult,
          userId: userId,
        );
      } catch (e, stackTrace) {
        //print('Error creating route in backend: $e');
        if (e is DioException) {
          // print('Response status: ${e.response?.statusCode}');
          // print('Response body: ${e.response?.data}');
        }
        //print('Stack trace: $stackTrace');
        rethrow;
      }

      // Convert TravelRoute to RouteResult for UI
      RouteResult routeResult;
      try {
        routeResult = RouteResult.fromTravelRoute(travelRoute);
      } catch (e, stackTrace) {
        //print('Error converting TravelRoute to RouteResult: $e');
        //print('Stack trace: $stackTrace');
        rethrow;
      }

      state = state.copyWith(
        finalRoute: routeResult,
        phase: RouteGenerationPhase.complete,
      );
    } on FirebaseAIException catch (e) {
      state = state.copyWith(
        phase: RouteGenerationPhase.error,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        phase: RouteGenerationPhase.error,
        error: e.toString(),
      );
    }
  }

  /// Reset the state
  void reset() {
    state = RouteGenerationState.initial;
  }

  /// Clear any error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for route generation state and controller
final routeGenerationProvider =
    StateNotifierProvider<RouteGenerationController, RouteGenerationState>(
  (ref) => RouteGenerationController(ref),
);

/// Convenience providers for specific state values
final isGeneratingRouteProvider = Provider<bool>((ref) {
  return ref.watch(routeGenerationProvider).isLoading;
});

final routeGenerationPhaseProvider = Provider<RouteGenerationPhase>((ref) {
  return ref.watch(routeGenerationProvider).phase;
});

final generatedLLMRouteProvider = Provider<LLMRouteOutput?>((ref) {
  return ref.watch(routeGenerationProvider).llmRoute;
});

final generatedRouteProvider = Provider<RouteResult?>((ref) {
  return ref.watch(routeGenerationProvider).finalRoute;
});

final routeGenerationErrorProvider = Provider<String?>((ref) {
  return ref.watch(routeGenerationProvider).error;
});
