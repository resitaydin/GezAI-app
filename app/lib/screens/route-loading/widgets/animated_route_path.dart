import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom painter for animated dashed route path connecting multiple points
class AnimatedRoutePath extends StatefulWidget {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final Duration duration;
  final bool animate;

  const AnimatedRoutePath({
    super.key,
    required this.points,
    this.color = const Color(0xFF16509c),
    this.strokeWidth = 3.0,
    this.dashLength = 8.0,
    this.gapLength = 6.0,
    this.duration = const Duration(milliseconds: 2000),
    this.animate = true,
  });

  @override
  State<AnimatedRoutePath> createState() => _AnimatedRoutePathState();
}

class _AnimatedRoutePathState extends State<AnimatedRoutePath>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.animate) {
      _controller.repeat();
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
        return CustomPaint(
          painter: _RoutePathPainter(
            points: widget.points,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
            dashLength: widget.dashLength,
            gapLength: widget.gapLength,
            dashOffset: _controller.value * (widget.dashLength + widget.gapLength),
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _RoutePathPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double dashOffset;

  _RoutePathPainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
    required this.dashOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Create curved path through all points using quadratic bezier curves
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];

      // Calculate control point for smooth curve
      final midX = (current.dx + next.dx) / 2;
      final midY = (current.dy + next.dy) / 2;

      // Add some curvature
      final controlX = midX + (next.dy - current.dy) * 0.2;
      final controlY = midY - (next.dx - current.dx) * 0.2;

      path.quadraticBezierTo(controlX, controlY, next.dx, next.dy);
    }

    // Draw dashed path
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = -dashOffset;

      while (distance < metric.length) {
        final start = math.max(0.0, distance);
        final end = math.min(distance + dashLength, metric.length);

        if (start < metric.length && end > 0) {
          final extractPath = metric.extractPath(start.toDouble(), end.toDouble());
          canvas.drawPath(extractPath, paint);
        }

        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePathPainter oldDelegate) {
    return oldDelegate.dashOffset != dashOffset ||
        oldDelegate.points != points ||
        oldDelegate.color != color;
  }
}

/// Widget to get the position along a path at a given progress (0.0 to 1.0)
class PathPositionCalculator {
  final List<Offset> points;

  PathPositionCalculator(this.points);

  /// Calculate position along the path at given progress (0.0 to 1.0)
  Offset getPositionAtProgress(double progress) {
    if (points.isEmpty) return Offset.zero;
    if (points.length == 1) return points.first;

    // Clamp progress
    progress = progress.clamp(0.0, 1.0);

    // Calculate total path length
    double totalLength = 0;
    List<double> segmentLengths = [];

    for (int i = 0; i < points.length - 1; i++) {
      final length = (points[i + 1] - points[i]).distance;
      segmentLengths.add(length);
      totalLength += length;
    }

    if (totalLength == 0) return points.first;

    // Find target distance
    double targetDistance = progress * totalLength;
    double accumulatedDistance = 0;

    for (int i = 0; i < segmentLengths.length; i++) {
      if (accumulatedDistance + segmentLengths[i] >= targetDistance) {
        // Interpolate within this segment
        final segmentProgress = (targetDistance - accumulatedDistance) / segmentLengths[i];
        return Offset.lerp(points[i], points[i + 1], segmentProgress.toDouble())!;
      }
      accumulatedDistance += segmentLengths[i];
    }

    return points.last;
  }

  /// Get the angle of the path at given progress (for rotating icons)
  double getAngleAtProgress(double progress) {
    if (points.length < 2) return 0;

    progress = progress.clamp(0.0, 1.0);

    // Find which segment we're in
    double totalLength = 0;
    List<double> segmentLengths = [];

    for (int i = 0; i < points.length - 1; i++) {
      final length = (points[i + 1] - points[i]).distance;
      segmentLengths.add(length);
      totalLength += length;
    }

    if (totalLength == 0) return 0;

    double targetDistance = progress * totalLength;
    double accumulatedDistance = 0;

    for (int i = 0; i < segmentLengths.length; i++) {
      if (accumulatedDistance + segmentLengths[i] >= targetDistance) {
        final diff = points[i + 1] - points[i];
        return math.atan2(diff.dy, diff.dx);
      }
      accumulatedDistance += segmentLengths[i];
    }

    // Return angle of last segment
    final diff = points.last - points[points.length - 2];
    return math.atan2(diff.dy, diff.dx);
  }
}
