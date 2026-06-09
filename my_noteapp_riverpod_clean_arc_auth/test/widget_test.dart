// Smoke test for the login screen.
//
// LoginPage only touches Firebase when the user submits, so it can be pumped
// directly inside a ProviderScope without initialising Firebase. This verifies
// the form renders its key fields and the submit button.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/presentation/login/login_page.dart';

void main() {
  testWidgets('LoginPage renders email, password and login button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginPage()),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
  });
}
