import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gez_ai/screens/auth/verify_email_screen.dart';

import '../../helpers/test_utils.dart';

void main() {
  group('VerifyEmailScreen - Widget Rendering', () {
    testWidgets('renders all UI elements', (tester) async {
      await pumpApp(tester, const VerifyEmailScreen());

      // Title
      expect(find.text('Verify Your Email'), findsOneWidget);

      // Subtitle text
      expect(find.textContaining('We\'ve sent a verification link to'), findsOneWidget);

      // Info box text
      expect(find.text('Click the link in the email to verify your account'), findsOneWidget);

      // Buttons and links
      expect(find.text('Resend Email'), findsOneWidget);
      expect(find.text('Wrong email? Go back'), findsOneWidget);
    });

    testWidgets('renders email icons', (tester) async {
      await pumpApp(tester, const VerifyEmailScreen());

      // Main draft icon
      expect(find.byIcon(Icons.drafts), findsOneWidget);

      // Send icon (badge)
      expect(find.byIcon(Icons.send), findsOneWidget);

      // Mark email read icon (info box)
      expect(find.byIcon(Icons.mark_email_read), findsOneWidget);
    });

    testWidgets('displays user email or fallback', (tester) async {
      await pumpApp(tester, const VerifyEmailScreen());

      // Should find either an actual email or 'your email' as fallback
      // Since we don't have a signed-in user in tests, it will show 'your email'
      expect(find.textContaining('your email'), findsOneWidget);
    });
  });

  group('VerifyEmailScreen - Resend Button', () {
    testWidgets('resend button is enabled initially', (tester) async {
      await pumpApp(tester, const VerifyEmailScreen());

      final resendButton = find.widgetWithText(OutlinedButton, 'Resend Email');
      final button = tester.widget<OutlinedButton>(resendButton);

      expect(button.onPressed, isNotNull);
    });

    testWidgets('does not show countdown initially', (tester) async {
      await pumpApp(tester, const VerifyEmailScreen());

      // Countdown text should not be visible initially
      expect(find.textContaining('Resend in'), findsNothing);
    });
  });

  group('VerifyEmailScreen - Navigation', () {
    testWidgets('wrong email link is present and tappable', (tester) async {
      await pumpApp(tester, const VerifyEmailScreen());

      final wrongEmailLink = find.text('Wrong email? Go back');
      expect(wrongEmailLink, findsOneWidget);

      // Verify it's wrapped in an InkWell (tappable)
      final inkWell = find.ancestor(
        of: wrongEmailLink,
        matching: find.byType(InkWell),
      );
      expect(inkWell, findsOneWidget);
    });
  });

  group('VerifyEmailScreen - Info Box', () {
    testWidgets('info box is styled correctly', (tester) async {
      await pumpApp(tester, const VerifyEmailScreen());

      // Find the info box container
      final container = find.ancestor(
        of: find.text('Click the link in the email to verify your account'),
        matching: find.byType(Container),
      );

      expect(container, findsAtLeastNWidgets(1));
    });
  });
}
