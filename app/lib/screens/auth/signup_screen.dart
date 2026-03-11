import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/error_localizer.dart';
import '../../widgets/terms_of_service_sheet.dart';
import '../../l10n/app_localizations.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  String _passwordStrength = '';
  int _passwordStrengthLevel = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _passwordStrengthLevel = 0;
      });
      return;
    }

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    setState(() {
      _passwordStrengthLevel = strength;
      final l10n = AppLocalizations.of(context)!;
      if (strength == 1) {
        _passwordStrength = l10n.authPasswordStrengthWeak;
      } else if (strength == 2) {
        _passwordStrength = l10n.authPasswordStrengthMedium;
      } else if (strength == 3) {
        _passwordStrength = l10n.authPasswordStrengthGood;
      } else if (strength == 4) {
        _passwordStrength = l10n.authPasswordStrengthStrong;
      }
    });
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authPleaseAgreeToTerms),
          backgroundColor: const Color(0xFF153765),
        ),
      );
      return;
    }

    await ref.read(authControllerProvider.notifier).signUpWithEmail(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
        );
  }

  Future<void> _signUpWithGoogle() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        final l10n = AppLocalizations.of(context)!;
        final localizedError = ErrorLocalizer.getLocalizedError(
          next.error.toString(),
          l10n,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizedError),
            backgroundColor: const Color(0xFF16509c),
          ),
        );
      } else if (next.hasValue && next.value != null) {
        context.go(AppRoutes.verifyEmail);
      }
    });

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: responsive.spacingSmall),

                    // Headline & Body
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        responsive.pagePaddingHorizontal,
                        responsive.spacingXS,
                        responsive.pagePaddingHorizontal,
                        responsive.spacingMedium,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.authCreateYourAccount,
                            style: TextStyle(
                              fontSize: responsive.titleFontSize,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF16509c),
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: responsive.spacingXS),
                          Text(
                            l10n.authStartPlanning,
                            style: TextStyle(
                              fontSize: responsive.bodyFontSize,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748b),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form Section
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.pagePaddingHorizontal,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Full Name Field
                            _buildTextField(
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              label: l10n.authFullName,
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.validationNameRequired;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: responsive.spacingSmall),

                            // Email Field
                            _buildTextField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              label: l10n.authEmailAddress,
                              icon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.validationEmailRequired;
                                }
                                if (!value.contains('@')) {
                                  return l10n.validationEmailInvalid;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: responsive.spacingSmall),

                            // Password Field
                            _buildTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              label: l10n.authPassword,
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF94a3b8),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.validationPasswordRequired;
                                }
                                if (value.length < 6) {
                                  return l10n.validationPasswordTooShort;
                                }
                                return null;
                              },
                            ),

                            // Password Strength Indicator
                            if (_passwordController.text.isNotEmpty) ...[
                              SizedBox(height: responsive.spacingXS),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: _passwordStrengthLevel >= 1
                                              ? const Color(0xFF2DD4BF)
                                              : const Color(0xFFe2e8f0),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: _passwordStrengthLevel >= 2
                                              ? const Color(0xFF2DD4BF)
                                              : const Color(0xFFe2e8f0),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: _passwordStrengthLevel >= 3
                                              ? const Color(0xFF2DD4BF)
                                              : const Color(0xFFe2e8f0),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: _passwordStrengthLevel >= 4
                                              ? const Color(0xFF2DD4BF)
                                              : const Color(0xFFe2e8f0),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _passwordStrength,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF64748b),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            SizedBox(height: responsive.spacingSmall),

                            // Confirm Password Field
                            _buildTextField(
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocusNode,
                              label: l10n.authConfirmPassword,
                              icon: Icons.lock_outline,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF94a3b8),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.validationPasswordConfirmRequired;
                                }
                                if (value != _passwordController.text) {
                                  return l10n.validationPasswordsDoNotMatch;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: responsive.spacingSmall),

                            // Terms Checkbox
                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: _agreeToTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        _agreeToTerms = value ?? false;
                                      });
                                    },
                                    activeColor: const Color(0xFF2DD4BF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      TermsOfServiceSheet.show(context);
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF475569),
                                        ),
                                        children: [
                                          TextSpan(text: l10n.authAgreeToTerms),
                                          TextSpan(
                                            text: l10n.authTermsOfService,
                                            style: const TextStyle(
                                              color: Color(0xFF16509c),
                                              fontWeight: FontWeight.w600,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: responsive.spacingMedium),

                            // Create Account Button
                            SizedBox(
                              width: double.infinity,
                              height: responsive.buttonHeight,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _signUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16509c),
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  shadowColor: const Color(0xFF16509c).withValues(alpha: 0.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  disabledBackgroundColor:
                                      const Color(0xFF16509c).withValues(alpha: 0.6),
                                ),
                                child: isLoading
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
                                        l10n.authCreateAccount,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: responsive.spacingMedium),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(0xFFe2e8f0),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    l10n.authOrContinueWith,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF94a3b8),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(0xFFe2e8f0),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: responsive.spacingMedium),

                            // Google Sign In Button
                            SizedBox(
                              width: double.infinity,
                              height: responsive.buttonHeight,
                              child: OutlinedButton(
                                onPressed: isLoading ? null : _signUpWithGoogle,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFFe2e8f0),
                                    width: 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      'https://www.google.com/favicon.ico',
                                      width: 24,
                                      height: 24,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.g_mobiledata,
                                          size: 24,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      l10n.authSignInWithGoogle,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0f141a),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: responsive.spacingMedium),

                            // Sign In Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.authAlreadyHaveAccount,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748b),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => context.go(AppRoutes.login),
                                  child: Text(
                                    l10n.authSignIn,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2DD4BF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: responsive.spacingMedium),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focusNode.hasFocus
              ? const Color(0xFF16509c)
              : const Color(0xFFe2e8f0),
          width: 1,
        ),
        boxShadow: focusNode.hasFocus
            ? [
                BoxShadow(
                  color: const Color(0xFF16509c).withValues(alpha: 0.1),
                  blurRadius: 0,
                  spreadRadius: 2,
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
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              icon,
              color: focusNode.hasFocus
                  ? const Color(0xFF16509c)
                  : const Color(0xFF94a3b8),
              size: 24,
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0f141a),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: label,
                labelStyle: TextStyle(
                  color: focusNode.hasFocus
                      ? const Color(0xFF16509c)
                      : const Color(0xFF64748b),
                ),
                floatingLabelStyle: TextStyle(
                  color: focusNode.hasFocus
                      ? const Color(0xFF16509c)
                      : const Color(0xFF64748b),
                  fontSize: 12,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
              validator: validator,
              onChanged: (value) => setState(() {}),
            ),
          ),
          if (suffixIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: suffixIcon,
            ),
        ],
      ),
    );
  }
}
