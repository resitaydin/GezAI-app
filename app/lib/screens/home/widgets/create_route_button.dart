import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class CreateRouteButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const CreateRouteButton({
    super.key,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isLoading
                  ? [const Color(0xFFCBD5E1), const Color(0xFFE2E8F0)]
                  : [
                      const Color(0xFF1E3A5F),
                      const Color(0xFF246D84),
                      const Color(0xFF2DD4BF),
                    ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: isLoading
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF2DD4BF).withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: const Color(0xFF2DD4BF).withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                )
              else ...[
                Text(
                  AppLocalizations.of(context)!.createMyRoute,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
