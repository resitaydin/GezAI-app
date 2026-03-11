import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return await currentUser?.getIdToken(forceRefresh);
  }

  // ===== EMAIL/PASSWORD =====

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _userFromCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code), code: e.code);
    }
  }

  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      return _userFromCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code), code: e.code);
    }
  }

  // ===== GOOGLE SIGN-IN =====

  Future<AppUser> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException('Google sign-in cancelled');
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      return _userFromCredential(userCredential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code), code: e.code);
    } catch (e) {
      throw AuthException('Google sign-in failed: $e');
    }
  }

  // ===== SIGN OUT =====

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ===== PASSWORD RESET =====

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code), code: e.code);
    }
  }

  // ===== EMAIL VERIFICATION =====

  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code), code: e.code);
    }
  }

  Future<void> reloadUser() async {
    await currentUser?.reload();
  }

  // ===== PROFILE UPDATE =====

  Future<void> updateDisplayName(String displayName) async {
    await currentUser?.updateDisplayName(displayName);
    await currentUser?.reload();
  }

  Future<void> updatePhotoUrl(String photoUrl) async {
    await currentUser?.updatePhotoURL(photoUrl);
    await currentUser?.reload();
  }

  // ===== HELPERS =====

  AppUser _userFromCredential(UserCredential credential) {
    final user = credential.user!;
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime,
    );
  }

  AppUser? getCurrentAppUser() {
    final user = currentUser;
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime,
    );
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'user-not-found';
      case 'wrong-password':
        return 'wrong-password';
      case 'invalid-credential':
        return 'invalid-credential';
      case 'invalid-email':
        return 'invalid-email';
      case 'user-disabled':
        return 'user-disabled';
      case 'email-already-in-use':
        return 'email-already-in-use';
      case 'weak-password':
        return 'weak-password';
      case 'operation-not-allowed':
        return 'operation-not-allowed';
      case 'too-many-requests':
        return 'too-many-requests';
      case 'network-request-failed':
        return 'network-request-failed';
      case 'expired-action-code':
        return 'expired-action-code';
      case 'invalid-action-code':
        return 'invalid-action-code';
      case 'requires-recent-login':
        return 'requires-recent-login';
      case 'account-exists-with-different-credential':
        return 'account-exists-with-different-credential';
      case 'credential-already-in-use':
        return 'credential-already-in-use';
      default:
        return 'unknown-error';
    }
  }
}
