import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/maplink.dart';

class MapLinkService {
  late final Dio _dio;
  String? _authToken;

  MapLinkService() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  /// Set the authentication token for API requests
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Generate Google Maps deep link for given places
  /// POST /api/v1/map_link/google-maps-link
  Future<GoogleMapsLinkResponse> generateGoogleMapsLink(
    GoogleMapsLinkRequest data,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/map_link/google-maps-link',
        data: data.toJson(),
      );
      return GoogleMapsLinkResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw GoogleMapsException(
          e.response?.data?['detail'] ?? 'Invalid request',
        );
      }
      rethrow;
    }
  }
}

// exception
class GoogleMapsException implements Exception {
  final String message;
  GoogleMapsException(this.message);

  @override
  String toString() => 'GoogleMapsException: $message';
}
