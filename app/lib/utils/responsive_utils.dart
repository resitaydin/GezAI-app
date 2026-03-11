import 'package:flutter/material.dart';

/// Centralized responsive utility class for consistent sizing across all screens.
/// Use this class to get responsive values based on screen dimensions.
///
/// Usage:
/// ```dart
/// final responsive = ResponsiveUtils.of(context);
/// SizedBox(height: responsive.spacingMedium);
/// Text('Title', style: TextStyle(fontSize: responsive.titleFontSize));
/// ```
class ResponsiveUtils {
  final double screenHeight;
  final double screenWidth;
  final double safeAreaTop;
  final double safeAreaBottom;

  ResponsiveUtils._({
    required this.screenHeight,
    required this.screenWidth,
    required this.safeAreaTop,
    required this.safeAreaBottom,
  });

  /// Factory constructor that creates ResponsiveUtils from BuildContext
  factory ResponsiveUtils.of(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return ResponsiveUtils._(
      screenHeight: mediaQuery.size.height,
      screenWidth: mediaQuery.size.width,
      safeAreaTop: mediaQuery.padding.top,
      safeAreaBottom: mediaQuery.padding.bottom,
    );
  }

  // ============== Screen Size Categories ==============

  /// Very compact screens: < 640px height (5-5.5 inch phones)
  bool get isVeryCompact => screenHeight < 640;

  /// Compact screens: < 700px height (older/smaller phones like iPhone SE)
  /// This includes veryCompact screens
  bool get isCompact => screenHeight < 700;

  /// Small screens: alias for compact (< 700px)
  bool get isSmall => screenHeight < 700;

  /// Regular screens: 700-850px height (most phones)
  bool get isRegular => screenHeight >= 700 && screenHeight < 850;

  /// Tall screens: >= 850px height (modern large phones like S23 Ultra, iPhone Pro Max)
  bool get isTall => screenHeight >= 850;

  /// Very tall screens: >= 900px (tablets, foldables)
  bool get isVeryTall => screenHeight >= 900;

  /// Narrow screens: < 360px width (very small phones)
  bool get isVeryNarrow => screenWidth < 360;

  /// Narrow screens: < 380px width (small phones)
  bool get isNarrow => screenWidth < 380;

  /// Wide screens: >= 420px width (large phones, tablets)
  bool get isWide => screenWidth >= 420;

  // ============== Available Height ==============

  /// Available height after safe areas (notch, navigation bar)
  double get availableHeight => screenHeight - safeAreaTop - safeAreaBottom;

  // ============== Spacing Values ==============

  /// Extra small spacing: scales 4-8px
  double get spacingXS => (screenHeight * 0.006).clamp(4.0, 8.0);

  /// Small spacing: scales 8-16px
  double get spacingSmall => (screenHeight * 0.012).clamp(8.0, 16.0);

  /// Medium spacing: scales 16-28px
  double get spacingMedium => (screenHeight * 0.024).clamp(16.0, 28.0);

  /// Large spacing: scales 24-40px
  double get spacingLarge => (screenHeight * 0.035).clamp(24.0, 40.0);

  /// Extra large spacing: scales 32-56px
  double get spacingXL => (screenHeight * 0.05).clamp(32.0, 56.0);

  // ============== Font Sizes ==============

  /// Title font size (large headers): scales 22-34px
  double get titleFontSize => (screenWidth * 0.07).clamp(22.0, 34.0);

  /// Subtitle font size: scales 16-24px
  double get subtitleFontSize => (screenWidth * 0.05).clamp(16.0, 24.0);

  /// Body font size: scales 14-16px
  double get bodyFontSize => (screenWidth * 0.038).clamp(14.0, 16.0);

  /// Caption font size: scales 11-13px
  double get captionFontSize => (screenWidth * 0.03).clamp(11.0, 13.0);

  // ============== Component Sizes ==============

  /// Button height: scales 52-60px
  double get buttonHeight => (screenHeight * 0.07).clamp(52.0, 60.0);

  /// Input field height: scales 50-60px
  double get inputHeight => (screenHeight * 0.07).clamp(50.0, 60.0);

  /// Icon size (standard): scales 22-28px
  double get iconSize => (screenWidth * 0.06).clamp(22.0, 28.0);

  /// Icon size (large): scales 40-56px
  double get iconSizeLarge => (screenWidth * 0.12).clamp(40.0, 56.0);

  /// Avatar/Logo size: scales 80-120px
  double get logoSize => (screenWidth * 0.25).clamp(80.0, 120.0);

  /// Success icon size: scales 90-120px (for completion screens)
  double get successIconSize => (screenHeight * 0.14).clamp(90.0, 120.0);

  // ============== Card & Container Sizes ==============

  /// Card aspect ratio based on screen height
  /// - Very compact screens: wider (16:9) to save vertical space
  /// - Compact screens: wider (16:9) to save vertical space
  /// - Regular screens: balanced (3:2)
  /// - Tall screens: taller (4:3) to fill space
  double get cardAspectRatio {
    if (isVeryCompact) return 16 / 9;
    if (isCompact) return 16 / 9;
    if (isTall) return 4 / 3;
    return 3 / 2;
  }

  /// Map card aspect ratio (for loading screens)
  /// - Higher ratio = wider/shorter card (saves vertical space)
  /// - Lower ratio = taller card (fills more vertical space)
  double get mapCardAspectRatio {
    if (isVeryCompact) return 1.4;
    if (isCompact) return 1.25;
    return 1.05;
  }

  /// Horizontal card/carousel height: scales 140-200px
  double get carouselHeight => (screenHeight * 0.2).clamp(140.0, 200.0);

  /// Card border radius: scales 16-24px
  double get cardRadius => (screenWidth * 0.05).clamp(16.0, 24.0);

  /// Standard border radius: scales 12-16px
  double get borderRadius => (screenWidth * 0.035).clamp(12.0, 16.0);

  // ============== Padding Values ==============

  /// Horizontal page padding: scales 16-28px
  double get pagePaddingHorizontal => (screenWidth * 0.05).clamp(16.0, 28.0);

  /// Vertical page padding: scales 16-24px
  double get pagePaddingVertical => (screenHeight * 0.02).clamp(16.0, 24.0);

  /// Content padding (smaller): scales 12-20px
  double get contentPadding => (screenWidth * 0.04).clamp(12.0, 20.0);

  // ============== Helper Methods ==============

  /// Returns a value based on screen size category
  T valueByScreenSize<T>({
    T? veryCompact,
    required T compact,
    required T regular,
    required T tall,
  }) {
    if (isVeryCompact) return veryCompact ?? compact;
    if (isCompact) return compact;
    if (isTall) return tall;
    return regular;
  }

  /// Returns responsive EdgeInsets for page content
  EdgeInsets get pagePadding => EdgeInsets.symmetric(
        horizontal: pagePaddingHorizontal,
        vertical: pagePaddingVertical,
      );

  /// Returns responsive EdgeInsets for card content
  EdgeInsets get cardPadding => EdgeInsets.all(contentPadding);

  /// Calculate percentage of screen height
  double heightPercent(double percent) => screenHeight * percent / 100;

  /// Calculate percentage of screen width
  double widthPercent(double percent) => screenWidth * percent / 100;

  @override
  String toString() {
    String category;
    if (isVeryCompact) {
      category = 'veryCompact';
    } else if (isCompact) {
      category = 'compact';
    } else if (isTall) {
      category = 'tall';
    } else {
      category = 'regular';
    }
    return 'ResponsiveUtils(height: $screenHeight, width: $screenWidth, category: $category)';
  }
}

/// Extension on BuildContext for easy access to ResponsiveUtils
extension ResponsiveContext on BuildContext {
  ResponsiveUtils get responsive => ResponsiveUtils.of(this);
}
