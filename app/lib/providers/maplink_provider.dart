import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/maplink.dart';
import '../services/maplink_service.dart';
import 'auth_provider.dart';

/// MapLink service singleton
final mapLinkServiceProvider = Provider<MapLinkService>((ref) {
  return MapLinkService();
});

/// State for Google Maps link generation
class GoogleMapsLinkState {
  final bool isLoading;
  final GoogleMapsLinkResponse? response;
  final String? error;

  const GoogleMapsLinkState({
    this.isLoading = false,
    this.response,
    this.error,
  });

  GoogleMapsLinkState copyWith({
    bool? isLoading,
    GoogleMapsLinkResponse? response,
    String? error,
  }) {
    return GoogleMapsLinkState(
      isLoading: isLoading ?? this.isLoading,
      response: response ?? this.response,
      error: error,
    );
  }
}

/// Provider for Google Maps link generation
final googleMapsLinkProvider =
    StateNotifierProvider<GoogleMapsLinkNotifier, GoogleMapsLinkState>((ref) {
      return GoogleMapsLinkNotifier(ref);
    });

class GoogleMapsLinkNotifier extends StateNotifier<GoogleMapsLinkState> {
  final Ref _ref;

  GoogleMapsLinkNotifier(this._ref) : super(const GoogleMapsLinkState());

  MapLinkService get _mapLinkService => _ref.read(mapLinkServiceProvider);

  /// Generate Google Maps deep link for given places
  Future<GoogleMapsLinkResponse?> generateLink({
    required List<RoutePlaceMaplink> places,
    TravelMode travelMode = TravelMode.walking,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get auth token
      final authService = _ref.read(authServiceProvider);
      final token = await authService.getIdToken();

      if (token != null) {
        _mapLinkService.setAuthToken(token);
      }

      final request = GoogleMapsLinkRequest(
        places: places,
        travelMode: travelMode,
      );

      final response = await _mapLinkService.generateGoogleMapsLink(request);
      state = state.copyWith(isLoading: false, response: response);
      return response;
    } on GoogleMapsException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Clear the current state
  void clear() {
    state = const GoogleMapsLinkState();
  }
}
