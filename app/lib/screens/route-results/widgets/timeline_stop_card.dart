import 'package:flutter/material.dart';
import '../../../models/route_result.dart';

class TimelineStopCard extends StatelessWidget {
  final RouteStop stop;
  final bool isLast;
  final bool isSelected;
  final VoidCallback? onTap;

  const TimelineStopCard({
    super.key,
    required this.stop,
    this.isLast = false,
    this.isSelected = false,
    this.onTap,
  });

  Color get _accentColor =>
      isSelected ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimelineIndicator(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              children: [
                _buildStopCard(),
                if (!isLast && stop.travelToNext != null)
                  _buildTravelSegment(),
                SizedBox(height: isLast ? 8 : 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator() {
    return SizedBox(
      width: 28,
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: isSelected || stop.order == 1
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    )
                  : null,
              color: isSelected || stop.order == 1 ? null : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected || stop.order == 1
                    ? Colors.transparent
                    : const Color(0xFFE2E8F0),
                width: 2,
              ),
              boxShadow: isSelected || stop.order == 1
                  ? [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '${stop.order}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected || stop.order == 1
                      ? Colors.white
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          ),
          if (!isLast)
            Container(
              width: 2,
              height: 90,
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _accentColor.withValues(alpha: 0.4),
                    _accentColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStopCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
              : const Color(0xFFF1F5F9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFF3B82F6).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThumbnail(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    height: 1.2,
                  ),
                ),
                if (stop.description != null) ...[
                  const SizedBox(height: 4),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    alignment: Alignment.topLeft,
                    child: Text(
                      stop.description!,
                      maxLines: isSelected ? null : 2,
                      overflow: isSelected ? null : TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _buildMetaRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow() {
    return Row(
      children: [
        _buildCompactBadge(
          icon: Icons.schedule_rounded,
          text: stop.formattedDuration,
          color: const Color(0xFF3B82F6),
        ),
        
          const SizedBox(width: 6),
          _buildCompactBadge(
            icon: Icons.route_rounded,
            text: stop.travelToNext?.distanceKm != null
                ? '${stop.travelToNext!.distanceKm!.toStringAsFixed(1)} km'
                : '-',
            color: const Color(0xFFF59E0B),
          ),
        ],
      
    );
  }

  Widget _buildCompactBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF1F5F9),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: stop.photoUrl != null
            ? Image.network(
                stop.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderImage(),
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Icon(
          _getCategoryIcon(stop.category),
          size: 24,
          color: const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'mosque':
        return Icons.mosque;
      case 'museum':
        return Icons.museum;
      case 'park':
        return Icons.park;
      case 'restaurant':
        return Icons.restaurant;
      case 'cafe':
        return Icons.local_cafe;
      case 'historical':
        return Icons.account_balance;
      default:
        return Icons.place;
    }
  }

  Widget _buildTravelSegment() {
    final travel = stop.travelToNext!;

    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8, bottom: 4),
      child: Row(
        children: [
          Icon(
            _getTravelModeIcon(travel.mode),
            size: 14,
            color: const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 6),
          Text(
            '${travel.formattedDuration} ${travel.modeLabel}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE2E8F0),
                    const Color(0xFFE2E8F0).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTravelModeIcon(TravelMode mode) {
    switch (mode) {
      case TravelMode.transit:
        return Icons.directions_bus_rounded;
      case TravelMode.driving:
        return Icons.directions_car_rounded;
      case TravelMode.walking:
        return Icons.directions_walk_rounded;
    }
  }
}
