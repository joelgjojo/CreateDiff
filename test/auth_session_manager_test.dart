import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creatediff/services/auth_contracts.dart';
import 'package:creatediff/services/session_token_store.dart';

class _FakeGateway implements SupabaseAuthGateway {
  @override
  Future<AuthSession> signUp({required String email, required String password}) async =>
      const AuthSession(accessToken: 'signup-token', userId: 'user-1', email: 'a@example.com');
  @override
  Future<AuthSession> signIn({required String email, required String password}) async =>
      const AuthSession(accessToken: 'signin-token', userId: 'user-1', email: 'a@example.com');
  @override
  Future<void> signOut() async {}
  @override
  Future<AuthSession?> restoreSession() async =>
      const AuthSession(accessToken: 'restored-token', userId: 'user-1', email: 'a@example.com');
}

void main() {
  test('registration, login, restore, token persistence, and logout', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await SessionTokenStore.init(prefs);
    final manager = SupabaseSessionManager(gateway: _FakeGateway());

    await manager.signUp(email: 'a@example.com', password: 'secure-password');
    expect(manager.isAuthenticated, isTrue);
    expect(SessionTokenStore.accessToken, 'signup-token');

    await manager.signIn(email: 'a@example.com', password: 'secure-password');
    expect(SessionTokenStore.accessToken, 'signin-token');

    await manager.restoreSession();
    expect(SessionTokenStore.accessToken, 'restored-token');

    await manager.logout();
    expect(manager.isAuthenticated, isFalse);
    expect(SessionTokenStore.accessToken, isNull);
  });
}
