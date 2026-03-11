import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/snackbar_utils.dart';
import '../../utils/error_localizer.dart';
import '../../l10n/app_localizations.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  Timer? _timer;
  Timer? _resendTimer;
  int _resendCountdown = 0;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startEmailCheckTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startEmailCheckTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final authService = ref.read(authServiceProvider);
      await authService.reloadUser();

      if (authService.isEmailVerified) {
        timer.cancel();
        if (mounted) {
          context.go(AppRoutes.home);
        }
      }
    });
  }

  void _startResendCountdown() {
    setState(() => _resendCountdown = 60);

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    if (_isResending || _resendCountdown > 0) return;

    setState(() => _isResending = true);

    try {
      await ref.read(authControllerProvider.notifier).sendEmailVerification();

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        SnackbarUtils.showSuccess(context, l10n.authVerificationEmailSent);
        _startResendCountdown();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final localizedError = ErrorLocalizer.getLocalizedError(
          e.toString(),
          l10n,
        );
        SnackbarUtils.showError(context, localizedError);
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;
    final email = currentUser?.email ?? 'your email';
    final responsive = ResponsiveUtils.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFf6f7f8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.all(responsive.pagePaddingHorizontal),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: responsive.spacingXL),

                      // Email Icon with Send Badge
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: responsive.logoSize * 1.8,
                            height: responsive.logoSize * 1.8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2DD4BF).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.drafts,
                              size: responsive.logoSize,
                              color: const Color(0xFF2DD4BF),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            right: -8,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Transform.rotate(
                                angle: -0.2,
                                child: Icon(
                                  Icons.send,
                                  size: responsive.iconSizeLarge,
                                  color: const Color(0xFF1E3A5F),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: responsive.spacingXL),

                      // Title
                      Text(
                        l10n.authVerifyEmail,
                        style: TextStyle(
                          fontSize: responsive.titleFontSize,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0e141b),
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: responsive.spacingXS),

                      // Subtitle with email
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: responsive.bodyFontSize,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4f6e8f),
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: 'We\'ve sent a verification link to\n'),
                            TextSpan(
                              text: email,
                              style: TextStyle(
                                fontSize: responsive.subtitleFontSize,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E3A5F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: responsive.spacingMedium),

                      // Info Box
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(responsive.contentPadding),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          border: Border.all(
                            color: const Color(0xFFDBEAFE),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.mark_email_read,
                              size: responsive.iconSize,
                              color: const Color(0xFF1E3A5F),
                            ),
                            SizedBox(height: responsive.spacingXS),
                            Text(
                              l10n.authClickLinkToVerify,
                              style: TextStyle(
                                fontSize: responsive.captionFontSize + 1,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E3A5F),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: responsive.spacingXL),

                      // Resend Email Button
                      SizedBox(
                        width: double.infinity,
                        height: responsive.buttonHeight,
                        child: OutlinedButton(
                          onPressed: (_isResending || _resendCountdown > 0)
                              ? null
                              : _resendVerificationEmail,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF1E3A5F),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledForegroundColor:
                                const Color(0xFF1E3A5F).withValues(alpha: 0.5),
                          ),
                          child: _isResending
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF1E3A5F)),
                                  ),
                                )
                              : Text(
                                  l10n.authResendEmail,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: (_resendCountdown > 0)
                                        ? const Color(0xFF1E3A5F).withValues(alpha: 0.5)
                                        : const Color(0xFF1E3A5F),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: responsive.spacingSmall),

                      // Countdown timer
                      if (_resendCountdown > 0)
                        Text(
                          l10n.authResendInSeconds(_resendCountdown),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      SizedBox(height: responsive.spacingMedium),

                      // Wrong email link
                      InkWell(
                        onTap: () async {
                          await ref.read(authControllerProvider.notifier).signOut();
                          if (mounted) {
                            context.go(AppRoutes.signup);
                          }
                        },
                        child: Text(
                          l10n.authWrongEmailGoBack,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E3A5F),
                          ),
                        ),
                      ),
                      SizedBox(height: responsive.spacingLarge),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
