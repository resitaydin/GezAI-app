import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/models.dart';
import '../models/advice_route.dart';
import '../models/llm_route_output.dart';

class ApiService {
  late final Dio _dio;
  String? _authToken;

  ApiService() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://192.168.1.23:8000';
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Future<Place> createOrGetPlace({
    required String name,
    required String region,
  }) async {
    final response = await _dio.post('/api/v1/places/', data: {
      'name': name,
      'region': region,
    });
    return Place.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Place> getPlace(String placeId) async {
    final response = await _dio.get('/api/v1/places/$placeId');
    return Place.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<PlacePhoto>> getPlacePhotos(String placeId) async {
    final response = await _dio.get('/api/v1/places/$placeId/photos');
    final data = response.data as Map<String, dynamic>;
    return (data['photos'] as List<dynamic>)
        .map((p) => PlacePhoto.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  Future<String> getGoogleMapsLink({
    required List<Map<String, dynamic>> places,
    required String travelMode,
  }) async {
    final response = await _dio.post('/api/v1/map_link/google-maps-link', data: {
      'places': places,
      'travel_mode': travelMode,
    });
    final data = response.data as Map<String, dynamic>;
    return data['url'] as String;
  }

  Future<TravelRoute> generateRoute({
    required String prompt,
    required String region,
    required String transportMode,
    int? maxPlaces,
  }) async {
    final response = await _dio.post('/api/v1/routes/generate', data: {
      'prompt': prompt,
      'region': region,
      'transport_mode': transportMode,
      if (maxPlaces != null) 'max_places': maxPlaces,
    });
    return TravelRoute.fromJson(response.data as Map<String, dynamic>);
  }

  /// Create a route from LLM-generated output
  ///
  /// Backend resolves place names to place_ids via Google Places API,
  /// enriches place data, and saves to Firestore.
  /// Returns TravelRoute with enriched place data.
  Future<TravelRoute> createRoute({
    required LLMRouteOutput llmOutput,
    String? userId,
  }) async {
    final response = await _dio.post(
      '/api/v1/routes/',
      data: llmOutput.toRouteCreateRequest(userId),
    );

    try {
      //print('Backend response data: ${response.data}');

      // Backend response is nested: { "route": { ... } }
      final routeData = response.data['route'] as Map<String, dynamic>;
      return TravelRoute.fromJson(routeData);
    } catch (e, stackTrace) {
      // print('Error parsing TravelRoute from JSON: $e');
      // print('Response data type: ${response.data.runtimeType}');
      // print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ============ Advice Routes ============

  /// Get all advice routes (lightweight list)
  Future<AdviceRouteListResponse> getAdviceRoutes() async {
    final response = await _dio.get('/api/v1/advice-routes/');
    return AdviceRouteListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get advice route by ID (full details)
  Future<AdviceRouteResponse> getAdviceRoute(String adviceRouteId) async {
    final response = await _dio.get('/api/v1/advice-routes/$adviceRouteId');
    return AdviceRouteResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
