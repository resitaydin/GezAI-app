import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/router.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/error_localizer.dart';
import '../../utils/snackbar_utils.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? oobCode; // Firebase action code from email link

  const ResetPasswordScreen({super.key, this.oobCode});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _newPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Password requirements
  bool _hasMinLength = false;
  bool _hasSpecialChar = false;
  bool _hasUppercase = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_checkPasswordRequirements);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _checkPasswordRequirements() {
    final password = _newPasswordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
    });
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    if (!_hasMinLength || !_hasSpecialChar || !_hasUppercase) {
      SnackbarUtils.showWarning(context, l10n.snackbarPasswordRequirements);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // If we have an action code (from email link), use it to reset password
      if (widget.oobCode != null && widget.oobCode!.isNotEmpty) {
        await FirebaseAuth.instance.confirmPasswordReset(
          code: widget.oobCode!,
          newPassword: _newPasswordController.text,
        );
      } else {
        // Fallback: if no code, try to update current user's password
        // This would only work if user is already logged in
        await FirebaseAuth.instance.currentUser
            ?.updatePassword(_newPasswordController.text);
      }

      if (mounted) {
        SnackbarUtils.showSuccess(context, l10n.snackbarPasswordResetSuccess);
        // Navigate to login
        context.go(AppRoutes.login);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final localizedError = ErrorLocalizer.getLocalizedError(
          e.code,
          l10n,
        );
        SnackbarUtils.showError(context, localizedError);
      }
    } catch (e) {
      if (mounted) {
        final localizedError = ErrorLocalizer.getLocalizedError(
          e.toString(),
          l10n,
        );
        SnackbarUtils.showError(context, localizedError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf6f7f8),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.all(24),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Shield Icon with checkmark badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2DD4BF).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shield,
                              size: 64,
                              color: Color(0xFF1E3A5F),
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
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Title
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0e141b),
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Set a strong password to protect your account.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4f6e8f),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // New Password Field
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _newPasswordFocusNode.hasFocus
                                ? const Color(0xFF2DD4BF)
                                : const Color(0xFFd1dae6),
                            width: 1,
                          ),
                          boxShadow: _newPasswordFocusNode.hasFocus
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2DD4BF)
                                        .withOpacity(0.1),
                                    blurRadius: 0,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
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
                                Icons.lock_outline,
                                color: _newPasswordFocusNode.hasFocus
                                    ? const Color(0xFF2DD4BF)
                                    : const Color(0xFF94a3b8),
                                size: 24,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: TextFormField(
                                  controller: _newPasswordController,
                                  focusNode: _newPasswordFocusNode,
                                  obscureText: _obscureNewPassword,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF0e141b),
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'New Password',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF94a3b8),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) => setState(() {}),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Icon(
                                  _obscureNewPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF94a3b8),
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password Field
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _confirmPasswordFocusNode.hasFocus
                                ? const Color(0xFF2DD4BF)
                                : const Color(0xFFd1dae6),
                            width: 1,
                          ),
                          boxShadow: _confirmPasswordFocusNode.hasFocus
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2DD4BF)
                                        .withOpacity(0.1),
                                    blurRadius: 0,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
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
                                Icons.lock_reset,
                                color: _confirmPasswordFocusNode.hasFocus
                                    ? const Color(0xFF2DD4BF)
                                    : const Color(0xFF94a3b8),
                                size: 24,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: TextFormField(
                                  controller: _confirmPasswordController,
                                  focusNode: _confirmPasswordFocusNode,
                                  obscureText: _obscureConfirmPassword,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF0e141b),
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Confirm Password',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF94a3b8),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value != _newPasswordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF94a3b8),
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Requirements
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Column(
                          children: [
                            _buildRequirement(
                              'At least 8 characters',
                              _hasMinLength,
                            ),
                            const SizedBox(height: 8),
                            _buildRequirement(
                              'One special character',
                              _hasSpecialChar,
                            ),
                            const SizedBox(height: 8),
                            _buildRequirement(
                              'One uppercase letter',
                              _hasUppercase,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Reset Password Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A5F),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor:
                                const Color(0xFF1E3A5F).withOpacity(0.6),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Reset Password',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isMet ? const Color(0xFF2DD4BF) : const Color(0xFFd1dae6),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4f6e8f),
          ),
        ),
      ],
    );
  }
}
