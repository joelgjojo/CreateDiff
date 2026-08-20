import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:creatediff/services/supabase_auth_service.dart';

void main() {
  group('SupabaseAuthService Error Mapping', () {
    test('maps invalid credentials error into user-friendly message', () {
      const ex = AuthException('Invalid login credentials', statusCode: '400');
      final msg = SupabaseAuthService.mapAuthError(ex);
      expect(msg, 'Incorrect email or password. Please verify your credentials.');
    });

    test('maps user already exists error into friendly message', () {
      const ex = AuthException('User already registered', statusCode: '422');
      final msg = SupabaseAuthService.mapAuthError(ex);
      expect(msg, 'An account with this email already exists. Please sign in instead.');
    });

    test('maps weak password error into friendly message', () {
      const ex = AuthException('Password should be at least 6 characters');
      final msg = SupabaseAuthService.mapAuthError(ex);
      expect(msg, 'Password is too weak. Please use at least 6 characters.');
    });

    test('maps unconfirmed email error into friendly message', () {
      const ex = AuthException('Email not confirmed');
      final msg = SupabaseAuthService.mapAuthError(ex);
      expect(msg, 'Please confirm your email address before signing in.');
    });

    test('maps rate limit error into friendly message', () {
      const ex = AuthException('over_email_send_rate_limit', statusCode: '429');
      final msg = SupabaseAuthService.mapAuthError(ex);
      expect(msg, 'Too many attempts. Please wait a moment and try again.');
    });

    test('maps network exceptions gracefully', () {
      final msg = SupabaseAuthService.mapAuthError(Exception('SocketException: Failed host lookup'));
      expect(msg, 'Unable to connect to the authentication server. Please check your internet connection.');
    });
  });
}
