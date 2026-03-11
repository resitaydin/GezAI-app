import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/router.dart';
import '../../l10n/app_localizations.dart';
import '../../models/route_result.dart';
import '../../providers/home_navigation_provider.dart';
import '../../utils/responsive_utils.dart';

/// Final screen - Premium "Your Route is Ready" celebration screen
/// Shows after AI Route Planner screen with beautiful animations
class RouteReadyScreen extends ConsumerStatefulWidget {
  final VoidCallback? onCancel;
  final String transportMode;
  final RouteResult? routeResult;

  const RouteReadyScreen({
    super.key,
    this.onCancel,
    this.transportMode = 'walking',
    this.routeResult,
  });

  @override
  ConsumerState<RouteReadyScreen> createState() => _RouteReadyScreenState();
}

class _RouteReadyScreenState extends ConsumerState<RouteReadyScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _confettiController;
  late AnimationController _shimmerController;
  late AnimationController _floatController;

  late Animation<double> _checkmarkAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Checkmark draw animation
    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _checkmarkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _checkmarkController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Scale bounce animation for the success circle
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    // Fade and slide for content
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Continuous pulse for glow effects
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Confetti animation
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Shimmer for button
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Floating animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    // Start animations sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    _confettiController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _checkmarkController.forward();
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    _shimmerController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _navigateToRouteResults() {
    // Get the route result (either from widget or use sample data as fallback)
    final routeResult = widget.routeResult ?? RouteResult.sampleData();

    // Set bottom navigation to index 1 (route results tab) with the route data
    ref.read(homeNavigationProvider.notifier).navigateToRouteResults(routeResult);
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Gradient overlay for better readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.85),
                    Colors.white.withValues(alpha: 0.75),
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),
          // Confetti particles
          _buildConfetti(),
          // Background decorations
          _buildBackgroundDecorations(),
          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  SizedBox(height: responsive.spacingLarge),
                                  _buildSuccessIcon(responsive),
                                  SizedBox(height: responsive.spacingMedium),
                                  _buildTitle(responsive),
                                  SizedBox(height: responsive.spacingSmall),
                                  _buildSubtitle(responsive),
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(height: responsive.spacingMedium),
                                  _buildRoutePreviewCard(responsive),
                                  SizedBox(height: responsive.spacingMedium),
                                  _buildViewRouteButton(responsive),
                                  SizedBox(height: responsive.spacingSmall),
                                  _buildSecondaryAction(),
                                  SizedBox(height: responsive.spacingLarge),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfetti() {
    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            progress: _confettiController.value,
            colors: const [
              Color(0xFF16509c),
              Color(0xFF6366F1),
              Color(0xFF22C55E),
              Color(0xFFF59E0B),
              Color(0xFFEF4444),
              Color(0xFF8B5CF6),
            ],
          ),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }

  Widget _buildBackgroundDecorations() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          children: [
            // Large circle top right
            Positioned(
              top: -50,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF16509c).withValues(alpha: 0.08 + (_pulseController.value * 0.04)),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Small circle bottom left
            Positioned(
              bottom: 150,
              left: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF22C55E).withValues(alpha: 0.06 + (_pulseController.value * 0.03)),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
            child: Row(
              // children: [
              //   GestureDetector(
              //     onTap: widget.onCancel,
              //     child: Container(
              //       width: 48,
              //       height: 48,
              //       decoration: BoxDecoration(
              //         color: Colors.white,
              //         shape: BoxShape.circle,
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.black.withValues(alpha: 0.08),
              //             blurRadius: 20,
              //             offset: const Offset(0, 4),
              //           ),
              //         ],
              //       ),
              //       child: const Icon(
              //         Icons.close_rounded,
              //         color: Color(0xFF64748B),
              //         size: 22,
              //       ),
              //     ),
              //   ),
              //   const Spacer(),
              // ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessIcon(ResponsiveUtils responsive) {
    // Responsive icon size - only shrink on very compact screens
    final iconSize = responsive.successIconSize;
    final ringBaseSize = iconSize * 1.17; // 140/120 ratio
    final floatAmount = responsive.isVeryCompact ? 5.0 : 8.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _pulseController, _floatController]),
      builder: (context, child) {
        final floatOffset = math.sin(_floatController.value * math.pi) * floatAmount;

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow rings
                ...List.generate(3, (index) {
                  final scale = 1.0 + (index * 0.25) + (_pulseController.value * 0.1);
                  final opacity = (0.15 - (index * 0.04)) * (1 - _pulseController.value * 0.3);

                  return Container(
                    width: ringBaseSize * scale,
                    height: ringBaseSize * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF22C55E).withValues(alpha: opacity),
                        width: 2,
                      ),
                    ),
                  );
                }),
                // Main success circle
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF22C55E),
                        Color(0xFF16A34A),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.4 + (_pulseController.value * 0.2)),
                        blurRadius: 30 + (_pulseController.value * 10),
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _checkmarkAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: CheckmarkPainter(
                          progress: _checkmarkAnimation.value,
                          color: Colors.white,
                          strokeWidth: 5,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle(ResponsiveUtils responsive) {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16509c)],
              ).createShader(bounds),
              child: Text(
                AppLocalizations.of(context)!.routeReady,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.titleFontSize,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle(ResponsiveUtils responsive) {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.8),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.isVeryCompact ? 28 : 40),
              child: Text(
                AppLocalizations.of(context)!.routeReadySubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.isVeryCompact ? 14 : 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B).withValues(alpha: 0.9),
                  height: 1.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoutePreviewCard(ResponsiveUtils responsive) {
    // Get route data for display
    final route = widget.routeResult;
    final placesCount = route?.stopsCount ?? 5;
    final durationHours = route?.totalDurationHours ?? 3.5;
    final distanceKm = route?.totalDistanceKm ?? 4.2;

    // Format duration string
    String durationStr;
    if (durationHours < 1) {
      durationStr = '${(durationHours * 60).round()}m';
    } else {
      final hours = durationHours.floor();
      final mins = ((durationHours - hours) * 60).round();
      durationStr = mins > 0 ? '$hours.${mins}h' : '${hours}h';
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _floatController]),
      builder: (context, child) {
        final floatOffset = math.sin(_floatController.value * math.pi) * 4;

        // Only apply smaller sizing on very compact screens
        final isVerySmall = responsive.isVeryCompact;

        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.5 + floatOffset),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isVerySmall ? 20 : 24),
              child: Container(
                padding: EdgeInsets.all(isVerySmall ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(responsive.cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF16509c).withValues(alpha: 0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFF0F4F8),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Route stats row - now shows real data
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.place_rounded,
                          value: '$placesCount',
                          label: AppLocalizations.of(context)!.placesLabel,
                          color: const Color(0xFF16509c),
                          isSmall: isVerySmall,
                        ),
                        _buildStatDivider(isSmall: isVerySmall),
                        _buildStatItem(
                          icon: Icons.schedule_rounded,
                          value: durationStr,
                          label: AppLocalizations.of(context)!.durationLabel,
                          color: const Color(0xFF6366F1),
                          isSmall: isVerySmall,
                        ),
                        _buildStatDivider(isSmall: isVerySmall),
                        _buildStatItem(
                          icon: Icons.straighten_rounded,
                          value: distanceKm.toStringAsFixed(1),
                          label: AppLocalizations.of(context)!.kmLabel,
                          color: const Color(0xFF22C55E),
                          isSmall: isVerySmall,
                        ),
                      ],
                    ),
                    SizedBox(height: isVerySmall ? 16 : 20),
                    // Route preview mini - show actual place icons if available
                    Container(
                      height: isVerySmall ? 52 : 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(responsive.borderRadius),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: _buildMiniRoutePreview(route, isSmall: isVerySmall),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build mini route preview showing place icons
  Widget _buildMiniRoutePreview(RouteResult? route, {bool isSmall = false}) {
    if (route == null || route.stops.isEmpty) {
      // Fallback to default icons
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMiniPin(Icons.flag_rounded, const Color(0xFF16509c), isSmall: isSmall),
          _buildRouteDots(isSmall: isSmall),
          _buildMiniPin(Icons.mosque_rounded, const Color(0xFF16509c), isSmall: isSmall),
          _buildRouteDots(isSmall: isSmall),
          _buildMiniPin(Icons.restaurant_rounded, const Color(0xFF16509c), isSmall: isSmall),
          _buildRouteDots(isSmall: isSmall),
          _buildMiniPin(Icons.park_rounded, const Color(0xFF16509c), isSmall: isSmall),
          _buildRouteDots(isSmall: isSmall),
          _buildMiniPin(Icons.shopping_bag_rounded, const Color(0xFFFF6B6B), isSmall: isSmall),
        ],
      );
    }

    // Show up to 5 stops with their category icons
    final stops = route.stops.take(5).toList();
    final widgets = <Widget>[];

    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final isLast = i == stops.length - 1;
      final icon = _getCategoryIcon(stop.category);
      final color = isLast ? const Color(0xFFFF6B6B) : const Color(0xFF16509c);

      widgets.add(_buildMiniPin(icon, color, isSmall: isSmall));
      if (!isLast) {
        widgets.add(_buildRouteDots(isSmall: isSmall));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets,
    );
  }

  /// Get icon for place category
  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'mosque':
        return Icons.mosque_rounded;
      case 'museum':
        return Icons.museum_rounded;
      case 'park':
        return Icons.park_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'cafe':
        return Icons.coffee_rounded;
      case 'attraction':
        return Icons.attractions_rounded;
      case 'historical':
        return Icons.account_balance_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    bool isSmall = false,
  }) {
    final iconContainerSize = isSmall ? 36.0 : 44.0;
    final iconSize = isSmall ? 18.0 : 22.0;
    final valueFontSize = isSmall ? 16.0 : 20.0;
    final labelFontSize = isSmall ? 10.0 : 12.0;

    return Column(
      children: [
        Container(
          width: iconContainerSize,
          height: iconContainerSize,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: iconSize,
          ),
        ),
        SizedBox(height: isSmall ? 6 : 8),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B).withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider({bool isSmall = false}) {
    return Container(
      width: 1,
      height: isSmall ? 40 : 50,
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget _buildMiniPin(IconData icon, Color color, {bool isSmall = false}) {
    final pinSize = isSmall ? 26.0 : 32.0;
    final iconSize = isSmall ? 13.0 : 16.0;

    return Container(
      width: pinSize,
      height: pinSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }

  Widget _buildRouteDots({bool isSmall = false}) {
    final dotSize = isSmall ? 3.0 : 4.0;
    final padding = isSmall ? 2.0 : 4.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        children: List.generate(3, (index) {
          return Container(
            width: dotSize,
            height: dotSize,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: const Color(0xFF16509c).withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildViewRouteButton(ResponsiveUtils responsive) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _shimmerController, _pulseController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.3),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: _navigateToRouteResults,
                child: Container(
                  width: double.infinity,
                  height: responsive.buttonHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF16509c),
                        Color(0xFF1E6AC0),
                        Color(0xFF2563EB),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF16509c).withValues(alpha: 0.4 + (_pulseController.value * 0.1)),
                        blurRadius: 20 + (_pulseController.value * 5),
                        offset: const Offset(0, 8),
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Shimmer effect
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: FractionallySizedBox(
                                    widthFactor: 0.3,
                                    alignment: Alignment(
                                      (_shimmerController.value * 4) - 1.5,
                                      0,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.white.withValues(alpha: 0.2),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      // Button content
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.viewMyRoute,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecondaryAction() {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
        );
      },
    );
  }
}

/// Custom painter for animated checkmark
class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CheckmarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final checkmarkSize = size.width * 0.35;

    // Checkmark path points (relative to center)
    final start = Offset(center.dx - checkmarkSize * 0.5, center.dy);
    final mid = Offset(center.dx - checkmarkSize * 0.1, center.dy + checkmarkSize * 0.35);
    final end = Offset(center.dx + checkmarkSize * 0.5, center.dy - checkmarkSize * 0.3);

    final path = Path();
    path.moveTo(start.dx, start.dy);

    // First segment (start to mid)
    final firstSegmentProgress = (progress * 2).clamp(0.0, 1.0);
    if (firstSegmentProgress > 0) {
      final firstEnd = Offset.lerp(start, mid, firstSegmentProgress)!;
      path.lineTo(firstEnd.dx, firstEnd.dy);
    }

    // Second segment (mid to end)
    final secondSegmentProgress = ((progress - 0.5) * 2).clamp(0.0, 1.0);
    if (secondSegmentProgress > 0) {
      final secondEnd = Offset.lerp(mid, end, secondSegmentProgress)!;
      path.lineTo(secondEnd.dx, secondEnd.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Custom painter for confetti animation
class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final math.Random random = math.Random(42); // Fixed seed for consistent positions

  ConfettiPainter({
    required this.progress,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()..style = PaintingStyle.fill;

    // Generate confetti particles
    for (int i = 0; i < 50; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = -20.0 - (random.nextDouble() * 100);

      // Calculate position based on progress
      final endY = size.height + 50;
      final currentY = startY + (endY - startY) * progress;

      // Add some horizontal drift
      final drift = math.sin(progress * math.pi * 2 + i) * 30;
      final currentX = startX + drift;

      // Fade out towards the end
      final opacity = (1 - progress).clamp(0.0, 1.0);

      if (currentY > 0 && currentY < size.height && opacity > 0) {
        paint.color = colors[i % colors.length].withValues(alpha: opacity * 0.8);

        // Rotate particles
        final rotation = progress * math.pi * 4 + i;

        canvas.save();
        canvas.translate(currentX, currentY);
        canvas.rotate(rotation);

        // Draw different shapes
        if (i % 3 == 0) {
          // Rectangle
          canvas.drawRect(
            const Rect.fromLTWH(-4, -2, 8, 4),
            paint,
          );
        } else if (i % 3 == 1) {
          // Circle
          canvas.drawCircle(Offset.zero, 4, paint);
        } else {
          // Triangle
          final path = Path()
            ..moveTo(0, -4)
            ..lineTo(4, 4)
            ..lineTo(-4, 4)
            ..close();
          canvas.drawPath(path, paint);
        }

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
