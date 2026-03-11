import 'package:flutter/material.dart';

/// A segmented progress indicator with shimmer effect on the active segment
class SegmentedProgressIndicator extends StatefulWidget {
  final int totalSteps;
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;
  final double height;
  final double gap;

  const SegmentedProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor = const Color(0xFF16509c),
    this.inactiveColor = const Color(0xFFDBEAFE),
    this.height = 8,
    this.gap = 8,
  });

  @override
  State<SegmentedProgressIndicator> createState() =>
      _SegmentedProgressIndicatorState();
}

class _SegmentedProgressIndicatorState extends State<SegmentedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(widget.totalSteps, (index) {
        final isActive = index < widget.currentStep;
        final isCurrent = index == widget.currentStep - 1;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < widget.totalSteps - 1 ? widget.gap : 0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.height / 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: widget.height,
                decoration: BoxDecoration(
                  color: isActive ? widget.activeColor : widget.inactiveColor,
                  borderRadius: BorderRadius.circular(widget.height / 2),
                ),
                child: isCurrent
                    ? AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: FractionallySizedBox(
                                  widthFactor: 0.5,
                                  alignment: Alignment(
                                    _shimmerAnimation.value - 0.5,
                                    0,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withValues(alpha: 0.4),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}
