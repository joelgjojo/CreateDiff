import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creatediff/screens/auth_screen.dart';
import 'package:creatediff/services/app_state.dart';
import 'package:creatediff/services/session_token_store.dart';
import 'package:creatediff/services/storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await SessionTokenStore.init(prefs);
    await StorageService.init(prefs);
    await AppState.instance.init();
  });

  testWidgets('AuthScreen renders Sign In form by default and toggles to Sign Up', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthScreen(initialIsSignUp: false),
      ),
    );

    expect(find.text('Sign In to CreateDiff'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In ✦'), findsOneWidget);
    expect(find.text('Display Name'), findsNothing);

    // Scroll to and toggle to Sign Up
    final toggleFinder = find.text('Create Account');
    await tester.ensureVisible(toggleFinder);
    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();

    expect(find.text('Create Studio Account'), findsOneWidget);
    expect(find.text('Display Name'), findsOneWidget);
    expect(find.text('Create Account ✦'), findsOneWidget);
  });

  testWidgets('AuthScreen shows validation error on empty email submission', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthScreen(initialIsSignUp: false),
      ),
    );

    await tester.tap(find.text('Sign In ✦'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email address.'), findsOneWidget);
  });
}
