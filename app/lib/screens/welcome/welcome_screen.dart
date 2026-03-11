import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/onboarding_provider.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          // Background Layer with Image and Gradient Overlay
          Positioned.fill(
            child: Container(
              color: const Color(0xFF1E3A5F), // istanbul-blue
              child: Stack(
                children: [
                  // Background Image with Overlay
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.4,
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAi-6QHB67EDDbDDqSjpijHGGcHQcJytpKJVuA15oI3BG0WSG0R36FDlTyynM-ln5-3nED08L-0fZW9iG9QtC3EUFJ43NsrUj-1evpVvb6-tkns8TrsaMX6hpmUp_vcYWcIKPwCkTbsv2hCKPWg7uolGjTVbVyu1_JUQ9KlOfNW0CPhgfbqguAB08tgSwxnpkAtb1cMoJtk6f9GQBvWJ6FkgdX0dUawYNNmGcVpD6H6k12P7fr4fb_s2j-EsIVCIWVBZeczZmVqQIET',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF1f3b61).withOpacity(0.9),
                            const Color(0xFF1f3b61).withOpacity(0.8),
                            const Color(0xFF1f3b61),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bottom Gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 256,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Decorative Elements
          const _FloatingDecorations(),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                  // Top Section: Branding
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      // Logo Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mosque,
                          size: 40,
                          color: Color(0xFFF59E0B), // istanbul-gold
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Headline
                      Text(
                        l10n.welcomeTitle,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Tagline
                      Text(
                        l10n.welcomeTagline,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Middle Section: Feature Card
                  const _FeatureCard(),

                  const SizedBox(height: 40),

                  // Bottom Section: Actions
                  Column(
                    children: [
                      // Get Started Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            context.go(AppRoutes.signup);
                            ref
                                .read(onboardingControllerProvider.notifier)
                                .completeOnboarding();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF2DD4BF), // istanbul-teal
                            foregroundColor: const Color(0xFF1E3A5F),
                            elevation: 8,
                            shadowColor:
                                const Color(0xFF2DD4BF).withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.welcomeGetStarted,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Secondary Link
                      TextButton(
                        onPressed: () {
                          context.go(AppRoutes.login);
                          ref
                              .read(onboardingControllerProvider.notifier)
                              .completeOnboarding();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withOpacity(0.7),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: Text(
                          l10n.welcomeAlreadyHaveAccount,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}

class _FloatingDecorations extends StatelessWidget {
  const _FloatingDecorations();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top Right Cloud
        Positioned(
          top: MediaQuery.of(context).size.height * 0.15,
          right: MediaQuery.of(context).size.width * 0.1,
          child: _FloatingIcon(
            icon: Icons.cloud_outlined,
            size: 60,
            color: Colors.white.withOpacity(0.1),
            duration: const Duration(seconds: 6),
          ),
        ),
        // Middle Left Flight
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          left: MediaQuery.of(context).size.width * 0.05,
          child: _FloatingIcon(
            icon: Icons.flight,
            size: 50,
            color: const Color(0xFFF59E0B).withOpacity(0.2),
            duration: const Duration(seconds: 7),
            delay: const Duration(seconds: 2),
          ),
        ),
        // Bottom Right Location
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.25,
          right: MediaQuery.of(context).size.width * 0.15,
          child: _FloatingIcon(
            icon: Icons.location_on,
            size: 40,
            color: Colors.white.withOpacity(0.1),
            duration: const Duration(seconds: 6),
          ),
        ),
      ],
    );
  }
}

class _FloatingIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Duration duration;
  final Duration delay;

  const _FloatingIcon({
    required this.icon,
    required this.size,
    required this.color,
    required this.duration,
    this.delay = Duration.zero,
  });

  @override
  State<_FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<_FloatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -10),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -10, end: 0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _FeatureCard extends ConsumerWidget {
  const _FeatureCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Transform.rotate(
      angle: -0.035, // -2 degrees in radians
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 280,
          maxHeight: 320,
        ),
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDDHl3-jD-x3xlQsNu9LYiajEyiWnI7wRQlqCMtoJzt8MW5nANJqRbfoZOz8KSbT-ohutzIEJxNMrs319cfQvu542MkvtIBGFmVi1T2mW5QDrlve86za_ZXnl8PXdmvLU7lDFEfbvOTCOqiAlRBhaX0Ciu2cJ5RieaGJqk_3mP5D3lMbtWx-1NlVlqzxbhTokiUCj4cN991CU1wv7hvr6ee7Bg-oZ3HtStPQubfW-yUqsRzZIvHIC0WqXl5MQz9ooNLrKzQ1BVRNhui',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Pick Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Color(0xFF1E3A5F),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.welcomeTopPick,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E3A5F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Title
                          Text(
                            l10n.welcomeHistoricalPeninsula,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Duration
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.welcomeRouteHours(4),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
