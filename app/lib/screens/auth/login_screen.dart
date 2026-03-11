import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/error_localizer.dart';
import '../../l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _emailFocused = false;
  bool _passwordFocused = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {
        _emailFocused = _emailFocusNode.hasFocus;
      });
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        _passwordFocused = _passwordFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        // Header Image - responsive height
                        Container(
                          height: responsive.heightPercent(28).clamp(180.0, 280.0),
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(32),
                              bottomRight: Radius.circular(32),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuDlOwkH9vXmU7ll6xVycMtqyChQxho7k0lxbbybYSBJbrG4upHKXLEQEUyD1bc18-d199aDEmqXvHwiqCwnIBDB632sxmeqHQjS4_xAtlaF72psnjUeJJ0bAsb3k0LxkGfyKQPmwRnqkLOg1sin2t5kGCoRCI5Zb6UoycPM4oFWTrvEmnL5kaURkFESp7s9rfkLaojORq8Av-vSPCvrGTDRG5-FImo-TAnSOatMDQxxBusAA7pnxETyR9gHnHcKuEneWs2fAgvQvVdh',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(32),
                                bottomRight: Radius.circular(32),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Main Content
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        responsive.pagePaddingHorizontal,
                        responsive.spacingMedium,
                        responsive.pagePaddingHorizontal,
                        responsive.spacingMedium,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Headline
                            Text(
                              l10n.authWelcomeBack,
                              style: TextStyle(
                                fontSize: responsive.titleFontSize,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0e141b),
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: responsive.spacingXS),
                            Text(
                              l10n.authPlanAdventure,
                              style: TextStyle(
                                fontSize: responsive.bodyFontSize,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4f6e8f),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: responsive.spacingMedium),

                            // Email Field
                            Container(
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _emailFocused
                                      ? const Color(0xFF16509c)
                                      : const Color(0xFFe2e8f0),
                                  width: 1,
                                ),
                                boxShadow: _emailFocused
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF16509c)
                                              .withValues(alpha: 0.1),
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
                                      Icons.mail_outline,
                                      color: _emailFocused
                                          ? const Color(0xFF16509c)
                                          : const Color(0xFF94a3b8),
                                      size: 24,
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _emailController,
                                      focusNode: _emailFocusNode,
                                      keyboardType: TextInputType.emailAddress,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF0f141a),
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: l10n.authEmailAddress,
                                        labelStyle: TextStyle(
                                          color: _emailFocused
                                              ? const Color(0xFF16509c)
                                              : const Color(0xFF64748b),
                                        ),
                                        floatingLabelStyle: TextStyle(
                                          color: _emailFocused
                                              ? const Color(0xFF16509c)
                                              : const Color(0xFF64748b),
                                          fontSize: 12,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 20),
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
                                ],
                              ),
                            ),
                            SizedBox(height: responsive.spacingSmall),

                            // Password Field
                            Container(
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _passwordFocused
                                      ? const Color(0xFF16509c)
                                      : const Color(0xFFe2e8f0),
                                  width: 1,
                                ),
                                boxShadow: _passwordFocused
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF16509c)
                                              .withValues(alpha: 0.1),
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
                                      Icons.lock_outline,
                                      color: _passwordFocused
                                          ? const Color(0xFF16509c)
                                          : const Color(0xFF94a3b8),
                                      size: 24,
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _passwordController,
                                      focusNode: _passwordFocusNode,
                                      obscureText: _obscurePassword,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF0f141a),
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: l10n.authPassword,
                                        labelStyle: TextStyle(
                                          color: _passwordFocused
                                              ? const Color(0xFF16509c)
                                              : const Color(0xFF64748b),
                                        ),
                                        floatingLabelStyle: TextStyle(
                                          color: _passwordFocused
                                              ? const Color(0xFF16509c)
                                              : const Color(0xFF64748b),
                                          fontSize: 12,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 20),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return l10n.validationPasswordRequired;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: IconButton(
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
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: responsive.spacingSmall),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () => context.push(AppRoutes.forgotPassword),
                                child: Text(
                                  l10n.authForgotPassword,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF16509c),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: responsive.spacingMedium),

                            // Sign In Button
                            SizedBox(
                              width: double.infinity,
                              height: responsive.buttonHeight,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16509c),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
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
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                        ),
                                      )
                                    : Text(
                                        l10n.authSignIn,
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
                                    color: const Color(0xFFd1dae6),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    l10n.authOrContinueWith,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(0xFFd1dae6),
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
                                onPressed: isLoading ? null : _signInWithGoogle,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFFd1dae6),
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
                                      l10n.authContinueWithGoogle,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0e141b),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: responsive.spacingMedium),

                            // Sign Up Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.authNewToApp,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => context.push(AppRoutes.signup),
                                  child: Text(
                                    l10n.authCreateAccount,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF16509c),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
}
