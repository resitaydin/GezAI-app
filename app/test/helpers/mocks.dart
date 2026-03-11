import 'package:firebase_auth/firebase_auth.dart';
import 'package:gez_ai/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';

// Generate mocks with:
// flutter pub run build_runner build

@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  AuthService,
])
void main() {}
