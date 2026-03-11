import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gez_ai/screens/auth/signup_screen.dart';

import '../../helpers/test_utils.dart';

void main() {
  // Ignore network image loading errors in tests
  setUpAll(() {
    FlutterError.onError = (details) {
      if (details.exception.toString().contains('NetworkImage') ||
          details.exception.toString().contains('HTTP request failed')) {
        return;
      }
      FlutterError.dumpErrorToConsole(details);
    };
  });

  tearDownAll(() {
    FlutterError.onError = FlutterError.dumpErrorToConsole;
  });

  group('SignupScreen - Widget Rendering', () {
    testWidgets('renders all UI elements', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Header text
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Start planning your Istanbul adventure'), findsOneWidget);

      // Form fields
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);

      // Terms checkbox text
      expect(find.text('I agree to the '), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);

      // Buttons
      expect(find.text('Create Account'), findsNWidgets(2)); // Header + button
      expect(find.text('Sign in with Google'), findsOneWidget);

      // Links
      expect(find.text('Sign In'), findsOneWidget);

      // Back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('renders password visibility toggle icons', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Initially both passwords should show visibility_off icon (hidden)
      expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(2));
    });

    testWidgets('renders checkbox for terms', (tester) async {
      await pumpApp(tester, const SignupScreen());

      expect(find.byType(Checkbox), findsOneWidget);
    });
  });

  group('SignupScreen - Name Validation', () {
    testWidgets('shows error when name is empty', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Tap create account button without entering name
      final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your name'), findsOneWidget);
    });

    testWidgets('accepts non-empty name', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Enter name
      final nameField = find.widgetWithText(TextFormField, 'Full Name');
      await tester.enterText(nameField, TestNames.valid);
      await tester.pump();

      // Enter other required fields
      final emailField = find.widgetWithText(TextFormField, 'Email Address');
      await tester.enterText(emailField, TestEmails.valid);
      await tester.pump();

      final passwordField = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(passwordField, TestPasswords.valid);
      await tester.pump();

      final confirmField = find.widgetWithText(TextFormField, 'Confirm Password');
      await tester.enterText(confirmField, TestPasswords.valid);
      await tester.pump();

      // Tap checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Tap create account
      final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.tap(createButton);
      await tester.pump();

      // Name validation error should not appear
      expect(find.text('Please enter your name'), findsNothing);
    });
  });

  group('SignupScreen - Email Validation', () {
    testWidgets('shows error when email is empty', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Enter name but not email
      final nameField = find.widgetWithText(TextFormField, 'Full Name');
      await tester.enterText(nameField, TestNames.valid);
      await tester.pump();

      // Tap create account
      final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows error when email is invalid', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Enter name
      final nameField = find.widgetWithText(TextFormField, 'Full Name');
      await tester.enterText(nameField, TestNames.valid);
      await tester.pump();

      // Enter invalid email (no @)
      final emailField = find.widgetWithText(TextFormField, 'Email Address');
      await tester.enterText(emailField, 'invalidemail');
      await tester.pump();

      // Tap create account
      final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });
  });

  group('SignupScreen - Password Validation', () {
    testWidgets('shows error when password is empty', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Enter name and email
      final nameField = find.widgetWithText(TextFormField, 'Full Name');
      await tester.enterText(nameField, TestNames.valid);
      await tester.pump();

      final emailField = find.widgetWithText(TextFormField, 'Email Address');
      await tester.enterText(emailField, TestEmails.valid);
      await tester.pump();

      // Tap create account without entering password
      final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a password'), findsOneWidget);
    });

    testWidgets('shows error when password is too short', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Enter name and email
      final nameField = find.widgetWithText(TextFormField, 'Full Name');
      await tester.enterText(nameField, TestNames.valid);
      await tester.pump();

      final emailField = find.widgetWithText(TextFormField, 'Email Address');
      await tester.enterText(emailField, TestEmails.valid);
      await tester.pump();

      // Enter short password (< 6 chars)
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(passwordField, '12345');
      await tester.pump();

      // Tap create account
      final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });
  });

  group('SignupScreen - Confirm Password Validation', () {
    testWidgets('shows error when confirm password is empty', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Enter all fields except confirm password
      final nameField = find.widgetWithText(TextFormField, 'Full Name');
      await tester.enterText(nameField, TestNames.valid);
      await tester.pump();

      final emailField = find.widgetWithText(TextFormField, 'Email Address');
      await tester.enterText(emailField, TestEmails.valid);
      await tester.pump();

      final passwordField = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(passwordField, TestPasswords.valid);
      await tester.pump();

      // Tap create account without confirm password
      final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('shows error when passwords do not match', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Enter all fields
      final nameField = find.widgetWithText(TextFormField, 'Full Name');
      await tester.enterText(nameField, TestNames.valid);
      await tester.pump();

      final emailField = find.widgetWithText(TextFormField, 'Email Address');
      await tester.enterText(emailField, TestEmails.valid);
      await tester.pump();

      final passwordField = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(passwordField, TestPasswords.valid);
      await tester.pump();

      // Enter different password in confirm field
      final confirmField = find.widgetWithText(TextFormField, 'Confirm Password');
      await tester.enterText(confirmField, 'differentpassword');
      await tester.pump();

      // Tap create account
      final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('SignupScreen - Password Strength Indicator', () {
    testWidgets('does not show indicator when password is empty', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Password strength text should not be visible
      expect(find.text('Weak'), findsNothing);
      expect(find.text('Medium'), findsNothing);
      expect(find.text('Good'), findsNothing);
      expect(find.text('Strong'), findsNothing);
    });

    testWidgets('shows Weak for 8+ characters', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Enter 8 character password with no special requirements
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(passwordField, 'password');
      await tester.pump();

      expect(find.text('Weak'), findsOneWidget);
    });

    testWidgets('shows Medium for 8+ chars with uppercase', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Enter password with 8+ chars and uppercase
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(passwordField, 'Password');
      await tester.pump();

      expect(find.text('Medium'), findsOneWidget);
    });

    testWidgets('shows Good for 8+ chars with uppercase and number', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Enter password with 8+ chars, uppercase, and number
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(passwordField, 'Password1');
      await tester.pump();

      expect(find.text('Good'), findsOneWidget);
    });

    testWidgets('shows Strong for 8+ chars with uppercase, number, and special char', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Enter password with all requirements
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(passwordField, 'Password1!');
      await tester.pump();

      expect(find.text('Strong'), findsOneWidget);
    });
  });

  group('SignupScreen - Password Visibility Toggle', () {
    testWidgets('toggles password visibility when icon is tapped', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Initially, visibility_off icons should be shown (passwords hidden)
      expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(2));
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);

      // Tap the first password visibility toggle (password field)
      await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
      await tester.pump();

      // Now should have one visible and one hidden
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('toggles confirm password visibility independently', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Tap the second password visibility toggle (confirm password field)
      await tester.tap(find.byIcon(Icons.visibility_off_outlined).last);
      await tester.pump();

      // Should have one visible and one hidden
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });

  group('SignupScreen - Terms Checkbox', () {
    testWidgets('checkbox starts unchecked', (tester) async {
      await pumpApp(tester, const SignupScreen());

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('checkbox can be checked', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Tap checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('checkbox can be unchecked after being checked', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Tap twice to check then uncheck
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });
  });

  group('SignupScreen - Form Submission', () {
    testWidgets('create account button is enabled by default', (tester) async {
      await pumpApp(tester, const SignupScreen());

      final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
      final button = tester.widget<ElevatedButton>(createButton);

      expect(button.onPressed, isNotNull);
    });

    testWidgets('google button is present and enabled', (tester) async {
      await pumpApp(tester, const SignupScreen());

      final googleButton = find.widgetWithText(OutlinedButton, 'Sign in with Google');
      final button = tester.widget<OutlinedButton>(googleButton);

      expect(button.onPressed, isNotNull);
    });
  });

  group('SignupScreen - Navigation', () {
    testWidgets('back button is present', (tester) async {
      await pumpApp(tester, const SignupScreen());

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('sign in link is tappable', (tester) async {
      await pumpApp(tester, const SignupScreen());

      final signInLink = find.text('Sign In');
      expect(signInLink, findsOneWidget);

      // Verify it's wrapped in an InkWell (tappable)
      final inkWell = find.ancestor(
        of: signInLink,
        matching: find.byType(InkWell),
      );
      expect(inkWell, findsOneWidget);
    });
  });

  group('SignupScreen - Field Icons', () {
    testWidgets('renders correct icons for each field', (tester) async {
      await pumpApp(tester, const SignupScreen());

      // Check for field icons
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.mail_outline), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(2)); // Password and confirm password
    });
  });
}
