import 'package:flutter/material.dart';
import '../../../utils/responsive_utils.dart';

/// A shimmer loading card for the place carousel with modern styling
class ShimmerPlaceCard extends StatefulWidget {
  final double? width;

  const ShimmerPlaceCard({
    super.key,
    this.width,
  });

  @override
  State<ShimmerPlaceCard> createState() => _ShimmerPlaceCardState();
}

class _ShimmerPlaceCardState extends State<ShimmerPlaceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildShimmerBox({
    required double height,
    double? width,
    BorderRadius? borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: const [
                Color(0xFFE8E8E8),
                Color(0xFFF5F5F5),
                Color(0xFFE8E8E8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils.of(context);
    // Shrink on compact screens (< 700px height) to prevent overflow
    final isSmall = responsive.isCompact;
    // Responsive width
    final cardWidth = widget.width ?? (isSmall ? 120.0 : 140.0);
    // Responsive padding
    final cardPadding = isSmall ? 8.0 : 10.0;
    // Image height scales with carousel to always fit
    // carouselHeight - padding*2 - titleHeight - subtitleHeight - spacings
    final imageHeight = (responsive.carouselHeight - cardPadding * 2 - 30).clamp(60.0, 100.0);

    return Container(
      width: cardWidth,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmall ? 16 : 20),
        border: Border.all(
          color: const Color(0xFFF0F0F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder with rounded corners
          _buildShimmerBox(
            height: imageHeight,
            borderRadius: BorderRadius.circular(isSmall ? 12 : 14),
          ),
          SizedBox(height: isSmall ? 8 : 10),
          // Title placeholder
          _buildShimmerBox(
            height: isSmall ? 12 : 14,
            width: cardWidth * 0.7,
            borderRadius: BorderRadius.circular(7),
          ),
          SizedBox(height: isSmall ? 5 : 6),
          // Subtitle placeholder (category)
          _buildShimmerBox(
            height: isSmall ? 9 : 10,
            width: cardWidth * 0.45,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }
}
