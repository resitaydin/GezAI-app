import 'package:flutter/material.dart';

/// Map pin with icon and label for route visualization
class RouteMapPin extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final bool isActive;
  final bool showLabel;
  final double scale;
  final bool animate;

  const RouteMapPin({
    super.key,
    required this.label,
    this.icon = Icons.location_on,
    this.backgroundColor = const Color(0xFF16509c),
    this.iconColor = Colors.white,
    this.isActive = true,
    this.showLabel = true,
    this.scale = 1.0,
    this.animate = true,
  });

  @override
  State<RouteMapPin> createState() => _RouteMapPinState();
}

class _RouteMapPinState extends State<RouteMapPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    if (widget.animate) {
      _controller.forward();
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(RouteMapPin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = widget.scale *
            _scaleAnimation.value *
            (widget.isActive ? _pulseAnimation.value : 1.0);

        return Transform.scale(
          scale: scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pin icon container
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? widget.backgroundColor
                      : widget.backgroundColor.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  boxShadow: widget.isActive
                      ? [
                          BoxShadow(
                            color: widget.backgroundColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                  border: widget.isActive
                      ? Border.all(
                          color: widget.backgroundColor.withValues(alpha: 0.3),
                          width: 3,
                        )
                      : null,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor,
                  size: 18,
                ),
              ),
              // Label
              if (widget.showLabel) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFF0F0F0),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.label,
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
}

/// Inactive/pending pin with muted styling
class PendingMapPin extends StatelessWidget {
  final IconData icon;
  final double opacity;

  const PendingMapPin({
    super.key,
    this.icon = Icons.restaurant,
    this.opacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF9CA3AF),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
