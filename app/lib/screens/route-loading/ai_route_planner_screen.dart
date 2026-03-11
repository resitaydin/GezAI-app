import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/ai_provider.dart';
import '../../utils/responsive_utils.dart';
import 'widgets/animated_route_path.dart';

/// Second phase loading screen - Premium AI Route Planner with animated map visualization
/// Shows for 4-6 seconds after the initial route loading screen
class AIRoutePlannerScreen extends ConsumerStatefulWidget {
  final VoidCallback? onCancel;
  final String transportMode; // 'walking', 'driving', 'transit'

  const AIRoutePlannerScreen({
    super.key,
    this.onCancel,
    this.transportMode = 'walking',
  });

  @override
  ConsumerState<AIRoutePlannerScreen> createState() =>
      _AIRoutePlannerScreenState();
}

class _AIRoutePlannerScreenState extends ConsumerState<AIRoutePlannerScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _travelController;
  late AnimationController _floatController;
  late AnimationController _rotateController;
  Timer? _completionTimer;

  // Loading messages that cycle
  int _currentMessageIndex = 0;
  Timer? _messageTimer;

  static List<String> _getLlmMessages(AppLocalizations l10n) => [
    l10n.aiCraftingRoute,
    l10n.findingBestSpots,
    l10n.personalizingJourney,
  ];

  static List<String> _getBackendMessages(AppLocalizations l10n) => [
    l10n.enrichingDetails,
    l10n.fetchingPhotos,
    l10n.finalizingItinerary,
  ];

  static List<String> _getLlmSubtitles(AppLocalizations l10n) => [
    l10n.analyzingPreferences,
    l10n.selectingLocations,
    l10n.creatingSequence,
  ];

  static List<String> _getBackendSubtitles(AppLocalizations l10n) => [
    l10n.gettingRealtimeData,
    l10n.loadingPlaceInfo,
    l10n.almostReady,
  ];

  /// Get current loading message based on phase
  String _getCurrentMessage(RouteGenerationPhase phase) {
    final l10n = AppLocalizations.of(context)!;
    final messages = phase == RouteGenerationPhase.backendProcessing
        ? _getBackendMessages(l10n)
        : _getLlmMessages(l10n);
    return messages[_currentMessageIndex % messages.length];
  }

  /// Get current subtitle based on phase
  String _getCurrentSubtitle(RouteGenerationPhase phase) {
    final l10n = AppLocalizations.of(context)!;
    final subtitles = phase == RouteGenerationPhase.backendProcessing
        ? _getBackendSubtitles(l10n)
        : _getLlmSubtitles(l10n);
    return subtitles[_currentMessageIndex % subtitles.length];
  }

  // Route points for the animated path (relative positions within the map container)
  static const List<Offset> _routePointsRatio = [
    Offset(0.18, 0.22), // Start point
    Offset(0.45, 0.38), // Mid point 1
    Offset(0.72, 0.28), // Mid point 2
    Offset(0.55, 0.65), // End point
  ];

  // Place data for pins
  static const List<Map<String, dynamic>> _places = [
    {
      'name': 'Galata Tower',
      'icon': Icons.flag_rounded,
      'ratio': Offset(0.18, 0.22),
      'color': Color(0xFF16509c),
    },
    {
      'name': 'Hagia Sophia',
      'icon': Icons.mosque_rounded,
      'ratio': Offset(0.72, 0.28),
      'color': Color(0xFF16509c),
    },
    {
      'name': 'Grand Bazaar',
      'icon': Icons.shopping_bag_rounded,
      'ratio': Offset(0.55, 0.65),
      'color': Color(0xFFFF6B6B),
    },
  ];

  @override
  void initState() {
    super.initState();

    // Progress animation (0 to 1 over the screen duration)
    // We'll control this based on generation phase
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..forward();

    // Shimmer animation for skeleton cards and effects
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Pulse animation for glowing effects
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Travel icon animation along the path
    _travelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Floating animation for the map card
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // Slow rotation for decorative elements
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Message cycling timer
    _messageTimer = Timer.periodic(const Duration(milliseconds: 1800), (timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % 3;
        });
      }
    });

    // Fallback timer - if generation takes too long, show timeout message
    // This is a safety net; normal flow uses state listening
    _completionTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        final phase = ref.read(routeGenerationPhaseProvider);
        final l10n = AppLocalizations.of(context)!;
        if (phase != RouteGenerationPhase.complete) {
          // Still not complete after 30 seconds, show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.snackbarRouteTakingLonger),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _travelController.dispose();
    _floatController.dispose();
    _rotateController.dispose();
    _messageTimer?.cancel();
    _completionTimer?.cancel();
    super.dispose();
  }

  IconData get _transportIcon {
    switch (widget.transportMode) {
      case 'driving':
        return Icons.directions_car_rounded;
      case 'transit':
        return Icons.directions_bus_rounded;
      default:
        return Icons.directions_walk_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Listen to route generation state changes
    ref.listen<RouteGenerationState>(routeGenerationProvider, (previous, current) {
      if (!mounted) return;

      if (current.phase == RouteGenerationPhase.complete && current.finalRoute != null) {
        // Route generation complete - navigate to ready screen
        context.go(AppRoutes.routeReady, extra: current.finalRoute);
      } else if (current.phase == RouteGenerationPhase.error) {
        // Show error and allow retry
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(current.error ?? l10n.snackbarErrorOccurred),
            action: SnackBarAction(
              label: l10n.retry,
              onPressed: () {
                // Go back to home to retry
                context.go(AppRoutes.home);
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Premium gradient background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8EEF8), // Light blue-gray
              Color(0xFFF0F4F8), // Very light gray
              Color(0xFFE5ECF5), // Soft blue
              Color(0xFFF5F7FA), // Almost white
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background circles
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
                                    SizedBox(height: responsive.spacingSmall),
                                    _buildFloatingMapCard(responsive),
                                    SizedBox(height: responsive.spacingMedium),
                                    _buildLoadingStatus(responsive),
                                  ],
                                ),
                                Column(
                                  children: [
                                    SizedBox(height: responsive.spacingMedium),
                                    _buildItinerarySection(responsive),
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
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return Stack(
          children: [
            // Large gradient circle top-right
            Positioned(
              top: -100,
              right: -80,
              child: Transform.rotate(
                angle: _rotateController.value * 2 * math.pi * 0.1,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF16509c).withValues(alpha: 0.08),
                        const Color(0xFF16509c).withValues(alpha: 0.02),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Medium circle bottom-left
            Positioned(
              bottom: 100,
              left: -60,
              child: Transform.rotate(
                angle: -_rotateController.value * 2 * math.pi * 0.05,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6366F1).withValues(alpha: 0.06),
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
      child: Row(
        children: [
          // Back button with glassmorphism
          // GestureDetector(
          //   onTap: widget.onCancel,
          //   child: Container(
          //     width: 48,
          //     height: 48,
          //     decoration: BoxDecoration(
          //       color: Colors.white.withValues(alpha: 0.8),
          //       shape: BoxShape.circle,
          //       border: Border.all(
          //         color: Colors.white,
          //         width: 2,
          //       ),
          //       boxShadow: [
          //         BoxShadow(
          //           color: const Color(0xFF16509c).withValues(alpha: 0.1),
          //           blurRadius: 20,
          //           offset: const Offset(0, 4),
          //         ),
          //       ],
          //     ),
          //     child: const Icon(
          //       Icons.arrow_back_rounded,
          //       color: Color(0xFF1A1A2E),
          //       size: 22,
          //     ),
          //   ),
          // ),
          // Title with gradient
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16509c)],
              ).createShader(bounds),
              child: Text(
                AppLocalizations.of(context)!.tripPlanner,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingMapCard(ResponsiveUtils responsive) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset = math.sin(_floatController.value * math.pi) * 6;

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  // Primary shadow with color
                  BoxShadow(
                    color: const Color(0xFF16509c).withValues(alpha: 0.2),
                    blurRadius: 50,
                    offset: const Offset(0, 20),
                    spreadRadius: -5,
                  ),
                  // Soft ambient shadow
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        // Map background image
                        AspectRatio(
                          aspectRatio: responsive.mapCardAspectRatio,
                          child: Image.asset(
                            'assets/images/map.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback gradient map
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFE8F4F8),
                                      Color(0xFFF0F8FF),
                                      Color(0xFFE5F0F5),
                                    ],
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: _MapPatternPainter(),
                                ),
                              );
                            },
                          ),
                        ),
                        // Gradient overlay for better contrast
                        AspectRatio(
                          aspectRatio: responsive.mapCardAspectRatio,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.4),
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.white.withValues(alpha: 0.3),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Vignette effect
                        AspectRatio(
                          aspectRatio: responsive.mapCardAspectRatio,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 0.9,
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Route and pins layer
                        AspectRatio(
                          aspectRatio: responsive.cardAspectRatio,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final height = constraints.maxHeight;

                              final routePoints = _routePointsRatio
                                  .map((r) => Offset(r.dx * width, r.dy * height))
                                  .toList();

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Animated dashed route path
                                  AnimatedRoutePath(
                                    points: routePoints,
                                    color: const Color(0xFF16509c),
                                    strokeWidth: 3.5,
                                    dashLength: 12,
                                    gapLength: 8,
                                  ),
                                  // Place pins
                                  ..._buildPlacePins(width, height),
                                  // Traveling icon
                                  _buildTravelingIcon(routePoints),
                                ],
                              );
                            },
                          ),
                        ),
                        // Top shine effect
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPlacePins(double width, double height) {
    return List.generate(_places.length, (index) {
      final place = _places[index];
      final ratio = place['ratio'] as Offset;
      final position = Offset(ratio.dx * width, ratio.dy * height);
      final isLast = index == _places.length - 1;

      return Positioned(
        left: position.dx - 28,
        top: position.dy - 28,
        child: _buildPremiumPin(
          label: place['name'] as String,
          icon: place['icon'] as IconData,
          color: place['color'] as Color,
          isDestination: isLast,
          showLabel: !isLast,
          index: index,
        ),
      );
    });
  }

  Widget _buildPremiumPin({
    required String label,
    required IconData icon,
    required Color color,
    bool isDestination = false,
    bool showLabel = true,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = isDestination ? 1.0 + (_pulseController.value * 0.08) : 1.0;

        return Transform.scale(
          scale: pulse,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pin container with glow
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: isDestination ? 20 : 12,
                      spreadRadius: isDestination ? 2 : 0,
                    ),
                  ],
                ),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color,
                        color.withValues(alpha: 0.85),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              // Label with glassmorphism
              if (showLabel) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTravelingIcon(List<Offset> routePoints) {
    final pathCalculator = PathPositionCalculator(routePoints);

    return AnimatedBuilder(
      animation: _travelController,
      builder: (context, child) {
        final position = pathCalculator.getPositionAtProgress(_travelController.value);

        return Positioned(
          left: position.dx - 24,
          top: position.dy - 50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Time badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF16509c), Color(0xFF1E6AC0)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF16509c).withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  '12 min',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Icon with pulsing glow
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF16509c)
                              .withValues(alpha: 0.3 + (_pulseController.value * 0.2)),
                          blurRadius: 16 + (_pulseController.value * 8),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF16509c).withValues(alpha: 0.3),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _transportIcon,
                        color: const Color(0xFF16509c),
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingStatus(ResponsiveUtils responsive) {
    final phase = ref.watch(routeGenerationPhaseProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          // Animated title with gradient
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            child: ShaderMask(
              key: ValueKey('${phase.name}_$_currentMessageIndex'),
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16509c)],
              ).createShader(bounds),
              child: Text(
                _getCurrentMessage(phase),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.titleFontSize,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
            ),
          ),
          SizedBox(height: responsive.spacingMedium),
          // Premium progress bar
          _buildPremiumProgressBar(),
          const SizedBox(height: 14),
          // Subtitle with animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Row(
              key: ValueKey('subtitle_${phase.name}_$_currentMessageIndex'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF16509c)
                            .withValues(alpha: 0.5 + (_pulseController.value * 0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF16509c)
                                .withValues(alpha: _pulseController.value * 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Text(
                  _getCurrentSubtitle(phase),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B).withValues(alpha: 0.9),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumProgressBar() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Container(
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: const Color(0xFFE2E8F0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
                blurStyle: BlurStyle.inner,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Progress fill with gradient
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressController.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF16509c),
                        Color(0xFF4F7DC0),
                        Color(0xFF6366F1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF16509c).withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              // Shimmer effect
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressController.value,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: FractionallySizedBox(
                              widthFactor: 0.4,
                              alignment: Alignment(
                                (_shimmerController.value * 4) - 1,
                                0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withValues(alpha: 0.5),
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
              ),
              // Leading glow dot
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Positioned(
                    left: (_progressController.value *
                            (MediaQuery.of(context).size.width - 56)) -
                        5,
                    top: 0,
                    bottom: 0,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white
                                    .withValues(alpha: 0.5 + (_pulseController.value * 0.5)),
                                blurRadius: 8 + (_pulseController.value * 4),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItinerarySection(ResponsiveUtils responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.suggestedItineraries,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 10),
              // Animated loading dots
              _buildLoadingDots(),
            ],
          ),
        ),
        SizedBox(height: responsive.spacingSmall),
        // Premium skeleton cards
        SizedBox(
          height: responsive.carouselHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < 2 ? 16 : 0),
                child: _buildPremiumSkeletonCard(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            final delay = index * 0.2;
            final progress = ((_shimmerController.value + delay) % 1.0);
            final opacity = (math.sin(progress * math.pi)).clamp(0.3, 1.0);

            return Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF16509c).withValues(alpha: opacity),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildPremiumSkeletonCard(int index) {
    final responsive = ResponsiveUtils.of(context);
    final opacity = 1.0 - (index * 0.2);
    final isSmall = responsive.isCompact;
    final cardPadding = isSmall ? 10.0 : 14.0;
    // Image height scales with carousel to always fit: carousel - padding*2 - some breathing room
    final imageHeight = (responsive.carouselHeight - cardPadding * 2 - 8).clamp(90.0, 150.0);

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Opacity(
          opacity: opacity,
          child: Container(
            width: isSmall ? 230 : 260,
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF16509c).withValues(alpha: 0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFF0F4F8),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Image placeholder with gradient shimmer
                Container(
                  width: isSmall ? 60 : 75,
                  height: imageHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment(_shimmerController.value * 3 - 1, 0),
                      end: Alignment(_shimmerController.value * 3, 0),
                      colors: const [
                        Color(0xFFE8EEF4),
                        Color(0xFFF5F8FA),
                        Color(0xFFE8EEF4),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: isSmall ? 10 : 14),
                // Content placeholders
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildShimmerLine(width: double.infinity, height: isSmall ? 14 : 16),
                      SizedBox(height: isSmall ? 8 : 10),
                      _buildShimmerLine(width: 100, height: 12),
                      SizedBox(height: isSmall ? 14 : 18),
                      _buildShimmerLine(width: double.infinity, height: isSmall ? 32 : 38),
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

  Widget _buildShimmerLine({required double width, required double height}) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: LinearGradient(
              begin: Alignment(_shimmerController.value * 3 - 1, 0),
              end: Alignment(_shimmerController.value * 3, 0),
              colors: const [
                Color(0xFFE8EEF4),
                Color(0xFFF8FAFC),
                Color(0xFFE8EEF4),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for abstract map pattern (fallback)
class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0E0EB).withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid lines to simulate map roads
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height * 0.3, size.height),
        paint,
      );
    }
    for (double i = 0; i < size.height; i += 25) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i + size.width * 0.2),
        paint,
      );
    }

    // Draw some circular "landmarks"
    final landmarkPaint = Paint()
      ..color = const Color(0xFFB8D4E8).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), 15, landmarkPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.3), 12, landmarkPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.7), 18, landmarkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
