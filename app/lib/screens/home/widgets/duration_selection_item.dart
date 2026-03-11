import 'package:flutter/material.dart';
import '../../../models/duration.dart';
import '../../../utils/model_localizer.dart';

class DurationSelectionItem extends StatelessWidget {
  final TimePeriod period;
  final bool isSelected;
  final VoidCallback onTap;

  // Green color only for selection frame
  static const Color selectionGreen = Color(0xFF10B981);

  const DurationSelectionItem({
    super.key,
    required this.period,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            // Only the frame/border is green when selected
            color: isSelected ? selectionGreen : const Color(0xFFF3F4F6),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: selectionGreen.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container with period's own color
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    // Use period's background color
                    color: period.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    period.icon,
                    size: 26,
                    // Use period's own color for icon
                    color: period.primaryColor,
                  ),
                ),
                // Green checkmark when selected
                if (isSelected)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: selectionGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: selectionGreen.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Name - dark text always
            Text(
              ModelLocalizer.getTimePeriodName(context, period.id),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            // Description - gray text
            Text(
              ModelLocalizer.getTimePeriodDescription(context, period.id),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
