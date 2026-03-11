import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final String? iconAsset;

  const SocialButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        side: BorderSide(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconAsset != null) ...[
            Image.asset(
              iconAsset!,
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to icon if asset not found
                return const Icon(Icons.g_mobiledata, size: 24);
              },
            ),
            const SizedBox(width: 12),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
