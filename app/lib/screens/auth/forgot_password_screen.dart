import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/error_localizer.dart';
import '../../l10n/app_localizations.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordReset(_emailController.text);

      if (mounted) {
        context.go(AppRoutes.passwordResetSent);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final localizedError = ErrorLocalizer.getLocalizedError(
          e.toString(),
          l10n,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizedError),
            backgroundColor: const Color(0xFF1E3A5F),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final responsive = ResponsiveUtils.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFf6f7f8),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Back Button
              Padding(
                padding: EdgeInsets.all(responsive.spacingMedium),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF0e141b),
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.pagePaddingHorizontal,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  SizedBox(height: responsive.spacingSmall),

                                  // Icon with badge
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: responsive.logoSize,
                                        height: responsive.logoSize,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2DD4BF).withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.lock,
                                          size: responsive.logoSize * 0.5,
                                          color: const Color(0xFF1E3A5F),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2DD4BF),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFFf6f7f8),
                                              width: 3,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.question_mark,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: responsive.spacingMedium),

                                  // Title
                                  Text(
                                    l10n.authForgotPasswordTitle,
                                    style: TextStyle(
                                      fontSize: responsive.titleFontSize,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0e141b),
                                      letterSpacing: -0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: responsive.spacingXS),

                                  // Subtitle
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      l10n.authResetInstructions,
                                      style: TextStyle(
                                        fontSize: responsive.bodyFontSize,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF4f6e8f),
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: responsive.spacingMedium),

                                  // Email Field
                                  Container(
                                    height: responsive.inputHeight,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _emailFocusNode.hasFocus
                                            ? const Color(0xFF2DD4BF)
                                            : const Color(0xFFd1dae6),
                                        width: 1,
                                      ),
                                      boxShadow: _emailFocusNode.hasFocus
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF2DD4BF).withValues(alpha: 0.1),
                                                blurRadius: 0,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.02),
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 16),
                                          child: Icon(
                                            Icons.mail_outline,
                                            color: _emailFocusNode.hasFocus
                                                ? const Color(0xFF2DD4BF)
                                                : const Color(0xFF94a3b8),
                                            size: 24,
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: TextFormField(
                                              controller: _emailController,
                                              focusNode: _emailFocusNode,
                                              keyboardType: TextInputType.emailAddress,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF0e141b),
                                              ),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: l10n.authEnterYourEmail,
                                                hintStyle: const TextStyle(
                                                  color: Color(0xFF94a3b8),
                                                ),
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return l10n.validationEmailRequired;
                                                }
                                                if (!value.contains('@')) {
                                                  return l10n.validationEmailInvalid;
                                                }
                                                return null;
                                              },
                                              onChanged: (value) => setState(() {}),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: responsive.spacingMedium),

                                  // Send Reset Link Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: responsive.buttonHeight,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _sendResetLink,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1E3A5F),
                                        foregroundColor: Colors.white,
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        disabledBackgroundColor:
                                            const Color(0xFF1E3A5F).withValues(alpha: 0.6),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              l10n.authSendResetLink,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),

                              // Back to Sign In
                              Padding(
                                padding: EdgeInsets.all(responsive.spacingMedium),
                                child: InkWell(
                                  onTap: () => context.go(AppRoutes.login),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.arrow_back,
                                        size: 18,
                                        color: Color(0xFF4f6e8f),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.authBackToSignIn,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF4f6e8f),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
