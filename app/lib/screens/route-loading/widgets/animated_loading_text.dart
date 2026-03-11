import 'package:flutter/material.dart';

/// Animated text that cycles through loading messages
class AnimatedLoadingText extends StatefulWidget {
  final List<String> messages;
  final Duration interval;
  final TextStyle? textStyle;

  const AnimatedLoadingText({
    super.key,
    required this.messages,
    this.interval = const Duration(seconds: 2),
    this.textStyle,
  });

  @override
  State<AnimatedLoadingText> createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<AnimatedLoadingText>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _startCycling();
  }

  void _startCycling() {
    Future.delayed(widget.interval, () {
      if (!mounted) return;

      _fadeController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.messages.length;
        });
        _fadeController.forward();
        _startCycling();
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        widget.messages[_currentIndex],
        style: widget.textStyle ??
            const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0E141B),
              letterSpacing: -0.5,
              height: 1.2,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
