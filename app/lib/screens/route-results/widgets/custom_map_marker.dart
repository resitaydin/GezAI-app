import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Category-based marker configuration - Google Maps style
class MarkerConfig {
  final IconData icon;
  final Color color;

  const MarkerConfig({required this.icon, required this.color});
}

/// Custom marker generator for route stops - Google Maps style
class CustomMapMarker {
  // Google Maps style colors
  static const Color _red = Color(0xFFEA4335);
  static const Color _blue = Color(0xFF4285F4);
  static const Color _green = Color(0xFF34A853);
  static const Color _purple = Color(0xFF9334E6);
  static const Color _orange = Color(0xFFFA7B17);
  static const Color _teal = Color(0xFF24C1E0);
  static const Color _pink = Color(0xFFE91E63);

  static final Map<String, MarkerConfig> _categoryConfigs = {
    'mosque': MarkerConfig(icon: Icons.mosque, color: _green),
    'museum': MarkerConfig(icon: Icons.museum, color: _purple),
    'park': MarkerConfig(icon: Icons.park, color: _green),
    'restaurant': MarkerConfig(icon: Icons.restaurant, color: _orange),
    'cafe': MarkerConfig(icon: Icons.local_cafe, color: _orange),
    'historical': MarkerConfig(icon: Icons.account_balance, color: _purple),
    'attraction': MarkerConfig(icon: Icons.photo_camera, color: _teal),
    'shopping': MarkerConfig(icon: Icons.shopping_bag, color: _pink),
    'hotel': MarkerConfig(icon: Icons.hotel, color: _blue),
    'beach': MarkerConfig(icon: Icons.beach_access, color: _teal),
    'church': MarkerConfig(icon: Icons.church, color: _purple),
    'default': MarkerConfig(icon: Icons.place, color: _red),
  };

  static MarkerConfig getConfig(String? category) {
    if (category == null) return _categoryConfigs['default']!;
    return _categoryConfigs[category.toLowerCase()] ??
        _categoryConfigs['default']!;
  }

  /// Creates a Google Maps style marker
  static Future<BitmapDescriptor> createMarkerBitmap({
    required String? category,
    required int order,
    required bool isFirst,
    required bool isLast,
    bool isSelected = false,
  }) async {
    final config = getConfig(category);

    // Smaller, more compact size like Google Maps
    const double canvasSize = 96;
    const double pinWidth = 28;
    const double pinHeight = 36;
    const double pinTailHeight = 8;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final double centerX = canvasSize / 2;
    final double pinTop = (canvasSize - pinHeight - pinTailHeight) / 2;

    // Pin color based on position
    final Color pinColor = isFirst ? _green : (isLast ? _red : config.color);

    // Draw drop shadow
    final shadowPath = _createPinPath(
      centerX + 1,
      pinTop + 2,
      pinWidth + 2,
      pinHeight,
      pinTailHeight,
    );
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Draw main pin shape
    final pinPath = _createPinPath(
      centerX,
      pinTop,
      pinWidth,
      pinHeight,
      pinTailHeight,
    );
    canvas.drawPath(pinPath, Paint()..color = pinColor);

    // Draw white inner circle
    final innerCircleY = pinTop + pinWidth / 2 + 2;
    canvas.drawCircle(
      Offset(centerX, innerCircleY),
      pinWidth / 2 - 4,
      Paint()..color = Colors.white,
    );

    // Draw icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(config.icon.codePoint),
        style: TextStyle(
          fontSize: 14,
          fontFamily: config.icon.fontFamily,
          package: config.icon.fontPackage,
          color: pinColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        centerX - iconPainter.width / 2,
        innerCircleY - iconPainter.height / 2,
      ),
    );

    // Draw order number badge (small circle at top-right)
    const double badgeRadius = 9;
    final badgeX = centerX + pinWidth / 2 - 2;
    final badgeY = pinTop + 2;

    // Badge border
    canvas.drawCircle(
      Offset(badgeX, badgeY),
      badgeRadius + 1.5,
      Paint()..color = Colors.white,
    );

    // Badge fill
    final badgeColor = isFirst ? _green : (isLast ? _red : _blue);
    canvas.drawCircle(
      Offset(badgeX, badgeY),
      badgeRadius,
      Paint()..color = badgeColor,
    );

    // Badge number
    final numberPainter = TextPainter(
      text: TextSpan(
        text: '$order',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    numberPainter.layout();
    numberPainter.paint(
      canvas,
      Offset(
        badgeX - numberPainter.width / 2,
        badgeY - numberPainter.height / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(canvasSize.toInt(), canvasSize.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(bytes);
  }

  /// Creates a Google Maps style pin path (teardrop shape)
  static Path _createPinPath(
    double centerX,
    double top,
    double width,
    double height,
    double tailHeight,
  ) {
    final path = Path();
    final radius = width / 2;
    final circleBottom = top + width;

    // Start from bottom point
    path.moveTo(centerX, top + height + tailHeight);

    // Left curve to circle
    path.quadraticBezierTo(
      centerX - radius * 0.6,
      circleBottom,
      centerX - radius,
      top + radius,
    );

    // Top arc (semi-circle)
    path.arcToPoint(
      Offset(centerX + radius, top + radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    // Right curve to bottom point
    path.quadraticBezierTo(
      centerX + radius * 0.6,
      circleBottom,
      centerX,
      top + height + tailHeight,
    );

    path.close();
    return path;
  }
}
