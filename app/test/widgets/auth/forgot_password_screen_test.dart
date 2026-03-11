import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gez_ai/screens/auth/forgot_password_screen.dart';

import '../../helpers/test_utils.dart';

void main() {
  group('ForgotPasswordScreen - Widget Rendering', () {
    testWidgets('renders all UI elements', (tester) async {
      await pumpApp(tester, const ForgotPasswordScreen());

      // Title and subtitle
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('No worries! Enter your email address and we\'ll send you a reset link.'), findsOneWidget);

      // Email field
      expect(find.text('Enter your email'), findsOneWidget);

      // Button
      expect(find.text('Send Reset Link'), findsOneWidget);

      // Back to Sign In link
      expect(find.text('Back to Sign In'), findsOneWidget);

      // Back button
      expect(find.byIcon(Icons.arrow_back), findsNWidgets(2)); // Top back button + "Back to Sign In" icon
    });

    testWidgets('renders lock icon', (tester) async {
      await pumpApp(tester, const ForgotPasswordScreen());

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('renders question mark icon', (tester) async {
      await pumpApp(tester, const ForgotPasswordScreen());

      expect(find.byIcon(Icons.question_mark), findsOneWidget);
    });

    testWidgets('renders email field icon', (tester) async {
      await pumpApp(tester, const ForgotPasswordScreen());

      expect(find.byIcon(Icons.mail_outline), findsOneWidget);
    });
  });

  group('ForgotPasswordScreen - Email Validation', () {
    testWidgets('shows error when email is empty', (tester) async {
      await pumpApp(tester, const ForgotPasswordScreen());

      // Tap send button without entering email
      final sendButton = find.text('Send Reset Link');
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows error when email is invalid', (tester) async {
      await pumpApp(tester, const ForgotPasswordScreen());

      // Enter invalid email (no @)
      final emailField = find.widgetWithText(TextFormField, 'Enter your email');
      await tester.enterText(emailField, 'invalidemail');
      await tester.pump();

      // Tap send button
      final sendButton = find.text('Send Reset Link');
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('accepts valid email', (tester) async {
      await pumpApp(tester, const ForgotPasswordScreen());

      // Enter valid email
      final emailField = find.widgetWithText(TextFormField, 'Enter your email');
      await tester.enterText(emailField, TestEmails.valid);
      await tester.pump();

      // Tap send button
      final sendButton = find.text('Send Reset Link');
      await tester.tap(sendButton);
      await tester.pump();

      // Email validation error should not appear
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter a valid email'), findsNothing);
    });
  });

  group('ForgotPasswordScreen - Button State', () {
    testWidgets('send button is enabled by default', (tester) async {
      await pumpApp(tester, const ForgotPasswordScreen());

      final sendButton = find.widgetWithText(ElevatedButton, 'Send Reset Link');
      final button = tester.widget<ElevatedButton>(sendButton);

      expect(button.onPressed, isNotNull);
    });
  });

  group('ForgotPasswordScreen - Navigation', () {
    testWidgets('top back button is present', (tester) async {
      await pumpApp(tester, const ForgotPasswordScreen());

      // Should find back button icon at the top
      expect(find.byIcon(Icons.arrow_back), findsAtLeastNWidgets(1));
    });

    testWidgets('back to sign in link is tappable', (tester) async {
      await pumpApp(tester, const ForgotPasswordScreen());

      final backLink = find.text('Back to Sign In');
      expect(backLink, findsOneWidget);

      // Verify it's wrapped in an InkWell (tappable)
      final inkWell = find.ancestor(
        of: backLink,
        matching: find.byType(InkWell),
      );
      expect(inkWell, findsOneWidget);
    });
  });

  group('ForgotPasswordScreen - Focus Behavior', () {
    testWidgets('email field can receive focus', (tester) async {
      await pumpApp(tester, const ForgotPasswordScreen());

      final emailField = find.widgetWithText(TextFormField, 'Enter your email');
      await tester.tap(emailField);
      await tester.pump();

      expect(emailField, findsOneWidget);
    });
  });
}
