import 'package:flutter/material.dart';

class RouteInfoPill extends StatelessWidget {
  final String distance;
  final String duration;
  final int? stopsCount;

  const RouteInfoPill({
    super.key,
    required this.distance,
    required this.duration,
    this.stopsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoChip(
            icon: Icons.schedule_rounded,
            value: duration,
            iconColor: const Color(0xFF3B82F6),
          ),
          Container(
            width: 1,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: const Color(0xFFE2E8F0),
          ),
          _buildInfoChip(
            icon: Icons.route_rounded,
            value: distance,
            iconColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor,
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
