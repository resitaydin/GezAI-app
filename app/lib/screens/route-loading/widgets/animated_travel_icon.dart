import 'package:flutter/material.dart';
import 'animated_route_path.dart';

/// Animated icon that travels along a route path
class AnimatedTravelIcon extends StatefulWidget {
  final List<Offset> routePoints;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final double iconSize;
  final double containerSize;
  final Duration duration;
  final Widget? badge;

  const AnimatedTravelIcon({
    super.key,
    required this.routePoints,
    this.icon = Icons.directions_walk,
    this.iconColor = const Color(0xFF16509c),
    this.backgroundColor = Colors.white,
    this.iconSize = 18,
    this.containerSize = 36,
    this.duration = const Duration(seconds: 4),
    this.badge,
  });

  @override
  State<AnimatedTravelIcon> createState() => _AnimatedTravelIconState();
}

class _AnimatedTravelIconState extends State<AnimatedTravelIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late PathPositionCalculator _pathCalculator;

  @override
  void initState() {
    super.initState();
    _pathCalculator = PathPositionCalculator(widget.routePoints);
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void didUpdateWidget(AnimatedTravelIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routePoints != widget.routePoints) {
      _pathCalculator = PathPositionCalculator(widget.routePoints);
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
        final position = _pathCalculator.getPositionAtProgress(_controller.value);

        return Positioned(
          left: position.dx - widget.containerSize / 2,
          top: position.dy - widget.containerSize / 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Time badge above icon
              if (widget.badge != null) ...[
                widget.badge!,
                const SizedBox(height: 4),
              ],
              // Icon container with shadow and glow
              Container(
                width: widget.containerSize,
                height: widget.containerSize,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.iconColor.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.iconColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor,
                  size: widget.iconSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Badge widget showing travel time
class TravelTimeBadge extends StatelessWidget {
  final String time;
  final Color backgroundColor;
  final Color textColor;

  const TravelTimeBadge({
    super.key,
    required this.time,
    this.backgroundColor = const Color(0xFF16509c),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        time,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
