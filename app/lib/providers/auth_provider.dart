import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

/// Auth service singleton
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Stream of Firebase auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Current auth state for routing decisions
enum AuthState { initial, authenticated, unauthenticated }

final authStatusProvider = Provider<AuthState>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return AuthState.unauthenticated;
      // TODO: Email verification temporarily disabled for testing
      // Check if email is verified for email/password users
      // if (user.providerData.any((p) => p.providerId == 'password') &&
      //     !user.emailVerified) {
      //   return AuthState.unauthenticated;
      // }
      return AuthState.authenticated;
    },
    loading: () => AuthState.initial,
    error: (_, __) => AuthState.unauthenticated,
  );
});

/// Auth controller for sign-in/sign-up actions
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AppUser?>>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AsyncValue<AppUser?>> {
  final Ref _ref;

  AuthController(this._ref) : super(const AsyncValue.data(null));

  AuthService get _authService => _ref.read(authServiceProvider);

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String? displayName,
  ) async {
    state = const AsyncValue.loading();

    try {
      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      // TODO: Email verification temporarily disabled for testing
      // Send email verification
      // await _authService.sendEmailVerification();

      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final user = await _authService.signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  Future<void> reloadUser() async {
    await _authService.reloadUser();
  }
}
