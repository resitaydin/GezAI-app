import 'package:flutter/material.dart';
import '../../../models/category.dart';
import '../../../utils/model_localizer.dart';

class CategorySelectionItem extends StatelessWidget {
  final PlaceCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategorySelectionItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF3B82F6).withValues(alpha: 0.20)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: isSelected ? 20 : 12,
              offset: const Offset(0, 6),
              spreadRadius: isSelected ? 2 : 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  // Image with gradient overlay
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    child: SizedBox.expand(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            category.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFE2E8F0),
                                      const Color(0xFFCBD5E1),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.image_outlined,
                                  color: Color(0xFF94A3B8),
                                  size: 36,
                                ),
                              );
                            },
                          ),
                          // Subtle vignette effect
                          Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 1.2,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.08),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Selection Checkbox
                  Positioned(
                    top: 12,
                    right: 12,
                    child: AnimatedScale(
                      scale: isSelected ? 1.0 : 0.9,
                      duration: const Duration(milliseconds: 200),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3B82F6)
                              : Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF3B82F6)
                                : Colors.white,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 18,
                                  key: ValueKey('check'),
                                )
                              : const SizedBox.shrink(key: ValueKey('empty')),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Name Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFF0F9FF)
                    : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(22),
                ),
              ),
              child: Text(
                ModelLocalizer.getCategoryName(context, category.id),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF334155),
                  letterSpacing: -0.3,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
