import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../models/route_result.dart';
import '../../models/place.dart';
import '../../models/maplink.dart' as maplink;
import '../../providers/home_navigation_provider.dart';
import '../../providers/maplink_provider.dart';
import '../../providers/saved_routes_provider.dart';
import '../../providers/place_provider.dart';
import '../../providers/cached_route_provider.dart';
import '../../services/saved_route_service.dart';
import '../../widgets/place_preview_sheet.dart';
import 'widgets/route_info_pill.dart';
import 'widgets/timeline_stop_card.dart';
import 'widgets/route_action_bar.dart';
import 'widgets/custom_map_marker.dart';

/// Content-only version for embedding in tab navigation (removes back button)
class RouteResultsScreenContent extends ConsumerStatefulWidget {
  final RouteResult? routeResult;

  const RouteResultsScreenContent({super.key, this.routeResult});

  @override
  ConsumerState<RouteResultsScreenContent> createState() =>
      _RouteResultsScreenContentState();
}

class _RouteResultsScreenContentState
    extends ConsumerState<RouteResultsScreenContent> {
  RouteResult? _routeResult;
  int? _selectedStopIndex;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  final Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isSaving = false;

  // Place prefetch state - cache fetched places with about
  final Map<String, Place> _prefetchedPlaces = {};
  final Set<String> _prefetchingPlaceIds = {};

  @override
  void initState() {
    super.initState();
    _initializeRoute();
  }

  void _initializeRoute() {
    if (widget.routeResult != null) {
      // Use route from widget (just generated or from saved routes)
      _routeResult = widget.routeResult;
      // Cache the new route
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(cachedRouteProvider.notifier).cacheRoute(widget.routeResult!);
      });
      _initializeMapData();
      _prefetchPlaceDetails();
    }
    // If no widget route, we'll show empty state or load from cache
  }

  /// Prefetch place details (with about) for all stops in parallel
  /// This runs in the background while user sees the map
  Future<void> _prefetchPlaceDetails() async {
    if (_routeResult == null) return;

    final apiService = ref.read(apiServiceProvider);
    final placeIds = _routeResult!.stops
        .map((stop) => stop.placeId)
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (placeIds.isEmpty) return;

    // Mark all as prefetching
    _prefetchingPlaceIds.addAll(placeIds);

    // Fetch all places in parallel
    final futures = placeIds.map((placeId) async {
      try {
        final place = await apiService.getPlace(placeId);
        if (mounted) {
          setState(() {
            _prefetchedPlaces[placeId] = place;
            _prefetchingPlaceIds.remove(placeId);
          });
          // Also update the global cache
          ref.read(placeCacheProvider.notifier).addPlace(place);
        }
      } catch (e) {
        // Silently fail - user will see loading state if they tap
        debugPrint('Failed to prefetch place $placeId: $e');
        if (mounted) {
          setState(() {
            _prefetchingPlaceIds.remove(placeId);
          });
        }
      }
    });

    // Run all in parallel
    await Future.wait(futures);
  }

  @override
  void didUpdateWidget(covariant RouteResultsScreenContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update route result when widget receives new data
    if (widget.routeResult != null && widget.routeResult != oldWidget.routeResult) {
      setState(() {
        _routeResult = widget.routeResult;
        _selectedStopIndex = null;
        // Clear prefetch state for new route
        _prefetchedPlaces.clear();
        _prefetchingPlaceIds.clear();
      });
      // Cache the new route
      ref.read(cachedRouteProvider.notifier).cacheRoute(widget.routeResult!);
      _initializeMapData();
      _fitMapToRoute();
      _prefetchPlaceDetails(); // Prefetch for new route
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _initializeMapData() {
    if (_routeResult == null) return;
    _createCustomMarkers();
    _createModernPolyline();
  }

  Future<void> _createCustomMarkers() async {
    if (_routeResult == null) return;

    final markers = <Marker>{};

    for (int i = 0; i < _routeResult!.stops.length; i++) {
      final stop = _routeResult!.stops[i];
      if (stop.location != null) {
        final isFirst = i == 0;
        final isLast = i == _routeResult!.stops.length - 1;
        final isSelected = _selectedStopIndex == i;

        final icon = await CustomMapMarker.createMarkerBitmap(
          category: stop.category,
          order: stop.order,
          isFirst: isFirst,
          isLast: isLast,
          isSelected: isSelected,
        );

        markers.add(
          Marker(
            markerId: MarkerId('stop_${stop.order}'),
            position: LatLng(stop.location!.lat, stop.location!.lng),
            icon: icon,
            anchor: const Offset(0.5, 1.0),
            onTap: () => _onMarkerTapped(i),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  void _createModernPolyline() {
    if (_routeResult == null) return;

    final polylines = <Polyline>{};
    final stopsWithLocation = _routeResult!.stops
        .where((s) => s.location != null)
        .toList();

    if (stopsWithLocation.length < 2) return;

    final allPoints = stopsWithLocation
        .map((s) => LatLng(s.location!.lat, s.location!.lng))
        .toList();

    // 1. Shadow Layer (Depth)
    polylines.add(
      Polyline(
        polylineId: const PolylineId('route_shadow'),
        points: allPoints,
        color: Colors.black.withValues(alpha: 0.15),
        width: 10,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        zIndex: 0,
      ),
    );

    // 2. Base Layer (Outline)
    polylines.add(
      Polyline(
        polylineId: const PolylineId('route_base'),
        points: allPoints,
        color: Colors.white,
        width: 7,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        zIndex: 1,
      ),
    );

    // 3. Segment Layer
    for (int i = 0; i < stopsWithLocation.length - 1; i++) {
      final current = stopsWithLocation[i];
      final next = stopsWithLocation[i + 1];

      final mode = current.travelToNext?.mode ?? TravelMode.driving;
      // segment_{order} ensures unique ID for each leg
      final PolylineId id = PolylineId('segment_${current.order}');

      Color color;
      List<PatternItem> patterns = [];

      switch (mode) {
        case TravelMode.walking:
          color = const Color(0xFF4285F4); // Blue
          patterns = [PatternItem.dash(12), PatternItem.gap(8)];
          break;
        case TravelMode.transit:
          color = const Color(0xFFEA4335); // Red
          patterns = [];
          break;
        case TravelMode.driving:
          color = const Color(0xFF34A853); // Green
          patterns = [];
          break;
      }

      polylines.add(
        Polyline(
          polylineId: id,
          points: [
            LatLng(current.location!.lat, current.location!.lng),
            LatLng(next.location!.lat, next.location!.lng),
          ],
          color: color,
          width: 4,
          patterns: patterns,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          zIndex: 2,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _polylines = polylines;
      });
    }
  }

  LatLng _getInitialCameraPosition() {
    if (_routeResult == null || _routeResult!.stops.isEmpty) {
      return const LatLng(41.0256, 29.0151);
    }

    double totalLat = 0;
    double totalLng = 0;
    int count = 0;

    for (final stop in _routeResult!.stops) {
      if (stop.location != null) {
        totalLat += stop.location!.lat;
        totalLng += stop.location!.lng;
        count++;
      }
    }

    if (count == 0) {
      return const LatLng(41.0256, 29.0151);
    }

    return LatLng(totalLat / count, totalLng / count);
  }

  LatLngBounds _getMapBounds() {
    if (_routeResult == null || _routeResult!.stops.isEmpty) {
      return LatLngBounds(
        southwest: const LatLng(41.0, 29.0),
        northeast: const LatLng(41.1, 29.1),
      );
    }

    double minLat = 90;
    double maxLat = -90;
    double minLng = 180;
    double maxLng = -180;

    for (final stop in _routeResult!.stops) {
      if (stop.location != null) {
        if (stop.location!.lat < minLat) minLat = stop.location!.lat;
        if (stop.location!.lat > maxLat) maxLat = stop.location!.lat;
        if (stop.location!.lng < minLng) minLng = stop.location!.lng;
        if (stop.location!.lng > maxLng) maxLng = stop.location!.lng;
      }
    }

    const padding = 0.002;
    return LatLngBounds(
      southwest: LatLng(minLat - padding, minLng - padding),
      northeast: LatLng(maxLat + padding, maxLng + padding),
    );
  }

  void _onMarkerTapped(int index) {
    if (_routeResult == null) return;

    setState(() {
      _selectedStopIndex = index;
    });

    final stop = _routeResult!.stops[index];
    final regionName = _routeResult!.region.isNotEmpty
        ? _routeResult!.region.first
        : 'Üsküdar'; // Default to Üsküdar for MVP

    // Check if we have prefetched data
    final prefetchedPlace = _prefetchedPlaces[stop.placeId];
    final isStillLoading = _prefetchingPlaceIds.contains(stop.placeId);

    // Check if prefetched place has about text
    final hasAbout = prefetchedPlace?.about != null &&
                     prefetchedPlace!.about!.isNotEmpty;

    if (prefetchedPlace != null && hasAbout) {
      // Use prefetched data directly - instant display with about
      final data = PlacePreviewData.fromPlace(prefetchedPlace);
      PlacePreviewSheet.show(
        context,
        data: data,
        onFavoritePressed: () {
          // TODO: Implement favorite functionality
        },
        onMorePressed: () {
          // TODO: Implement more options
        },
      );
    } else {
      // Either no prefetched data, or prefetched but missing about
      // Use showWithFetch which will generate about via Firebase AI
      final initialData = prefetchedPlace != null
          ? PlacePreviewData(
              placeId: prefetchedPlace.placeId,
              name: prefetchedPlace.name,
              description: prefetchedPlace.description ?? prefetchedPlace.descriptionEn,
              about: null,
              location: '${prefetchedPlace.region}, ${prefetchedPlace.city}',
              category: prefetchedPlace.category,
              rating: prefetchedPlace.rating,
              totalRatings: prefetchedPlace.totalRatings,
              photoUrls: prefetchedPlace.photos.map((p) => p.url).whereType<String>().toList(),
              isAboutLoading: true,
            )
          : PlacePreviewData(
              placeId: stop.placeId,
              name: stop.name,
              description: stop.description,
              about: null,
              location: '$regionName, Istanbul',
              category: stop.category,
              rating: stop.rating,
              totalRatings: null,
              photoUrls: stop.photoUrl != null ? [stop.photoUrl!] : [],
              isAboutLoading: isStillLoading,
            );

      PlacePreviewSheet.showWithFetch(
        context,
        name: stop.name,
        region: regionName,
        initialData: initialData,
        onFavoritePressed: () {
          // TODO: Implement favorite functionality
        },
        onMorePressed: () {
          // TODO: Implement more options
        },
      );
    }
  }

  void _onStopTapped(int index) async {
    if (_routeResult == null) return;

    setState(() {
      _selectedStopIndex = _selectedStopIndex == index ? null : index;
    });

    if (_selectedStopIndex != null) {
      final stop = _routeResult!.stops[_selectedStopIndex!];
      if (stop.location != null) {
        final controller = await _mapController.future;
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(stop.location!.lat, stop.location!.lng),
            16,
          ),
        );
      }
    }
  }

  Future<void> _fitMapToRoute() async {
    final controller = await _mapController.future;
    final bounds = _getMapBounds();
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  Future<void> _centerOnUserLocation() async {
    if (_routeResult != null &&
        _routeResult!.stops.isNotEmpty &&
        _routeResult!.stops.first.location != null) {
      final controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            _routeResult!.stops.first.location!.lat,
            _routeResult!.stops.first.location!.lng,
          ),
          15,
        ),
      );
    }
  }

  Future<void> _onStartRoute() async {
    if (_routeResult == null) return;

    // Convert route stops to RoutePlaceMaplink list
    final places = _routeResult!.stops.map((stop) {
      return maplink.RoutePlaceMaplink(
        name: stop.name,
        lat: stop.location?.lat,
        lng: stop.location?.lng,
      );
    }).toList();

    final l10n = AppLocalizations.of(context)!;

    if (places.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.snackbarAtLeastTwoStops),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Call API to generate Google Maps link
    final linkNotifier = ref.read(googleMapsLinkProvider.notifier);
    final response = await linkNotifier.generateLink(
      places: places,
      travelMode: maplink.TravelMode.fromString(_routeResult!.transportType),
    );

    if (response != null) {
      // Open Google Maps URL
      final url = Uri.parse(response.googleMapsUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.snackbarCouldNotOpenMaps),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Show error
      final error = ref.read(googleMapsLinkProvider).error;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? l10n.snackbarFailedGenerateLink),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCustomSnackBar({
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color iconBackgroundColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }

  void _showSavedSnackBar() {
    _showCustomSnackBar(
      message: AppLocalizations.of(context)!.routeSaved,
      icon: Icons.bookmark_added_rounded,
      backgroundColor: const Color(0xFF1E293B),
      iconBackgroundColor: const Color(0xFFF59E0B),
    );
  }

  void _showRemovedSnackBar() {
    _showCustomSnackBar(
      message: AppLocalizations.of(context)!.routeUnsaved,
      icon: Icons.bookmark_remove_rounded,
      backgroundColor: const Color(0xFF374151),
      iconBackgroundColor: const Color(0xFF6B7280),
    );
  }

  void _showErrorSnackBar(String message) {
    _showCustomSnackBar(
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: const Color(0xFF991B1B),
      iconBackgroundColor: const Color(0xFFDC2626),
    );
  }

  void _onRegenerate() {
    // Navigate back to Explore tab (index 0)
    ref.read(homeNavigationProvider.notifier).setTabIndex(0);
  }

  Future<void> _onSaveRoute() async {
    if (_routeResult == null) return;

    final routeId = _routeResult!.routeId;
    if (routeId == null) {
      _showErrorSnackBar(AppLocalizations.of(context)!.cannotSaveRoute);
      return;
    }

    final savedRoutesNotifier = ref.read(savedRoutesProvider.notifier);
    final isSaved = savedRoutesNotifier.isRouteSaved(routeId);

    setState(() {
      _isSaving = true;
    });

    try {
      if (isSaved) {
        // Unsave the route
        final savedRouteId = savedRoutesNotifier.getSavedRouteId(routeId);
        if (savedRouteId != null) {
          await savedRoutesNotifier.deleteSavedRoute(savedRouteId);
          if (mounted) {
            _showRemovedSnackBar();
          }
        }
      } else {
        // Save the route
        await savedRoutesNotifier.saveRoute(
          routeId: routeId,
          customTitle: _routeResult!.title,
        );
        if (mounted) {
          _showSavedSnackBar();
        }
      }
    } on SavedRouteException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(AppLocalizations.of(context)!.failedToSaveRoute);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch cached route state
    final cachedState = ref.watch(cachedRouteProvider);

    // Determine the route to display
    RouteResult? displayRoute = _routeResult;

    // If no widget route and cache is loaded, use cached route
    if (displayRoute == null && cachedState.hasCheckedCache) {
      displayRoute = cachedState.route;
      if (displayRoute != null && _routeResult == null) {
        // Initialize with cached route
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _routeResult == null) {
            setState(() {
              _routeResult = displayRoute;
            });
            _initializeMapData();
            _prefetchPlaceDetails();
          }
        });
      }
    }

    // Show loading while cache is being checked
    if (!cachedState.hasCheckedCache && widget.routeResult == null) {
      return _buildLoadingState();
    }

    // Show empty state if no route available
    if (displayRoute == null) {
      return _buildEmptyState();
    }

    return Container(
      color: const Color(0xFFF6F7F8),
      child: Stack(
        children: [
          _buildMapSection(),
          _buildTopBarContent(),
          _buildBottomSheet(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RouteActionBar(
              onStartRoute: _onStartRoute,
              onRegenerate: _onRegenerate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: const Color(0xFFF6F7F8),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3B82F6),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: const Color(0xFFF6F7F8),
      child: Stack(
        children: [
          // Empty state content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Illustration
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Decorative circles
                      Positioned(
                        top: 20,
                        right: 30,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 25,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Main icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Title
                Text(
                  AppLocalizations.of(context)!.noRouteYet,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    AppLocalizations.of(context)!.createFirstRoute,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Create Route Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ref.read(homeNavigationProvider.notifier).setTabIndex(0);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.createYourRoute,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
          // Bottom bar with empty state message
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RouteActionBar(
              isEmpty: true,
              onStartRoute: null,
              onRegenerate: () {
                ref.read(homeNavigationProvider.notifier).setTabIndex(0);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBarContent() {
    // Watch saved routes to check if current route is saved
    final savedRoutesAsync = ref.watch(savedRoutesProvider);
    final isSaved = savedRoutesAsync.whenOrNull(
      data: (routes) {
        if (_routeResult?.routeId == null) return false;
        return routes.any((r) => r.routeId == _routeResult!.routeId);
      },
    ) ?? false;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.2), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildSaveButton(isSaved: isSaved),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton({required bool isSaved}) {
    const savedColor = Color(0xFFF59E0B); // Amber/Orange
    const unsavedColor = Color(0xFF64748B); // Slate gray

    return GestureDetector(
      onTap: _isSaving ? null : _onSaveRoute,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSaved ? savedColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isSaved
                  ? savedColor.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: isSaved ? 12 : 8,
              offset: const Offset(0, 4),
              spreadRadius: isSaved ? 1 : 0,
            ),
          ],
          border: isSaved
              ? null
              : Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: _isSaving
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isSaved ? Colors.white : savedColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
                    color: isSaved ? Colors.white : unsavedColor,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isSaved ? AppLocalizations.of(context)!.saved : AppLocalizations.of(context)!.save,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSaved ? Colors.white : unsavedColor,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMapSection() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      width: double.infinity,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _getInitialCameraPosition(),
              zoom: 12,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
              Future.delayed(const Duration(milliseconds: 500), () {
                _fitMapToRoute();
              });
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            mapType: MapType.normal,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 60,
              bottom: MediaQuery.of(context).size.height * 0.15,
            ),
          ),
          if (_routeResult != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 0,
              right: 0,
              child: Center(
                child: RouteInfoPill(
                  distance: _routeResult!.formattedDistance,
                  duration: _routeResult!.formattedDuration,
                ),
              ),
            ),
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.15 + 20,
            child: _buildMapControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControls() {
    return Column(
      children: [
        _buildMapControlButton(
          icon: Icons.my_location,
          onTap: _centerOnUserLocation,
        ),
        const SizedBox(height: 12),
        _buildMapControlButton(icon: Icons.zoom_out_map, onTap: _fitMapToRoute),
      ],
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF475569), size: 22),
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    if (_routeResult == null) return const SizedBox.shrink();

    // Calculate max child size based on number of stops
    // Each stop card is roughly 120px + header ~100px + bottom padding 120px
    final stopCount = _routeResult!.stops.length;
    final estimatedContentHeight = 100 + (stopCount * 130) + 120;
    final screenHeight = MediaQuery.of(context).size.height;
    final calculatedMaxSize = (estimatedContentHeight / screenHeight).clamp(0.45, 0.9);

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.35,
      maxChildSize: calculatedMaxSize,
      controller: _sheetController,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFB),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Header as sliver - scrolls with content
              SliverToBoxAdapter(
                child: _buildSheetHeader(),
              ),
              // Stop cards list
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final stop = _routeResult!.stops[index];
                      final isLast = index == _routeResult!.stops.length - 1;
                      final isSelected = _selectedStopIndex == index;

                      return TimelineStopCard(
                        stop: stop,
                        isLast: isLast,
                        isSelected: isSelected,
                        onTap: () => _onStopTapped(index),
                      );
                    },
                    childCount: _routeResult!.stops.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetHeader() {
    if (_routeResult == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _routeResult!.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (_routeResult!.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _routeResult!.subtitle!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 14,
                      color: Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context)!.stopsCount(_routeResult!.stopsCount),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
