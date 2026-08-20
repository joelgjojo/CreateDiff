import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized configuration and initialization for Supabase Auth and Database.
///
/// Security Boundary:
/// - Only accepts public `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
/// - Never accepts or exposes `SUPABASE_SERVICE_ROLE_KEY` or `SUPABASE_JWT_SECRET`.
/// - Supports offline / unconfigured mode: if Supabase credentials are not
///   provided, the app gracefully falls back to local guest creator mode.
class SupabaseConfig {
  SupabaseConfig._();

  static String? _overrideUrl;
  static String? _overrideAnonKey;
  static bool _isInitialized = false;

  /// Sanitizes string inputs by stripping whitespace and wrapping quotes.
  static String sanitize(String? raw) {
    if (raw == null) return '';
    var clean = raw.trim();
    if ((clean.startsWith('"') && clean.endsWith('"')) ||
        (clean.startsWith("'") && clean.endsWith("'"))) {
      clean = clean.substring(1, clean.length - 1).trim();
    }
    return clean;
  }

  /// Supabase project URL.
  static String get url {
    if (_overrideUrl != null && _overrideUrl!.isNotEmpty) {
      return sanitize(_overrideUrl);
    }
    const envUrl = String.fromEnvironment('SUPABASE_URL');
    if (envUrl.isNotEmpty) return sanitize(envUrl);

    const legacyUrl = String.fromEnvironment('CREATE_DIFF_SUPABASE_URL');
    if (legacyUrl.isNotEmpty) return sanitize(legacyUrl);

    return '';
  }

  /// Supabase Anonymous Public Key.
  static String get anonKey {
    if (_overrideAnonKey != null && _overrideAnonKey!.isNotEmpty) {
      return sanitize(_overrideAnonKey);
    }
    const envKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (envKey.isNotEmpty) return sanitize(envKey);

    const legacyKey = String.fromEnvironment('CREATE_DIFF_SUPABASE_ANON_KEY');
    if (legacyKey.isNotEmpty) return sanitize(legacyKey);

    return '';
  }

  /// Returns true if valid Supabase connection parameters are present.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  /// Returns true if Supabase SDK has been successfully initialized.
  static bool get isInitialized => _isInitialized;

  /// Sets runtime overrides for testing or debug panel switching.
  static void setOverrides({String? url, String? anonKey}) {
    if (url != null) _overrideUrl = sanitize(url);
    if (anonKey != null) _overrideAnonKey = sanitize(anonKey);
  }

  /// Clears runtime overrides.
  static void resetOverrides() {
    _overrideUrl = null;
    _overrideAnonKey = null;
  }

  /// Initializes the Supabase client safely.
  ///
  /// If Supabase is unconfigured or unavailable, returns false and allows the
  /// application to operate in offline-first guest mode without crashing.
  static Future<bool> init() async {
    if (!isConfigured) {
      if (kDebugMode) {
        debugPrint('[SupabaseConfig] Supabase is unconfigured — operating in local guest mode.');
      }
      _isInitialized = false;
      return false;
    }

    try {
      await Supabase.initialize(
        url: url,
        // ignore: deprecated_member_use
        anonKey: anonKey,
        debug: kDebugMode,
      );
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('[SupabaseConfig] Supabase client initialized successfully.');
      }
      return true;
    } catch (e) {
      _isInitialized = false;
      if (kDebugMode) {
        debugPrint('[SupabaseConfig] Warning: Supabase initialization failed ($e). Falling back to guest mode.');
      }
      return false;
    }
  }
}
