import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creatediff/screens/profile_screen.dart';
import 'package:creatediff/services/app_state.dart';
import 'package:creatediff/services/auth_contracts.dart';
import 'package:creatediff/services/session_token_store.dart';
import 'package:creatediff/services/storage_service.dart';

class _MockUserIdentity implements UserIdentity {
  @override
  final String id = 'test-user-123';
  @override
  final String? email = 'creator@example.com';
  @override
  final String? displayName = 'Alex Creator';
  @override
  final String role = 'user';
  @override
  bool get isAdmin => false;
  @override
  final bool isAnonymous = false;
  @override
  final DateTime createdAt = DateTime(2026, 1, 1);
}

class _MockSessionManager implements SessionManager {
  final UserIdentity? _user;
  _MockSessionManager(this._user);

  @override
  UserIdentity? get currentUser => _user;
  @override
  bool get isAuthenticated => _user != null;
  @override
  Future<void> restoreSession() async {}
  @override
  Future<void> loginWithProvider(String provider) async {}
  @override
  Future<void> logout() async {}
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await SessionTokenStore.init(prefs);
    await StorageService.init(prefs);
    await AppState.instance.init();
  });

  testWidgets('ProfileScreen renders Guest Mode badge when unauthenticated', (tester) async {
    AppState.instance.setSessionManagerForTesting(LocalSessionManager());

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('GUEST MODE'), findsOneWidget);
    expect(find.text('Sign In / Create Account ✦'), findsOneWidget);
  });

  testWidgets('ProfileScreen renders AUTHENTICATED badge and user details when authenticated', (tester) async {
    AppState.instance.setSessionManagerForTesting(_MockSessionManager(_MockUserIdentity()));

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AUTHENTICATED'), findsOneWidget);
    expect(find.text('Alex Creator'), findsOneWidget);
    expect(find.text('creator@example.com'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
    expect(find.text('ADMIN'), findsNothing);
  });

  testWidgets('ProfileScreen renders ADMIN badge when authenticated user has admin role', (tester) async {
    final adminUser = _MockAdminIdentity();
    AppState.instance.setSessionManagerForTesting(_MockSessionManager(adminUser));

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AUTHENTICATED'), findsOneWidget);
    expect(find.text('ADMIN'), findsOneWidget);
    expect(find.text('Admin Creator'), findsOneWidget);
  });
}

class _MockAdminIdentity implements UserIdentity {
  @override
  final String id = 'admin-user-999';
  @override
  final String? email = 'admin@creatediff.com';
  @override
  final String? displayName = 'Admin Creator';
  @override
  final String role = 'admin';
  @override
  bool get isAdmin => true;
  @override
  final bool isAnonymous = false;
  @override
  final DateTime createdAt = DateTime(2026, 1, 1);
}
