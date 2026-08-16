/// Abstract User Identity contract ready for Phase 2 authentication (Firebase/Supabase/Custom)
abstract class UserIdentity {
  String get id;
  String? get email;
  String? get displayName;
  bool get isAnonymous;
  DateTime get createdAt;
}

/// Abstract Session Manager contract for managing user sessions and tokens
abstract class SessionManager {
  UserIdentity? get currentUser;
  bool get isAuthenticated;

  Future<void> restoreSession();
  Future<void> loginWithProvider(String provider);
  Future<void> logout();
}

/// Abstract Permission Layer for gating tier-based features and generation quotas
abstract class PermissionLayer {
  bool get isPremium;
  int get dailyGenerationQuota;
  bool canAccessTemplate(String templateId);
}

/// Default Local Session Manager for Pre-Launch (single local user state)
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
