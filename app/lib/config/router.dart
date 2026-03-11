import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/route_result.dart';
import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/password_reset_sent_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/saved-route/my_route_screen.dart';
import '../screens/route-results/route_results_screen.dart';
import '../screens/route-loading/route_loading_screen.dart';
import '../screens/route-loading/ai_route_planner_screen.dart';
import '../screens/route-loading/route_ready_screen.dart';

/// Route names
abstract class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const passwordResetSent = '/password-reset-sent';
  static const resetPassword = '/reset-password';
  static const verifyEmail = '/verify-email';
  static const home = '/home';
  static const myRoutes = '/my-routes';
  static const routeResults = '/route-results';
  static const routeLoading = '/route-loading';
  static const aiRoutePlanner = '/ai-route-planner';
  static const routeReady = '/route-ready';
}

/// GoRouter provider with auth redirect
final routerProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(authStatusProvider);
  final hasSeenWelcome = ref.read(onboardingControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // Redirect based on auth state
    redirect: (context, state) {
      final isWelcome = state.matchedLocation == AppRoutes.welcome;
      final isLoggingIn = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.passwordResetSent ||
          state.matchedLocation == AppRoutes.resetPassword;

      final isVerifyingEmail = state.matchedLocation == AppRoutes.verifyEmail;

      // Still loading auth state
      if (authStatus == AuthState.initial) {
        return AppRoutes.splash;
      }

      // Not authenticated
      if (authStatus == AuthState.unauthenticated) {
        // Allow access to welcome and all auth screens
        if (isWelcome || isLoggingIn || isVerifyingEmail) {
          return null;
        }

        // First time user - show welcome screen, otherwise login
        return hasSeenWelcome ? AppRoutes.login : AppRoutes.welcome;
      }

      // Authenticated - redirect away from welcome and auth screens
      if (isWelcome || isLoggingIn || state.matchedLocation == AppRoutes.splash) {
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
      // Splash screen (loading state)
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Welcome screen
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.passwordResetSent,
        builder: (context, state) => const PasswordResetSentScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) {
          final oobCode = state.uri.queryParameters['oobCode'];
          return ResetPasswordScreen(oobCode: oobCode);
        },
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (context, state) => const VerifyEmailScreen(),
      ),

      // Protected routes
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.myRoutes,
        builder: (context, state) => const MyRoutesScreen(),
      ),
      GoRoute(
        path: AppRoutes.routeResults,
        builder: (context, state) {
          final routeResult = state.extra as RouteResult?;
          return Scaffold(
            body: RouteResultsScreenContent(routeResult: routeResult),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.routeLoading,
        builder: (context, state) {
          final transportMode = state.extra as String? ?? 'walking';
          return RouteLoadingScreen(
            onCancel: () => context.go(AppRoutes.home),
            transportMode: transportMode,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.aiRoutePlanner,
        builder: (context, state) {
          final transportMode = state.extra as String? ?? 'walking';
          return AIRoutePlannerScreen(
            onCancel: () => context.go(AppRoutes.home),
            transportMode: transportMode,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.routeReady,
        builder: (context, state) {
          // Extra can be either a RouteResult (from ai planner) or a String (legacy)
          final extra = state.extra;
          RouteResult? routeResult;
          String transportMode = 'walking';

          if (extra is RouteResult) {
            routeResult = extra;
            transportMode = extra.transportType;
          } else if (extra is String) {
            transportMode = extra;
          }

          return RouteReadyScreen(
            onCancel: () => context.go(AppRoutes.home),
            transportMode: transportMode,
            routeResult: routeResult,
          );
        },
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

/// Simple splash screen for loading state
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'GezAI',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
