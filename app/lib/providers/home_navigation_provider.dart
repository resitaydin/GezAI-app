import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/route_result.dart';

/// State for home screen navigation
class HomeNavigationState {
  final int selectedTabIndex;
  final RouteResult? selectedRouteResult;

  const HomeNavigationState({
    this.selectedTabIndex = 0,
    this.selectedRouteResult,
  });

  HomeNavigationState copyWith({
    int? selectedTabIndex,
    RouteResult? selectedRouteResult,
    bool clearRouteResult = false,
  }) {
    return HomeNavigationState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedRouteResult: clearRouteResult ? null : (selectedRouteResult ?? this.selectedRouteResult),
    );
  }
}

/// Notifier for home navigation state
class HomeNavigationNotifier extends Notifier<HomeNavigationState> {
  @override
  HomeNavigationState build() {
    return const HomeNavigationState();
  }

  void setTabIndex(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  void navigateToRouteResults(RouteResult routeResult) {
    state = HomeNavigationState(
      selectedTabIndex: 1,
      selectedRouteResult: routeResult,
    );
  }

  /// Navigate to Advice Routes tab
  void navigateToAdviceRoutes() {
    state = state.copyWith(selectedTabIndex: 2);
  }

  /// Navigate to Saved Routes tab
  void navigateToSavedRoutes() {
    state = state.copyWith(selectedTabIndex: 3);
  }

  void clearRouteResult() {
    state = state.copyWith(clearRouteResult: true);
  }
}

/// Provider for home navigation state
final homeNavigationProvider =
    NotifierProvider<HomeNavigationNotifier, HomeNavigationState>(
  HomeNavigationNotifier.new,
);
