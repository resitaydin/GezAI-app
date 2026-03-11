import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper function to pump a widget wrapped with MaterialApp and ProviderScope
Future<void> pumpApp(
  WidgetTester tester,
  Widget widget, {
  List<Override>? overrides,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides ?? [],
      child: MaterialApp(
        home: Scaffold(
          body: widget,
        ),
      ),
    ),
  );
}

/// Helper function to pump a widget with GoRouter for navigation testing
/// Note: Requires proper router setup - not used in basic widget tests
Future<void> pumpAppWithRouter(
  WidgetTester tester,
  Widget widget, {
  List<Override>? overrides,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides ?? [],
      child: MaterialApp(
        home: widget,
      ),
    ),
  );

  await tester.pumpAndSettle();
}

/// Test data for valid email addresses
class TestEmails {
  static const valid = 'test@example.com';
  static const valid2 = 'user@test.com';
  static const invalid = 'invalid-email';
  static const empty = '';
  static const noAt = 'testexample.com';
}

/// Test data for passwords
class TestPasswords {
  static const valid = 'password123';
  static const weak = '12345';
  static const strong = 'StrongP@ss123!';
  static const empty = '';
  static const short = 'pass';
  static const long = 'ThisIsAVeryLongPasswordThatMeetsAllRequirements123!';
}

/// Test data for user display names
class TestNames {
  static const valid = 'John Doe';
  static const short = 'J';
  static const long = 'A Very Long Name That Is Still Valid';
  static const empty = '';
}

/// Common widget finders for auth screens
class AuthFinders {
  // Text fields
  static final emailField = find.byKey(const Key('email_field'));
  static final passwordField = find.byKey(const Key('password_field'));
  static final confirmPasswordField = find.byKey(const Key('confirm_password_field'));
  static final nameField = find.byKey(const Key('name_field'));

  // Buttons
  static final loginButton = find.byKey(const Key('login_button'));
  static final signupButton = find.byKey(const Key('signup_button'));
  static final forgotPasswordButton = find.byKey(const Key('forgot_password_button'));
  static final googleSignInButton = find.byKey(const Key('google_signin_button'));
  static final submitButton = find.byKey(const Key('submit_button'));
  static final resendButton = find.byKey(const Key('resend_button'));

  // Links
  static final forgotPasswordLink = find.text('Forgot Password?');
  static final signupLink = find.text('Sign up');
  static final loginLink = find.text('Log in');

  // Icons
  static final passwordVisibilityIcon = find.byIcon(Icons.visibility);
  static final passwordVisibilityOffIcon = find.byIcon(Icons.visibility_off);

  // Other
  static final termsCheckbox = find.byKey(const Key('terms_checkbox'));
  static final passwordStrengthIndicator = find.byKey(const Key('password_strength_indicator'));
}

/// Helper to find text containing a substring
Finder findTextContaining(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is Text && widget.data?.contains(text) == true,
  );
}

/// Helper to enter text in a field
Future<void> enterText(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.enterText(finder, text);
  await tester.pump();
}

/// Helper to tap a widget and wait for animations
Future<void> tapAndSettle(
  WidgetTester tester,
  Finder finder,
) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Helper to verify a SnackBar is shown with specific text
void expectSnackBar(String text) {
  expect(find.byType(SnackBar), findsOneWidget);
  expect(findTextContaining(text), findsOneWidget);
}

/// Helper to verify no SnackBar is shown
void expectNoSnackBar() {
  expect(find.byType(SnackBar), findsNothing);
}
