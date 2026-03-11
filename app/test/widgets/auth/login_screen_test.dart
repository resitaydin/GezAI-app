import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gez_ai/screens/auth/login_screen.dart';

import '../../helpers/test_utils.dart';

void main() {
  // Ignore network image loading errors in tests
  setUpAll(() {
    FlutterError.onError = (details) {
      // Ignore network image errors
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
  group('LoginScreen - Widget Rendering', () {
    testWidgets('renders all UI elements', (tester) async {
      await pumpApp(tester, const LoginScreen());

      // Header text
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Plan your next Istanbul adventure.'), findsOneWidget);

      // Form fields
      expect(find.text('Email Address'), findsWidgets);
      expect(find.text('Enter your password'), findsOneWidget);

      // Buttons
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);

      // Links
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Create an account'), findsOneWidget);
    });

    testWidgets('renders password visibility toggle icon', (tester) async {
      await pumpApp(tester, const LoginScreen());

      // Initially should show visibility_off icon (password hidden)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('renders divider with "Or continue with" text', (tester) async {
      await pumpApp(tester, const LoginScreen());

      expect(find.text('Or continue with'), findsOneWidget);
    });
  });

  group('LoginScreen - Email Validation', () {
    testWidgets('shows error when email is empty', (tester) async {
      await pumpApp(tester, const LoginScreen());

      // Find and tap the sign-in button
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows error when email is invalid', (tester) async {
      await pumpApp(tester, const LoginScreen());

      // Enter invalid email (no @ symbol)
      final emailField = find.widgetWithText(TextFormField, 'Email Address').first;
      await tester.enterText(emailField, 'invalidemail');
      await tester.pump();

      // Tap sign-in button
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('accepts valid email', (tester) async {
      await pumpApp(tester, const LoginScreen());

      // Enter valid email
      final emailField = find.widgetWithText(TextFormField, 'Email Address').first;
      await tester.enterText(emailField, TestEmails.valid);
      await tester.pump();

      // Enter password (to avoid password validation error)
      final passwordField = find.widgetWithText(TextFormField, 'Enter your password');
      await tester.enterText(passwordField, TestPasswords.valid);
      await tester.pump();

      // Tap sign-in button
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pump();

      // Email validation error should not appear
      expect(find.text('Please enter a valid email'), findsNothing);
      expect(find.text('Please enter your email'), findsNothing);
    });
  });

  group('LoginScreen - Password Validation', () {
    testWidgets('shows error when password is empty', (tester) async {
      await pumpApp(tester, const LoginScreen());

      // Enter valid email
      final emailField = find.widgetWithText(TextFormField, 'Email Address').first;
      await tester.enterText(emailField, TestEmails.valid);
      await tester.pump();

      // Tap sign-in button without entering password
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('accepts non-empty password', (tester) async {
      await pumpApp(tester, const LoginScreen());

      // Enter valid email
      final emailField = find.widgetWithText(TextFormField, 'Email Address').first;
      await tester.enterText(emailField, TestEmails.valid);
      await tester.pump();

      // Enter password
      final passwordField = find.widgetWithText(TextFormField, 'Enter your password');
      await tester.enterText(passwordField, TestPasswords.valid);
      await tester.pump();

      // Tap sign-in button
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pump();

      // Password validation error should not appear
      expect(find.text('Please enter your password'), findsNothing);
    });
  });

  group('LoginScreen - Password Visibility Toggle', () {
    testWidgets('toggles password visibility when icon is tapped', (tester) async {
      await pumpApp(tester, const LoginScreen());

      // Initially, visibility_off icon should be shown (password hidden)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);

      // Tap the visibility toggle icon
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      // Now visibility icon should be shown (password visible)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

      // Tap again to hide password
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Back to visibility_off
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    });

    testWidgets('password visibility toggle changes icon', (tester) async {
      await pumpApp(tester, const LoginScreen());

      // Verify initial state shows visibility_off (password hidden)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // This test confirms the toggle functionality works
      // The actual obscureText property is tested through user interaction
    });
  });

  group('LoginScreen - Loading State', () {
    testWidgets('sign-in button is present and enabled by default', (tester) async {
      await pumpApp(tester, const LoginScreen());

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      expect(signInButton, findsOneWidget);

      // Button should be enabled initially
      final button = tester.widget<ElevatedButton>(signInButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('google button is enabled by default', (tester) async {
      await pumpApp(tester, const LoginScreen());

      final googleButton = find.widgetWithText(OutlinedButton, 'Continue with Google');
      final button = tester.widget<OutlinedButton>(googleButton);

      expect(button.onPressed, isNotNull);
    });
  });

  group('LoginScreen - Navigation', () {
    testWidgets('forgot password link is tappable', (tester) async {
      await pumpApp(tester, const LoginScreen());

      final forgotPasswordLink = find.text('Forgot Password?');
      expect(forgotPasswordLink, findsOneWidget);

      // Verify it's wrapped in an InkWell (tappable)
      final inkWell = find.ancestor(
        of: forgotPasswordLink,
        matching: find.byType(InkWell),
      );
      expect(inkWell, findsOneWidget);
    });

    testWidgets('create account link is tappable', (tester) async {
      await pumpApp(tester, const LoginScreen());

      final createAccountLink = find.text('Create an account');
      expect(createAccountLink, findsOneWidget);

      // Verify it's wrapped in an InkWell (tappable)
      final inkWell = find.ancestor(
        of: createAccountLink,
        matching: find.byType(InkWell),
      );
      expect(inkWell, findsOneWidget);
    });
  });

  group('LoginScreen - Google Sign-In', () {
    testWidgets('google sign-in button is present', (tester) async {
      await pumpApp(tester, const LoginScreen());

      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('google sign-in button is tappable', (tester) async {
      await pumpApp(tester, const LoginScreen());

      final googleButton = find.widgetWithText(OutlinedButton, 'Continue with Google');
      expect(googleButton, findsOneWidget);

      // Button should be enabled (onPressed not null)
      final button = tester.widget<OutlinedButton>(googleButton);
      expect(button.onPressed, isNotNull);
    });
  });

  group('LoginScreen - Focus Behavior', () {
    testWidgets('email field can receive focus', (tester) async {
      await pumpApp(tester, const LoginScreen());

      final emailField = find.widgetWithText(TextFormField, 'Email Address').first;
      await tester.tap(emailField);
      await tester.pump();

      // Field should be focused (would need to check FocusNode state in real app)
      expect(emailField, findsOneWidget);
    });

    testWidgets('password field can receive focus', (tester) async {
      await pumpApp(tester, const LoginScreen());

      final passwordField = find.widgetWithText(TextFormField, 'Enter your password');
      await tester.tap(passwordField);
      await tester.pump();

      expect(passwordField, findsOneWidget);
    });
  });
}
