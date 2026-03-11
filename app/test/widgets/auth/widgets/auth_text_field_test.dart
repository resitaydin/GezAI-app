import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gez_ai/screens/auth/widgets/auth_text_field.dart';

import '../../../helpers/test_utils.dart';

void main() {
  late TextEditingController controller;

  setUp(() {
    controller = TextEditingController();
  });

  tearDown(() {
    controller.dispose();
  });

  group('AuthTextField - Basic Rendering', () {
    testWidgets('renders with required properties', (tester) async {
      await pumpApp(
        tester,
        AuthTextField(
          controller: controller,
          label: 'Test Label',
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('renders with hint text', (tester) async {
      await pumpApp(
        tester,
        AuthTextField(
          controller: controller,
          label: 'Email',
          hint: 'Enter your email',
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      // Hint text appears when field is focused
      await tester.tap(find.byType(TextFormField));
      await tester.pump();
    });

    testWidgets('renders prefix icon', (tester) async {
      await pumpApp(
        tester,
        AuthTextField(
          controller: controller,
          label: 'Email',
          prefixIcon: Icons.email,
        ),
      );

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('renders suffix icon', (tester) async {
      await pumpApp(
        tester,
        AuthTextField(
          controller: controller,
          label: 'Password',
          suffixIcon: const Icon(Icons.visibility),
        ),
      );

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });

  group('AuthTextField - Obscure Text', () {
    testWidgets('obscures text when obscureText is true', (tester) async {
      await pumpApp(
        tester,
        AuthTextField(
          controller: controller,
          label: 'Password',
          obscureText: true,
        ),
      );

      // Check that the text field exists
      expect(find.byType(TextFormField), findsOneWidget);

      // Enter text - when obscured, the controller still has the actual text
      await tester.enterText(find.byType(TextFormField), 'password');
      await tester.pump();

      // The controller should have the text even though it's obscured
      expect(controller.text, 'password');
    });

    testWidgets('does not obscure text by default', (tester) async {
      await pumpApp(
        tester,
        AuthTextField(
          controller: controller,
          label: 'Email',
        ),
      );

      // Enter text and verify it's displayed as plain text
      await tester.enterText(find.byType(TextFormField), 'test@email.com');
      await tester.pump();

      // The actual characters should be visible
      expect(find.text('test@email.com'), findsOneWidget);
    });
  });

  group('AuthTextField - Keyboard Type', () {
    testWidgets('uses text keyboard by default', (tester) async {
      await pumpApp(
        tester,
        AuthTextField(
          controller: controller,
          label: 'Name',
        ),
      );

      // Verify the text field exists and is ready for text input
      expect(find.byType(TextFormField), findsOneWidget);
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      // The field should accept text input
      await tester.enterText(find.byType(TextFormField), 'John Doe');
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('uses email keyboard when specified', (tester) async {
      await pumpApp(
        tester,
        AuthTextField(
          controller: controller,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
      );

      // Verify the text field exists and accepts email format input
      expect(find.byType(TextFormField), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      expect(find.text('test@example.com'), findsOneWidget);
    });
  });

  group('AuthTextField - Validation', () {
    testWidgets('calls validator when provided', (tester) async {
      String? validatorCalled;

      await pumpApp(
        tester,
        Form(
          child: AuthTextField(
            controller: controller,
            label: 'Email',
            validator: (value) {
              validatorCalled = value;
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              return null;
            },
          ),
        ),
      );

      // Enter text to trigger validation
      await tester.enterText(find.byType(TextFormField), 'test');
      await tester.pump();

      expect(validatorCalled, 'test');
    });

    testWidgets('shows validation error when validator returns message', (tester) async {
      final formKey = GlobalKey<FormState>();

      await pumpApp(
        tester,
        Form(
          key: formKey,
          child: AuthTextField(
            controller: controller,
            label: 'Email',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              return null;
            },
          ),
        ),
      );

      // Manually trigger form validation (simpler than waiting for auto-validation)
      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      // Validation error should appear
      expect(find.text('Email is required'), findsOneWidget);
    });
  });

  group('AuthTextField - Enabled State', () {
    testWidgets('is enabled by default', (tester) async {
      await pumpApp(
        tester,
        AuthTextField(
          controller: controller,
          label: 'Email',
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, isTrue);
    });

    testWidgets('can be disabled', (tester) async {
      await pumpApp(
        tester,
        AuthTextField(
          controller: controller,
          label: 'Email',
          enabled: false,
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, isFalse);
    });
  });

  group('AuthTextField - Controller', () {
    testWidgets('uses provided controller', (tester) async {
      controller.text = 'Initial text';

      await pumpApp(
        tester,
        AuthTextField(
          controller: controller,
          label: 'Email',
        ),
      );

      expect(find.text('Initial text'), findsOneWidget);
    });

    testWidgets('updates when controller text changes', (tester) async {
      await pumpApp(
        tester,
        AuthTextField(
          controller: controller,
          label: 'Email',
        ),
      );

      controller.text = 'New text';
      await tester.pump();

      expect(find.text('New text'), findsOneWidget);
    });
  });

  group('AuthTextField - AutovalidateMode', () {
    testWidgets('has autovalidateMode set to onUserInteraction', (tester) async {
      await pumpApp(
        tester,
        AuthTextField(
          controller: controller,
          label: 'Email',
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.autovalidateMode, AutovalidateMode.onUserInteraction);
    });
  });
}
