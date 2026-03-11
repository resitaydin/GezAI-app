import 'package:flutter/material.dart';

/// An animated map pin that bounces and displays a category icon
class AnimatedMapPin extends StatefulWidget {
  final IconData icon;
  final Duration animationDuration;
  final Duration delay;
  final Color backgroundColor;

  const AnimatedMapPin({
    super.key,
    required this.icon,
    this.animationDuration = const Duration(milliseconds: 2000),
    this.delay = Duration.zero,
    this.backgroundColor = const Color(0xFF16509c),
  });

  @override
  State<AnimatedMapPin> createState() => _AnimatedMapPinState();
}

class _AnimatedMapPinState extends State<AnimatedMapPin>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _scaleController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  bool _started = false;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _shadowAnimation = Tween<double>(begin: 1, end: 0.6).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _started = true);
        _scaleController.forward();
        _bounceController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) {
      return const SizedBox(width: 50, height: 70);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_bounceAnimation, _scaleAnimation]),
      builder: (context, child) {
        final bounce = _bounceAnimation.value * 10;
        final scale = _scaleAnimation.value;
        final shadowScale = _shadowAnimation.value;

        return SizedBox(
          width: 50,
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shadow at the bottom
              Positioned(
                bottom: 0,
                child: Transform.scale(
                  scale: shadowScale,
                  child: Container(
                    width: 20,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              // Pin body
              Positioned(
                bottom: 8 + bounce,
                child: Transform.scale(
                  scale: scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pin head with gradient
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.backgroundColor,
                              Color.lerp(
                                widget.backgroundColor,
                                Colors.black,
                                0.2,
                              )!,
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.backgroundColor.withValues(alpha: 0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),

                      // Pin pointer/stick
                      ClipPath(
                        clipper: _PinPointerClipper(),
                        child: Container(
                          width: 14,
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                widget.backgroundColor,
                                Color.lerp(
                                  widget.backgroundColor,
                                  Colors.black,
                                  0.3,
                                )!,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom clipper for the pin pointer triangle
class _PinPointerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
