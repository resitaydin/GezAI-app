import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/ai_provider.dart';
import '../../providers/route_preferences_provider.dart';
import '../../utils/responsive_utils.dart';
import 'widgets/shimmer_place_card.dart';

/// Route loading screen with animated phases while AI generates the route
/// Phase 1: Shows for ~6 seconds with step-based animations
/// Then transitions to AIRoutePlannerScreen (Phase 2)
class RouteLoadingScreen extends ConsumerStatefulWidget {
  final VoidCallback? onCancel;
  final String transportMode;

  const RouteLoadingScreen({
    super.key,
    this.onCancel,
    this.transportMode = 'walking',
  });

  @override
  ConsumerState<RouteLoadingScreen> createState() => _RouteLoadingScreenState();
}

class _RouteLoadingScreenState extends ConsumerState<RouteLoadingScreen>
    with TickerProviderStateMixin {
  int _currentStep = 1;
  Timer? _stepTimer;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  // Get localized loading messages for each step
  List<String> _getStepMessages(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.routeLoadingStep1Message,
      l10n.routeLoadingStep2Message,
      l10n.routeLoadingStep3Message,
    ];
  }

  // Get localized step labels
  List<String> _getStepLabels(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.routeLoadingStep1Label,
      l10n.routeLoadingStep2Label,
      l10n.routeLoadingStep3Label,
    ];
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _startStepProgression();
    _startRouteGeneration();
  }

  /// Start the actual route generation process
  void _startRouteGeneration() {
    // Use Future.microtask to ensure we have access to ref after initState
    Future.microtask(() {
      if (!mounted) return;

      // Read user preferences
      final preferences = ref.read(routePreferencesProvider);

      // Build prompt from preferences
      final prompt = preferences.buildPrompt();

      // Get transport mode from preferences or use the one passed to widget
      final transportMode = preferences.selectedTransport?.id ?? widget.transportMode;

      // Calculate max places based on duration preference
      int maxPlaces = 5;
      if (preferences.durationPreference != null) {
        final hours = preferences.durationPreference!.maxHours;
        // Roughly 1 place per 30-45 minutes, capped at 2-10
        maxPlaces = (hours * 1.5).round().clamp(2, 10);
      }

      // Start route generation
      ref.read(routeGenerationProvider.notifier).generateRoute(
            prompt,
            transportMode,
            maxPlaces: maxPlaces,
          );
    });
  }

  void _startStepProgression() {
    _stepTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentStep < 3) {
        setState(() {
          _currentStep++;
        });
      } else {
        timer.cancel();
        // Transition to Phase 2: AI Route Planner screen
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go(AppRoutes.aiRoutePlanner, extra: widget.transportMode);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use centralized responsive utilities for all device sizes
    final responsive = ResponsiveUtils.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Warm gradient background like Figma
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8D5B7), // Warm beige/tan at top
              Color(0xFFE8D5B7), // Sage green in middle
              Color(0xFF8FA5A0), // Muted teal
              Color(0xFFF5F5F5), // Light gray at bottom
            ],
            stops: [0.0, 0.35, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(responsive),
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
                                _buildAnimatedTitle(responsive),
                                SizedBox(height: responsive.spacingMedium),
                                _buildMapCard(responsive),
                                SizedBox(height: responsive.spacingMedium),
                                _buildProgressSection(responsive),
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(height: responsive.spacingMedium),
                                _buildPlaceCarousel(responsive),
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
      ),
    );
  }

  Widget _buildHeader(ResponsiveUtils responsive) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.fromLTRB(4, responsive.spacingXS, 8, 0),
      child: Row(
        children: [
          // // Close button with glass effect
          // GestureDetector(
          //   onTap: widget.onCancel,
          //   child: Container(
          //     width: 44,
          //     height: 44,
          //     margin: const EdgeInsets.all(4),
          //     decoration: BoxDecoration(
          //       color: Colors.white.withValues(alpha: 0.3),
          //       shape: BoxShape.circle,
          //       border: Border.all(
          //         color: Colors.white.withValues(alpha: 0.5),
          //         width: 1,
          //       ),
          //     ),
          //     child: const Icon(
          //       Icons.close_rounded,
          //       color: Color(0xFF1A1A2E),
          //       size: 22,
          //     ),
          //   ),
          // ),
          // Title
          Expanded(
            child: Text(
              l10n.routeLoadingTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.3,
              ),
            ),
          ),
          // // Cancel button
          // TextButton(
          //   onPressed: widget.onCancel,
          //   style: TextButton.styleFrom(
          //     foregroundColor: const Color(0xFF16509c),
          //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //   ),
          //   child: const Text(
          //     'Cancel',
          //     style: TextStyle(
          //       fontSize: 15,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTitle(ResponsiveUtils responsive) {
    final stepMessages = _getStepMessages(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: Text(
          stepMessages[_currentStep - 1],
          key: ValueKey(_currentStep),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: responsive.titleFontSize,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A2E),
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  // Step images paths
  static const List<String> _stepImages = [
    'assets/images/step1.png',
    'assets/images/step2.png',
    'assets/images/step3.png',
  ];

  Widget _buildMapCard(ResponsiveUtils responsive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          border: Border.all(color: Colors.white, width: 5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: AspectRatio(
            // Aspect ratio adapts to screen size
            aspectRatio: responsive.cardAspectRatio,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: Image.asset(
                _stepImages[_currentStep - 1],
                key: ValueKey(_currentStep),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image not found
                  return Container(
                    color: const Color(0xFFF0EDE5),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 48,
                            color: const Color(0xFF16509c).withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Step $_currentStep',
                            style: TextStyle(
                              color: const Color(0xFF16509c).withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(ResponsiveUtils responsive) {
    final l10n = AppLocalizations.of(context)!;
    final stepLabels = _getStepLabels(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          // Step label row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF16509c),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.routeLoadingStep(_currentStep),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.5 + (_pulseController.value * 0.5),
                    child: Text(
                      l10n.routeLoadingStatus,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                        letterSpacing: 1.5,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar segments
          Row(
            children: List.generate(3, (index) {
              final isActive = index < _currentStep;
              final isCurrent = index == _currentStep - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 2 ? 8 : 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: isActive
                          ? const Color(0xFF16509c)
                          : const Color(0xFFDBE4EE),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: const Color(0xFF16509c)
                                    .withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: isCurrent
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: AnimatedBuilder(
                              animation: _shimmerController,
                              builder: (context, child) {
                                return Stack(
                                  children: [
                                    Positioned.fill(
                                      child: FractionallySizedBox(
                                        widthFactor: 0.4,
                                        alignment: Alignment(
                                          (_shimmerController.value * 3) - 1,
                                          0,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                Colors.white
                                                    .withValues(alpha: 0.5),
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
                          )
                        : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // Step description
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              stepLabels[_currentStep - 1],
              key: ValueKey(_currentStep),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCarousel(ResponsiveUtils responsive) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with spinning icon
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Row(
            children: [
              Text(
                l10n.routeLoadingPlacesConsidering,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _shimmerController.value * 2 * math.pi,
                    child: Icon(
                      Icons.sync_rounded,
                      size: 16,
                      color: const Color(0xFF16509c).withValues(alpha: 0.8),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(height: responsive.spacingSmall),

        // Horizontal scrolling cards - height scales with screen
        SizedBox(
          height: responsive.carouselHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < 3 ? 12 : 0),
                child: const ShimmerPlaceCard(),
              );
            },
          ),
        ),
      ],
    );
  }
}
