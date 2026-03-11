import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/advice_route.dart';
import '../../providers/advice_routes_provider.dart';
import '../../providers/home_navigation_provider.dart';
import '../../utils/responsive_utils.dart';
import 'widgets/advice_route_card.dart';

/// Content-only version for embedding in tab navigation (no Scaffold, no header)
class AdviceRoutesScreenContent extends ConsumerStatefulWidget {
  const AdviceRoutesScreenContent({super.key});

  @override
  ConsumerState<AdviceRoutesScreenContent> createState() =>
      _AdviceRoutesScreenContentState();
}

class _AdviceRoutesScreenContentState
    extends ConsumerState<AdviceRoutesScreenContent>
    with TickerProviderStateMixin {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Walking',
    'Transit',
    'Driving',
  ];

  late AnimationController _animationController;
  late AnimationController _shimmerController;
  String? _loadingRouteId;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adviceRoutesAsync = ref.watch(adviceRoutesProvider);
    final responsive = ResponsiveUtils.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFF1F5F9),
            Color(0xFFEEF2FF),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildPremiumHeader(responsive),
            _buildFilterChips(responsive),
            Expanded(
              child: adviceRoutesAsync.when(
                data: (routes) {
                  final filteredRoutes = _filterRoutes(routes);
                  return filteredRoutes.isEmpty
                      ? _buildEmptyState(responsive)
                      : _buildRoutesList(filteredRoutes, responsive);
                },
                loading: () => _buildPremiumLoadingState(responsive),
                error: (error, stack) =>
                    _buildErrorState(error.toString(), responsive),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(ResponsiveUtils responsive) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(
        responsive.pagePaddingHorizontal,
        responsive.spacingSmall + 4,
        responsive.pagePaddingHorizontal,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.curatedRoutes,
                style: TextStyle(
                  fontSize: responsive.subtitleFontSize + 4,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.8,
                ),
              ),
              SizedBox(width: responsive.spacingSmall),
              // Container(
              //   padding: EdgeInsets.symmetric(
              //     horizontal: responsive.spacingSmall,
              //     vertical: 2,
              //   ),
              //   decoration: BoxDecoration(
              //     gradient: const LinearGradient(
              //       colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              //     ),
              //     borderRadius: BorderRadius.circular(6),
              //   ),
              //   child: Text(
              //     'PRO',
              //     style: TextStyle(
              //       fontSize: responsive.captionFontSize - 2,
              //       fontWeight: FontWeight.w800,
              //       color: Colors.white,
              //       letterSpacing: 0.5,
              //     ),
              //   ),
              // ),
            ],
          ),
          SizedBox(height: responsive.spacingXS - 2),
          Text(
            l10n.curatedRoutesSubtitle,
            style: TextStyle(
              fontSize: responsive.captionFontSize,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ResponsiveUtils responsive) {
    final chipHeight = responsive.valueByScreenSize(
      compact: 38.0,
      regular: 40.0,
      tall: 42.0,
    );

    return Container(
      height: chipHeight,
      margin: EdgeInsets.only(top: responsive.spacingSmall + 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
            horizontal: responsive.pagePaddingHorizontal - 4),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;

          return Padding(
            padding: EdgeInsets.only(right: responsive.spacingSmall),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.contentPadding,
                  vertical: responsive.spacingSmall,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius:
                      BorderRadius.circular(responsive.borderRadius + 4),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF667EEA).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (filter == 'Walking')
                      _buildFilterIcon(Icons.directions_walk_rounded,
                          isSelected, const Color(0xFF3B82F6)),
                    if (filter == 'Transit')
                      _buildFilterIcon(Icons.directions_bus_rounded, isSelected,
                          const Color(0xFFF59E0B)),
                    if (filter == 'Driving')
                      _buildFilterIcon(Icons.directions_car_rounded, isSelected,
                          const Color(0xFF10B981)),
                    if (filter == 'All')
                      _buildFilterIcon(
                          Icons.apps_rounded, isSelected, const Color(0xFF667EEA)),
                    SizedBox(width: responsive.spacingXS),
                    Text(
                      _getFilterLabel(filter, context),
                      style: TextStyle(
                        fontSize: responsive.captionFontSize + 1,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterIcon(IconData icon, bool isSelected, Color activeColor) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.2)
            : activeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Icon(
        icon,
        size: 14,
        color: isSelected ? Colors.white : activeColor,
      ),
    );
  }

  List<AdviceRouteListItem> _filterRoutes(List<AdviceRouteListItem> routes) {
    switch (_selectedFilter) {
      case 'Walking':
        return routes
            .where((r) => r.transportType?.toLowerCase() == 'walking')
            .toList();
      case 'Transit':
        return routes
            .where((r) => r.transportType?.toLowerCase() == 'transit')
            .toList();
      case 'Driving':
        return routes
            .where((r) => r.transportType?.toLowerCase() == 'driving')
            .toList();
      default:
        return routes;
    }
  }

  Widget _buildPremiumLoadingState(ResponsiveUtils responsive) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        responsive.pagePaddingHorizontal,
        responsive.spacingMedium,
        responsive.pagePaddingHorizontal,
        responsive.spacingXL,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: responsive.spacingMedium),
          child: _buildShimmerCard(responsive, index),
        );
      },
    );
  }

  Widget _buildShimmerCard(ResponsiveUtils responsive, int index) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(responsive.cardRadius + 8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A5F).withValues(alpha: 0.06),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(responsive.cardRadius + 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image skeleton
                _buildShimmerBox(
                  width: double.infinity,
                  height: responsive.valueByScreenSize(
                    compact: 160.0,
                    regular: 175.0,
                    tall: 190.0,
                  ),
                  borderRadius: 0,
                ),
                // Content skeleton
                Padding(
                  padding: EdgeInsets.all(responsive.contentPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      _buildShimmerBox(
                        width: responsive.valueByScreenSize(
                          compact: 180.0,
                          regular: 210.0,
                          tall: 240.0,
                        ),
                        height: 22,
                        borderRadius: 8,
                      ),
                      SizedBox(height: responsive.spacingSmall),
                      // Location
                      _buildShimmerBox(
                        width: responsive.valueByScreenSize(
                          compact: 120.0,
                          regular: 140.0,
                          tall: 160.0,
                        ),
                        height: 16,
                        borderRadius: 6,
                      ),
                      SizedBox(height: responsive.spacingMedium),
                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatShimmer(responsive),
                          _buildStatShimmer(responsive),
                          _buildStatShimmer(responsive),
                        ],
                      ),
                      SizedBox(height: responsive.spacingMedium),
                      // Button
                      _buildShimmerBox(
                        width: double.infinity,
                        height: responsive.buttonHeight - 4,
                        borderRadius: responsive.borderRadius + 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatShimmer(ResponsiveUtils responsive) {
    return Column(
      children: [
        _buildShimmerBox(width: 32, height: 32, borderRadius: 8),
        SizedBox(height: responsive.spacingXS),
        _buildShimmerBox(width: 44, height: 12, borderRadius: 4),
      ],
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2 * _shimmerController.value, 0),
              end: Alignment(1.0 + 2 * _shimmerController.value, 0),
              colors: const [
                Color(0xFFEEF2FF),
                Color(0xFFE0E7FF),
                Color(0xFFEEF2FF),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error, ResponsiveUtils responsive) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.pagePaddingHorizontal),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon with gradient background
            Container(
              width: responsive.iconSizeLarge + 32,
              height: responsive.iconSizeLarge + 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF6B6B).withValues(alpha: 0.15),
                    const Color(0xFFEE5A24).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(responsive.cardRadius + 8),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: responsive.iconSizeLarge,
                color: const Color(0xFFEF4444),
              ),
            ),
            SizedBox(height: responsive.spacingLarge),
            Text(
              l10n.somethingWentWrong,
              style: TextStyle(
                fontSize: responsive.subtitleFontSize + 2,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: responsive.spacingSmall),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsive.captionFontSize + 1,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            SizedBox(height: responsive.spacingXL),
            Container(
              height: responsive.buttonHeight + 4,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius:
                    BorderRadius.circular(responsive.borderRadius + 4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(responsive.borderRadius + 4),
                  onTap: () => ref.invalidate(adviceRoutesProvider),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: responsive.spacingXL),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.refresh_rounded,
                              color: Colors.white,
                              size: responsive.iconSize - 4),
                        ),
                        SizedBox(width: responsive.spacingSmall + 2),
                        Text(
                          l10n.tryAgain,
                          style: TextStyle(
                            fontSize: responsive.bodyFontSize + 1,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
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
    );
  }

  Widget _buildEmptyState(ResponsiveUtils responsive) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon
            Container(
              width: responsive.logoSize + 20,
              height: responsive.logoSize + 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF667EEA).withValues(alpha: 0.12),
                    const Color(0xFF764BA2).withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(responsive.cardRadius + 16),
                border: Border.all(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.explore_off_rounded,
                size: responsive.iconSizeLarge + 8,
                color: const Color(0xFF667EEA),
              ),
            ),
            SizedBox(height: responsive.spacingXL),
            Text(
              l10n.noRoutesFound,
              style: TextStyle(
                fontSize: responsive.subtitleFontSize + 2,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: responsive.spacingSmall),
            Text(
              l10n.noRoutesFoundSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsive.bodyFontSize,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
                height: 1.6,
              ),
            ),
            SizedBox(height: responsive.spacingXL),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = 'All';
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacingLarge,
                  vertical: responsive.spacingSmall + 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF667EEA).withValues(alpha: 0.1),
                      const Color(0xFF764BA2).withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(responsive.borderRadius + 4),
                  border: Border.all(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_list_off_rounded,
                      size: responsive.iconSize - 4,
                      color: const Color(0xFF667EEA),
                    ),
                    SizedBox(width: responsive.spacingSmall),
                    Text(
                      l10n.showAllRoutes,
                      style: TextStyle(
                        fontSize: responsive.bodyFontSize,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF667EEA),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutesList(
      List<AdviceRouteListItem> routes, ResponsiveUtils responsive) {
    // No RefreshIndicator - advice routes are admin-curated and only fetched once on app launch
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        responsive.pagePaddingHorizontal,
        responsive.spacingMedium,
        responsive.pagePaddingHorizontal,
        responsive.spacingXL + 80,
      ),
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        final isLoading = _loadingRouteId == route.adviceRouteId;

        return Padding(
          padding: EdgeInsets.only(bottom: responsive.spacingMedium),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  (index * 0.1).clamp(0.0, 1.0),
                  ((index * 0.1) + 0.6).clamp(0.0, 1.0),
                  curve: Curves.easeOutCubic,
                ),
              ),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    (index * 0.1).clamp(0.0, 1.0),
                    ((index * 0.1) + 0.6).clamp(0.0, 1.0),
                    curve: Curves.easeOut,
                  ),
                ),
              ),
              child: AdviceRouteCard(
                route: route,
                responsive: responsive,
                isLoading: isLoading,
                onTap: () => _onRouteSelected(route),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onRouteSelected(AdviceRouteListItem route) async {
    // Prevent multiple taps
    if (_loadingRouteId != null) return;

    setState(() {
      _loadingRouteId = route.adviceRouteId;
    });

    try {
      // Fetch full route details and convert to RouteResult
      final selectionNotifier = ref.read(adviceRouteSelectionProvider.notifier);
      final routeResult =
          await selectionNotifier.selectAdviceRoute(route.adviceRouteId);

      if (mounted && routeResult != null) {
        // Navigate to route results screen
        ref
            .read(homeNavigationProvider.notifier)
            .navigateToRouteResults(routeResult);
      } else if (mounted) {
        // Show error
        final l10n = AppLocalizations.of(context)!;
        final error = ref.read(adviceRouteSelectionProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.error_outline_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    error ?? l10n.snackbarFailedLoadRouteDetails,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingRouteId = null;
        });
      }
    }
  }

  String _getFilterLabel(String filter, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (filter) {
      case 'All':
        return l10n.filterAll;
      case 'Walking':
        return l10n.filterWalking;
      case 'Transit':
        return l10n.filterTransit;
      case 'Driving':
        return l10n.filterDriving;
      default:
        return filter;
    }
  }
}

/// Full screen version with Scaffold (for standalone navigation)
class AdviceRoutesScreen extends ConsumerWidget {
  const AdviceRoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: AdviceRoutesScreenContent(),
    );
  }
}
