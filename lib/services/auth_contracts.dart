import 'session_token_store.dart';

/// Abstract User Identity contract for CreateDiff authentication.
abstract class UserIdentity {
  String get id;
  String? get email;
  String? get displayName;
  bool get isAnonymous;
  DateTime get createdAt;
}

/// Abstract Session Manager contract for managing user sessions and tokens.
abstract class SessionManager {
  UserIdentity? get currentUser;
  bool get isAuthenticated;

  Future<void> restoreSession();
  Future<void> loginWithProvider(String provider);
  Future<void> logout();
}

/// Abstract Permission Layer for gating tier-based features and generation quotas.
abstract class PermissionLayer {
  bool get isPremium;
  int get dailyGenerationQuota;
  bool canAccessTemplate(String templateId);
}

/// Strongly typed authentication session representation.
class AuthSession {
  final String accessToken;
  final String userId;
  final String? email;
  final String? displayName;

  const AuthSession({
    required this.accessToken,
    required this.userId,
    this.email,
    this.displayName,
  });
}

/// Gateway interface for Supabase Authentication operations.
abstract interface class SupabaseAuthGateway {
  Future<AuthSession> signUp({
    required String email,
    required String password,
    String? displayName,
  });
  Future<AuthSession> signIn({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<AuthSession?> restoreSession();
  Stream<AuthSession?> get onAuthStateChange;
}

/// Production Supabase Session Manager coordinating authentication lifecycle.
class SupabaseSessionManager implements SessionManager, PermissionLayer {
  final SupabaseAuthGateway gateway;
  UserIdentity? _currentUser;
  void Function(UserIdentity?)? onAuthChanged;

  SupabaseSessionManager({required this.gateway, this.onAuthChanged});

  @override
  UserIdentity? get currentUser => _currentUser;
  @override
  bool get isAuthenticated => _currentUser != null;

  Future<void> _apply(AuthSession? session) async {
    if (session == null) {
      _currentUser = null;
      await SessionTokenStore.setAccessToken(null);
    } else {
      await SessionTokenStore.setAccessToken(session.accessToken);
      _currentUser = _SessionUserIdentity(
        id: session.userId,
        email: session.email,
        displayName: session.displayName,
      );
    }
    onAuthChanged?.call(_currentUser);
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final session = await gateway.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    await _apply(session);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final session = await gateway.signIn(email: email, password: password);
    await _apply(session);
  }

  @override
  Future<void> restoreSession() async {
    final session = await gateway.restoreSession();
    await _apply(session);
  }

  @override
  Future<void> loginWithProvider(String provider) async =>
      throw UnsupportedError('Use a provider-specific gateway adapter for $provider.');

  @override
  Future<void> logout() async {
    await gateway.signOut();
    await _apply(null);
  }

  @override
  bool get isPremium => false;
  @override
  int get dailyGenerationQuota => 50;
  @override
  bool canAccessTemplate(String templateId) => true;
}

class _SessionUserIdentity implements UserIdentity {
  @override
  final String id;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final bool isAnonymous = false;
  @override
  final DateTime createdAt = DateTime.now();

  _SessionUserIdentity({
    required this.id,
    this.email,
    this.displayName,
  });
}

/// Default Local Session Manager for Pre-Launch and Offline Guest Mode.
class LocalSessionManager implements SessionManager, PermissionLayer {
  final UserIdentity _localUser;

  LocalSessionManager({String localId = 'local_device_creator'})
      : _localUser = _LocalUserIdentity(id: localId);

  @override
  UserIdentity? get currentUser => _localUser;

  @override
  bool get isAuthenticated => true;

  @override
  Future<void> restoreSession() async {}

  @override
  Future<void> loginWithProvider(String provider) async {}

  @override
  Future<void> logout() async {}

  @override
  bool get isPremium => false;

  @override
  int get dailyGenerationQuota => 50;

  @override
  bool canAccessTemplate(String templateId) => true;
}

class _LocalUserIdentity implements UserIdentity {
  @override
  final String id;
  @override
  final String? email = null;
  @override
  final String? displayName = 'Local Creator';
  @override
  final bool isAnonymous = true;
  @override
  final DateTime createdAt;

  _LocalUserIdentity({required this.id}) : createdAt = DateTime(2026, 1, 1);
}
