import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_contracts.dart';
import '../config/supabase_config.dart';

/// User-friendly exception thrown on authentication failures.
class AuthServiceException implements Exception {
  final String message;
  final String? code;

  const AuthServiceException(this.message, {this.code});

  @override
  String toString() => 'AuthServiceException: $message ($code)';
}

/// Concrete Supabase Authentication gateway interacting directly with Supabase Auth API.
class SupabaseAuthService implements SupabaseAuthGateway {
  final SupabaseClient? _client;

  SupabaseAuthService({SupabaseClient? client})
      : _client = client ?? (SupabaseConfig.isInitialized ? Supabase.instance.client : null);

  SupabaseClient get _activeClient {
    if (_client != null) return _client;
    if (SupabaseConfig.isInitialized) return Supabase.instance.client;
    throw const AuthServiceException(
      'Authentication service is not configured. Please check your connection.',
      code: 'UNCONFIGURED',
    );
  }

  /// Maps Supabase and network exceptions to clear, user-friendly messages.
  static String mapAuthError(dynamic error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      final code = error.statusCode;

      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid_credentials') ||
          code == '400') {
        return 'Incorrect email or password. Please verify your credentials.';
      }
      if (msg.contains('user already registered') ||
          msg.contains('already been registered') ||
          msg.contains('user_already_exists')) {
        return 'An account with this email already exists. Please sign in instead.';
      }
      if (msg.contains('password') && (msg.contains('least 6') || msg.contains('short') || msg.contains('weak'))) {
        return 'Password is too weak. Please use at least 6 characters.';
      }
      if (msg.contains('email not confirmed') || msg.contains('unconfirmed')) {
        return 'Please confirm your email address before signing in.';
      }
      if (msg.contains('invalid email') || msg.contains('valid email')) {
        return 'Please enter a valid email address.';
      }
      if (msg.contains('rate limit') || msg.contains('too many requests') || code == '429') {
        return 'Too many attempts. Please wait a moment and try again.';
      }
      return error.message;
    }

    final raw = error.toString().toLowerCase();
    if (raw.contains('socketexception') ||
        raw.contains('failed host lookup') ||
        raw.contains('connection refused') ||
        raw.contains('network is unreachable') ||
        raw.contains('handshake') ||
        raw.contains('timeout')) {
      return 'Unable to connect to the authentication server. Please check your internet connection.';
    }

    return 'Authentication failed. Please try again.';
  }

  @override
  Future<AuthSession> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final trimmedEmail = email.trim();
      final response = await _activeClient.auth.signUp(
        email: trimmedEmail,
        password: password,
        data: displayName != null && displayName.trim().isNotEmpty
            ? {'display_name': displayName.trim(), 'name': displayName.trim()}
            : null,
      );

      final session = response.session;
      final user = response.user;

      if (session != null) {
        final name = (user?.userMetadata?['display_name'] as String?) ??
            (user?.userMetadata?['name'] as String?) ??
            displayName;
        final role = (user?.appMetadata['role'] as String?) ??
            (user?.userMetadata?['role'] as String?) ??
            'user';
        return AuthSession(
          accessToken: session.accessToken,
          userId: session.user.id,
          email: session.user.email,
          displayName: name,
          role: role,
        );
      } else if (user != null) {
        // When email confirmation is enabled, session may be null initially.
        final role = (user.appMetadata['role'] as String?) ??
            (user.userMetadata?['role'] as String?) ??
            'user';
        return AuthSession(
          accessToken: '',
          userId: user.id,
          email: user.email,
          displayName: displayName,
          role: role,
        );
      }

      throw const AuthServiceException('Sign-up completed without a valid user.');
    } catch (e) {
      if (e is AuthServiceException) rethrow;
      throw AuthServiceException(mapAuthError(e));
    }
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final trimmedEmail = email.trim();
      final response = await _activeClient.auth.signInWithPassword(
        email: trimmedEmail,
        password: password,
      );

      final session = response.session;
      if (session == null) {
        throw const AuthServiceException('Sign-in did not return a valid session.');
      }

      final user = session.user;
      final name = (user.userMetadata?['display_name'] as String?) ??
          (user.userMetadata?['name'] as String?);
      final role = (user.appMetadata['role'] as String?) ??
          (user.userMetadata?['role'] as String?) ??
          'user';

      return AuthSession(
        accessToken: session.accessToken,
        userId: user.id,
        email: user.email,
        displayName: name,
        role: role,
      );
    } catch (e) {
      if (e is AuthServiceException) rethrow;
      throw AuthServiceException(mapAuthError(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _activeClient.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SupabaseAuthService] Sign-out warning: $e');
      }
    }
  }

  @override
  Future<AuthSession?> restoreSession() async {
    try {
      final session = _activeClient.auth.currentSession;
      if (session == null || session.isExpired) {
        return null;
      }

      final user = session.user;
      final name = (user.userMetadata?['display_name'] as String?) ??
          (user.userMetadata?['name'] as String?);
      final role = (user.appMetadata['role'] as String?) ??
          (user.userMetadata?['role'] as String?) ??
          'user';

      return AuthSession(
        accessToken: session.accessToken,
        userId: user.id,
        email: user.email,
        displayName: name,
        role: role,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SupabaseAuthService] Session restoration warning: $e');
      }
      return null;
    }
  }

  @override
  Stream<AuthSession?> get onAuthStateChange {
    if (!SupabaseConfig.isInitialized && _client == null) {
      return const Stream.empty();
    }
    return _activeClient.auth.onAuthStateChange.map((data) {
      final session = data.session;
      if (session == null) return null;
      final user = session.user;
      final name = (user.userMetadata?['display_name'] as String?) ??
          (user.userMetadata?['name'] as String?);
      final role = (user.appMetadata['role'] as String?) ??
          (user.userMetadata?['role'] as String?) ??
          'user';
      return AuthSession(
        accessToken: session.accessToken,
        userId: user.id,
        email: user.email,
        displayName: name,
        role: role,
      );
    });
  }
}
