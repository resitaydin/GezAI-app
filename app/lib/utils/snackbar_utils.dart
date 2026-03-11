import 'package:flutter/material.dart';

/// Utility class for showing consistent styled snackbars across the app
class SnackbarUtils {
  SnackbarUtils._();

  /// Shows a custom styled snackbar with icon
  static void _showCustomSnackBar(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color iconBackgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: duration,
        elevation: 8,
      ),
    );
  }

  /// Shows an error snackbar with red styling
  static void showError(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: const Color(0xFF991B1B), // Dark red
      iconBackgroundColor: const Color(0xFFDC2626), // Red
    );
  }

  /// Shows a success snackbar with green styling
  static void showSuccess(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: const Color(0xFF065F46), // Dark green
      iconBackgroundColor: const Color(0xFF10B981), // Green
    );
  }

  /// Shows an info snackbar with blue styling
  static void showInfo(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      backgroundColor: const Color(0xFF1E3A8A), // Dark blue
      iconBackgroundColor: const Color(0xFF3B82F6), // Blue
    );
  }

  /// Shows a warning snackbar with orange/amber styling
  static void showWarning(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: const Color(0xFF92400E), // Dark amber
      iconBackgroundColor: const Color(0xFFF59E0B), // Amber
    );
  }

  /// Shows a saved/bookmarked snackbar (for routes)
  static void showSaved(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message: message,
      icon: Icons.bookmark_added_rounded,
      backgroundColor: const Color(0xFF1E293B), // Slate
      iconBackgroundColor: const Color(0xFFF59E0B), // Amber
    );
  }

  /// Shows a removed/deleted snackbar
  static void showRemoved(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message: message,
      icon: Icons.bookmark_remove_rounded,
      backgroundColor: const Color(0xFF374151), // Gray
      iconBackgroundColor: const Color(0xFF6B7280), // Lighter gray
    );
  }
}
