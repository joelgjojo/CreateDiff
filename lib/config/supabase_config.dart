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
  /// Canonical: SUPABASE_URL (with fallback alias SUPABASE_PROJECT_URL)
  static String get url {
    if (_overrideUrl != null && _overrideUrl!.isNotEmpty) {
      return sanitize(_overrideUrl);
    }
    const envUrl = String.fromEnvironment('SUPABASE_URL');
    if (envUrl.isNotEmpty) return sanitize(envUrl);

    const projectUrl = String.fromEnvironment('SUPABASE_PROJECT_URL');
    if (projectUrl.isNotEmpty) return sanitize(projectUrl);

    const legacyUrl = String.fromEnvironment('CREATE_DIFF_SUPABASE_URL');
    if (legacyUrl.isNotEmpty) return sanitize(legacyUrl);

    return '';
  }

  /// Supabase Anonymous Public Key.
  /// Canonical: SUPABASE_ANON_KEY (with fallback aliases SUPABASE_PUBLISHABLE_KEY, SUPABASE_PUBLIC_ANON_KEY)
  static String get anonKey {
    if (_overrideAnonKey != null && _overrideAnonKey!.isNotEmpty) {
      return sanitize(_overrideAnonKey);
    }
    const envKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (envKey.isNotEmpty) return sanitize(envKey);

    const pubKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    if (pubKey.isNotEmpty) return sanitize(pubKey);

    const pubAnonKey = String.fromEnvironment('SUPABASE_PUBLIC_ANON_KEY');
    if (pubAnonKey.isNotEmpty) return sanitize(pubAnonKey);

    const legacyKey = String.fromEnvironment('CREATE_DIFF_SUPABASE_ANON_KEY');
    if (legacyKey.isNotEmpty) return sanitize(legacyKey);

    return '';
  }

  /// Checks if a configuration string contains placeholder markers.
  static bool isPlaceholder(String val) {
    if (val.isEmpty) return true;
    final lower = val.toLowerCase().trim();
    return lower.contains('<') ||
        lower.contains('>') ||
        lower.contains('%3c') ||
        lower.contains('%3e') ||
        lower.contains('project-ref') ||
        lower.contains('project_ref') ||
        lower.contains('your_') ||
        lower.contains('your-') ||
        lower.contains('your_supabase') ||
        lower.contains('insert_') ||
        lower.contains('insert-') ||
        lower.contains('change_me') ||
        lower.contains('change-me') ||
        lower.contains('placeholder') ||
        lower.contains('anon_key') ||
        lower.contains('anon-key');
  }

  /// Validates that the Supabase URL is properly formatted and non-placeholder.
  static bool isUrlValid(String rawUrl) {
    if (rawUrl.isEmpty || isPlaceholder(rawUrl)) return false;
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;
    if (uri.scheme != 'https' && uri.scheme != 'http') return false;
    if (uri.host.contains('%') || uri.host.contains('<') || uri.host.contains('>')) return false;
    return true;
  }

  /// Validates that the Supabase Anon / Publishable Key is non-placeholder.
  static bool isKeyValid(String rawKey) {
    if (rawKey.isEmpty || isPlaceholder(rawKey)) return false;
    if (rawKey.length < 16) return false;
    return true;
  }

  /// Returns true if valid, non-placeholder Supabase connection parameters are present.
  static bool get isConfigured => isUrlValid(url) && isKeyValid(anonKey);

  /// Safe diagnostic status object showing only non-secret boolean status and host.
  static Map<String, dynamic> get diagnosticStatus => {
    'supabaseConfigured': isConfigured,
    'host': isUrlValid(url) ? (Uri.tryParse(url)?.host ?? 'none') : 'none',
  };

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
        if (isPlaceholder(url) || isPlaceholder(anonKey)) {
          debugPrint('[SupabaseConfig] Placeholder credentials detected in SUPABASE_URL / SUPABASE_ANON_KEY — operating in local guest mode.');
        } else {
          debugPrint('[SupabaseConfig] Supabase is unconfigured — operating in local guest mode.');
        }
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
