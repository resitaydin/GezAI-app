import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/route_result.dart';

/// Service for caching the last generated route locally.
/// Routes are cached for 30 days and automatically expire.
class CachedRouteService {
  static const String _cacheKey = 'cached_route';
  static const String _timestampKey = 'cached_route_timestamp';
  static const int _cacheDurationDays = 30;

  final SharedPreferences _prefs;

  CachedRouteService(this._prefs);

  /// Check if there's a valid cached route
  bool hasCachedRoute() {
    final routeJson = _prefs.getString(_cacheKey);
    if (routeJson == null) return false;

    // Check if cache has expired
    final timestamp = _prefs.getInt(_timestampKey);
    if (timestamp == null) return false;

    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(cachedTime).inDays;

    if (difference > _cacheDurationDays) {
      // Cache expired, clear it
      clearCache();
      return false;
    }

    return true;
  }

  /// Get the cached route, returns null if not found or expired
  RouteResult? getCachedRoute() {
    if (!hasCachedRoute()) return null;

    try {
      final routeJson = _prefs.getString(_cacheKey);
      if (routeJson == null) return null;

      final json = jsonDecode(routeJson) as Map<String, dynamic>;
      return RouteResult.fromJson(json);
    } catch (e) {
      debugPrint('Error loading cached route: $e');
      clearCache();
      return null;
    }
  }

  /// Save a route to cache, replacing any existing cached route
  Future<bool> cacheRoute(RouteResult route) async {
    try {
      final routeJson = jsonEncode(route.toJson());
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await _prefs.setString(_cacheKey, routeJson);
      await _prefs.setInt(_timestampKey, timestamp);

      debugPrint('Route cached successfully: ${route.title}');
      return true;
    } catch (e) {
      debugPrint('Error caching route: $e');
      return false;
    }
  }

  /// Clear the cached route
  Future<void> clearCache() async {
    await _prefs.remove(_cacheKey);
    await _prefs.remove(_timestampKey);
    debugPrint('Route cache cleared');
  }

  /// Get the cache timestamp
  DateTime? getCacheTimestamp() {
    final timestamp = _prefs.getInt(_timestampKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Get days until cache expires
  int? getDaysUntilExpiry() {
    final timestamp = getCacheTimestamp();
    if (timestamp == null) return null;

    final expiryDate = timestamp.add(const Duration(days: _cacheDurationDays));
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }
}
