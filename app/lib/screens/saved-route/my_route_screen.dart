import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import 'widgets/route_card.dart';
import '../../models/route_model.dart';
import '../../models/route_result.dart';
import '../../providers/saved_routes_provider.dart';
import '../../providers/home_navigation_provider.dart';


/// Content-only version for embedding in tab navigation (no Scaffold, no header)
class MyRoutesScreenContent extends ConsumerStatefulWidget {
  const MyRoutesScreenContent({super.key});

  @override
  ConsumerState<MyRoutesScreenContent> createState() => _MyRoutesScreenContentState();
}

class _MyRoutesScreenContentState extends ConsumerState<MyRoutesScreenContent> {
  @override
  Widget build(BuildContext context) {
    final savedRoutesAsync = ref.watch(savedRoutesProvider);

    return Container(
      color: const Color(0xFFF8FAFC),
      child: SafeArea(
        child: Column(
          children: [
            _buildContentHeader(),
            Expanded(
              child: savedRoutesAsync.when(
                data: (routes) => routes.isEmpty
                    ? _buildEmptyState()
                    : _buildRoutesList(routes),
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(error.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.myRoutesTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bookmark_rounded,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                    SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context)!.myRoutesSavedBadge,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF2563EB)),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.myRoutesErrorTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(savedRoutesProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.myRoutesRetryButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Container(
              width: 300,
              height: 350,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEF4),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Container(
                  width: 200,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/empty_saved_routes.png',
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildMapPlaceholder();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              AppLocalizations.of(context)!.myRoutesEmptyTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.myRoutesEmptySubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to explore/discover routes
                  context.go('/explore');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('\u2728', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.myRoutesDiscoverButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7CB8B8), Color(0xFFE8E4D8)],
          stops: [0.0, 0.4],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 50,
            left: 90,
            child: Icon(
              Icons.location_on,
              color: Color(0xFFEF4444),
              size: 20,
            ),
          ),
          Positioned(
            top: 80,
            left: 70,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Center(
                child: Icon(Icons.circle, color: Colors.white, size: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutesList(List<SavedRouteListItem> routes) {
    return RefreshIndicator(
      onRefresh: () => ref.read(savedRoutesProvider.notifier).refresh(),
      color: const Color(0xFF2563EB),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: RouteCard(
              route: route,
              onRemove: () => _showDeleteConfirmation(route),
              onViewDetails: () => _viewRouteDetails(route.savedRouteId),
            ),
          );
        },
      ),
    );
  }

  Future<void> _viewRouteDetails(String savedRouteId) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF2563EB)),
      ),
    );

    try {
      // Fetch the saved route details
      final savedRoute = await ref.read(savedRouteDetailProvider(savedRouteId).future);
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Convert SavedRouteResponse to RouteResult
      final routeResult = _convertToRouteResult(savedRoute);

      // Debug: Print locations for each stop
      for (final stop in routeResult.stops) {
        debugPrint('Stop ${stop.order}: ${stop.name} -> location: ${stop.location?.lat}, ${stop.location?.lng}');
      }

      // Navigate to RouteResultsScreen via home navigation provider
      if (mounted) {
        ref.read(homeNavigationProvider.notifier).navigateToRouteResults(routeResult);
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.myRoutesLoadFailed(e.toString())),
            backgroundColor: const Color(0xFFF43F5E),
          ),
        );
      }
    }
  }

  RouteResult _convertToRouteResult(SavedRouteResponse savedRoute) {
    final route = savedRoute.route;

    // Convert PlaceInRoute to RouteStop
    final stops = route.places.map((place) {
      // Convert TravelToNext to TravelSegment if available
      TravelSegment? travelSegment;
      if (place.travelToNext != null) {
        travelSegment = TravelSegment(
          mode: _parseTravelMode(route.transportType),
          durationMinutes: place.travelToNext!.durationMinutes ?? 0,
          distanceKm: place.travelToNext!.distanceKm,
        );
      }

      return RouteStop(
        order: place.order,
        placeId: place.placeId,
        name: place.name,
        description: place.notes,
        durationMinutes: place.durationMinutes ?? 30,
        category: place.category,
        photoUrl: place.photoUrl,
        location: place.location,
        travelToNext: travelSegment,
      );
    }).toList();

    return RouteResult(
      routeId: route.routeId,
      title: savedRoute.displayTitle,
      subtitle: route.description,
      description: route.descriptionEn,
      region: route.region,
      totalDistanceKm: route.totalDistanceKm ?? 0,
      totalDurationHours: route.durationHours,
      stops: stops,
      transportType: route.transportType,
      createdAt: route.createdAt,
    );
  }

  TravelMode _parseTravelMode(String transportType) {
    switch (transportType.toLowerCase()) {
      case 'transit':
      case 'bus':
      case 'public_transit':
        return TravelMode.transit;
      case 'driving':
      case 'car':
        return TravelMode.driving;
      default:
        return TravelMode.walking;
    }
  }

  void _showDeleteConfirmation(SavedRouteListItem route) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 32),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFF43F5E),
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  AppLocalizations.of(context)!.myRoutesDeleteTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  AppLocalizations.of(context)!.myRoutesDeleteMessage(route.displayTitle),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => Navigator.pop(context),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.myRoutesCancelButton,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF43F5E).withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              Navigator.pop(context);
                              _deleteRoute(route.savedRouteId);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.myRoutesDeleteButton,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteRoute(String savedRouteId) async {
    try {
      await ref.read(savedRoutesProvider.notifier).deleteSavedRoute(savedRouteId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.myRoutesDeleteSuccess),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.myRoutesDeleteFailed(e.toString())),
            backgroundColor: const Color(0xFFF43F5E),
          ),
        );
      }
    }
  }
}

/// Full screen version with Scaffold (for standalone navigation)
class MyRoutesScreen extends ConsumerStatefulWidget {
  const MyRoutesScreen({super.key});

  @override
  ConsumerState<MyRoutesScreen> createState() => _MyRoutesScreenState();
}

class _MyRoutesScreenState extends ConsumerState<MyRoutesScreen> {

  @override
  Widget build(BuildContext context) {
    final savedRoutesAsync = ref.watch(savedRoutesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: savedRoutesAsync.when(
                data: (routes) => routes.isEmpty
                    ? _buildEmptyState()
                    : _buildRoutesList(routes),
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(error.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF2563EB)),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.myRoutesErrorTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(savedRoutesProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.myRoutesRetryButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 24, 16),
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Color(0xFF475569),
              size: 22,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.myRoutesTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bookmark_rounded,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                    SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context)!.myRoutesSavedBadge,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.myRoutesSubtitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            // Map illustration container
            Container(
              width: 300,
              height: 350,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEF4),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Container(
                  width: 200,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/empty_saved_routes.png',
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildMapPlaceholder();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              AppLocalizations.of(context)!.myRoutesEmptyTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.myRoutesEmptySubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 60),
            // Discover Routes button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to explore/discover routes
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('✨', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.myRoutesDiscoverButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7CB8B8), Color(0xFFE8E4D8)],
          stops: [0.0, 0.4],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 50,
            left: 90,
            child: const Icon(
              Icons.location_on,
              color: Color(0xFFEF4444),
              size: 20,
            ),
          ),
          Positioned(
            top: 80,
            left: 70,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Center(
                child: Icon(Icons.circle, color: Colors.white, size: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutesList(List<SavedRouteListItem> routes) {
    return RefreshIndicator(
      onRefresh: () => ref.read(savedRoutesProvider.notifier).refresh(),
      color: const Color(0xFF2563EB),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: RouteCard(
              route: route,
              onRemove: () => _showDeleteConfirmation(route),
              onViewDetails: () => _viewRouteDetails(route.savedRouteId),
            ),
          );
        },
      ),
    );
  }

  Future<void> _viewRouteDetails(String savedRouteId) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF2563EB)),
      ),
    );

    try {
      // Fetch the saved route details
      final savedRoute = await ref.read(savedRouteDetailProvider(savedRouteId).future);
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);


      final routeResult = _convertToRouteResult(savedRoute);

      // Navigate to RouteResultsScreen via home navigation provider
      if (mounted) {
        ref.read(homeNavigationProvider.notifier).navigateToRouteResults(routeResult);
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.myRoutesLoadFailed(e.toString())),
            backgroundColor: const Color(0xFFF43F5E),
          ),
        );
      }
    }
  }

  RouteResult _convertToRouteResult(SavedRouteResponse savedRoute) {
    final route = savedRoute.route;

    // Convert PlaceInRoute to RouteStop
    final stops = route.places.map((place) {
      // Convert TravelToNext to TravelSegment if available
      TravelSegment? travelSegment;
      if (place.travelToNext != null) {
        travelSegment = TravelSegment(
          mode: _parseTravelMode(route.transportType),
          durationMinutes: place.travelToNext!.durationMinutes ?? 0,
          distanceKm: place.travelToNext!.distanceKm,
        );
      }

      return RouteStop(
        order: place.order,
        placeId: place.placeId,
        name: place.name,
        description: place.notes,
        durationMinutes: place.durationMinutes ?? 30,
        category: place.category,
        photoUrl: place.photoUrl,
        location: place.location,
        travelToNext: travelSegment,
      );
    }).toList();

    return RouteResult(
      routeId: route.routeId,
      title: savedRoute.displayTitle,
      subtitle: route.description,
      description: route.descriptionEn,
      region: route.region,
      totalDistanceKm: route.totalDistanceKm ?? 0,
      totalDurationHours: route.durationHours,
      stops: stops,
      transportType: route.transportType,
      createdAt: route.createdAt,
    );
  }

  TravelMode _parseTravelMode(String transportType) {
    switch (transportType.toLowerCase()) {
      case 'transit':
      case 'bus':
      case 'public_transit':
        return TravelMode.transit;
      case 'driving':
      case 'car':
        return TravelMode.driving;
      default:
        return TravelMode.walking;
    }
  }

  void _showDeleteConfirmation(SavedRouteListItem route) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 32),
              // Warning Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFF43F5E),
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  AppLocalizations.of(context)!.myRoutesDeleteDialogTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  AppLocalizations.of(context)!.myRoutesDeleteDialogMessage(route.displayTitle),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => Navigator.pop(context),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.myRoutesCancelButton,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Delete Button
                    Expanded(
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFF43F5E,
                              ).withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              Navigator.pop(context);
                              _deleteRoute(route.savedRouteId);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.myRoutesDeleteButton,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteRoute(String savedRouteId) async {
    try {
      await ref
          .read(savedRoutesProvider.notifier)
          .deleteSavedRoute(savedRouteId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.myRoutesDeleteSuccess),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.myRoutesDeleteFailed(e.toString())),
            backgroundColor: const Color(0xFFF43F5E),
          ),
        );
      }
    }
  }
}

