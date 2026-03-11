import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gez_ai/l10n/app_localizations.dart';

class RouteActionBar extends StatelessWidget {
  final VoidCallback? onRegenerate;
  final VoidCallback? onStartRoute;
  final bool isLoading;
  final bool isEmpty;

  const RouteActionBar({
    super.key,
    this.onRegenerate,
    this.onStartRoute,
    this.isLoading = false,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            border: const Border(
              top: BorderSide(
                color: Color(0xFFF1F5F9),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: isEmpty ? const SizedBox.shrink() : _buildNormalContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNormalContent() {
    return Builder(
      builder: (context) => Row(
        children: [
          _buildRegenerateButton(),
          const SizedBox(width: 10),
          Expanded(child: _buildStartRouteButton(context)),
        ],
      ),
    );
  }

  Widget _buildRegenerateButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onRegenerate,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Icon(
              Icons.refresh_rounded,
              size: 22,
              color: isLoading
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartRouteButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onStartRoute,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isLoading
                  ? [const Color(0xFFCBD5E1), const Color(0xFFE2E8F0)]
                  : [const Color(0xFF10B981), const Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isLoading
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                )
              else ...[
                const Icon(
                  Icons.navigation_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.startRoute,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
