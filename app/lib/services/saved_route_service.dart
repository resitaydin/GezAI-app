import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/route_model.dart';

class SavedRouteService {
  late final Dio _dio;
  String? _authToken;

  SavedRouteService() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';
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

  /// Set the authentication token for API requests
  void setAuthToken(String? token) {
    _authToken = token;
    //print('Auth token set: $_authToken');
  }

  /// Save a route for the current user
  /// POST /api/v1/saved-routes/
  Future<SavedRouteResponse> saveRoute(SavedRouteCreate data) async {
    try {
      final response = await _dio.post(
        '/api/v1/saved-routes/',
        data: data.toJson(),
      );
      return SavedRouteResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw SavedRouteException(
          e.response?.data?['detail'] ?? 'Invalid request',
        );
      }
      rethrow;
    }
  }

  /// List saved routes for the current user
  /// GET /api/v1/saved-routes/
  Future<SavedRouteListResponse> listSavedRoutes() async {
    final response = await _dio.get('/api/v1/saved-routes/');
    return SavedRouteListResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Get a saved route by ID
  /// GET /api/v1/saved-routes/{saved_route_id}
  Future<SavedRouteResponse> getSavedRoute(String savedRouteId) async {
    try {
      final response = await _dio.get('/api/v1/saved-routes/$savedRouteId');
      return SavedRouteResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw SavedRouteException('Saved route not found');
      }
      rethrow;
    }
  }

  /// Update a saved route
  /// PUT /api/v1/saved-routes/{saved_route_id}
  Future<SavedRouteResponse> updateSavedRoute(
    String savedRouteId,
    SavedRouteUpdate data,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v1/saved-routes/$savedRouteId',
        data: data.toJson(),
      );
      return SavedRouteResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw SavedRouteException('Route not found');
      }
      rethrow;
    }
  }

  /// Delete a saved route
  /// DELETE /api/v1/saved-routes/{saved_route_id}
  Future<void> deleteSavedRoute(String savedRouteId) async {
    try {
      await _dio.delete('/api/v1/saved-routes/$savedRouteId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw SavedRouteException('Saved route not found');
      }
      rethrow;
    }
  }
}

/// Exception for saved route operations
class SavedRouteException implements Exception {
  final String message;

  SavedRouteException(this.message);

  @override
  String toString() => 'SavedRouteException: $message';
}
