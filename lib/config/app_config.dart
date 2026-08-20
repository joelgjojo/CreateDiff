import 'package:flutter/foundation.dart';

/// Centralized production-ready runtime & build configuration for CreateDiff.
///
/// Networking Architecture:
/// - Defaults to the production Render HTTPS endpoint.
/// - Accepts custom backend via `--dart-define=API_BASE_URL=https://...` or `--dart-define-from-file`.
/// - Supports runtime configuration overrides for debug panel & automated testing.
/// - Never hardcodes local emulator/simulator IPs (e.g. 10.0.2.2 / 127.0.0.1) as defaults.
class AppConfig {
  AppConfig._();

  /// Default production HTTPS backend URL.
  static const String defaultProductionUrl = 'https://creatediff-api.onrender.com';
  static const String defaultModelName = 'openai/gpt-oss-120b';
  static const String providerName = 'CreateDiff Cloud AI';

  static String? _overrideApiBaseUrl;
  static String? _overrideModel;
  static String? _overrideApiKey;

  /// Sanitizes URL / key by stripping whitespace, quotes, and trailing slashes.
  static String sanitizeUrl(String? raw) {
    if (raw == null) return '';
    var clean = raw.trim();
    if ((clean.startsWith('"') && clean.endsWith('"')) ||
        (clean.startsWith("'") && clean.endsWith("'"))) {
      clean = clean.substring(1, clean.length - 1).trim();
    }
    clean = clean.replaceAll(RegExp(r'/+$'), '');
    return clean;
  }

  /// Canonical active API Base URL.
  /// Priority:
  /// 1. In-memory runtime override (debug panel / tests)
  /// 2. Build-time `API_BASE_URL` environment variable (`--dart-define=API_BASE_URL=...`)
  /// 3. Legacy build-time variables (for backward compatibility)
  /// 4. Default production Render HTTPS endpoint
  static String get apiBaseUrl {
    // 1. Runtime override
    if (_overrideApiBaseUrl != null && _overrideApiBaseUrl!.trim().isNotEmpty) {
      return sanitizeUrl(_overrideApiBaseUrl);
    }

    // 2. Standard build environment variable
    const dartDefineUrl = String.fromEnvironment('API_BASE_URL');
    if (dartDefineUrl.trim().isNotEmpty) {
      return sanitizeUrl(dartDefineUrl);
    }

    // 3. Backward-compatible environment variables
    const legacyProdUrl = String.fromEnvironment('CREATE_DIFF_PRODUCTION_API_BASE_URL');
    if (legacyProdUrl.trim().isNotEmpty) {
      return sanitizeUrl(legacyProdUrl);
    }

    const legacyDevUrl = String.fromEnvironment('CREATE_DIFF_DEV_API_BASE_URL');
    if (legacyDevUrl.trim().isNotEmpty) {
      return sanitizeUrl(legacyDevUrl);
    }

    const legacyGenericUrl = String.fromEnvironment('CREATE_DIFF_API_BASE_URL');
    if (legacyGenericUrl.trim().isNotEmpty) {
      return sanitizeUrl(legacyGenericUrl);
    }

    // 4. Default to production HTTPS backend placeholder
    return defaultProductionUrl;
  }

  /// Validates the configured backend URL before any socket connection is attempted.
  static bool get hasValidApiBaseUrl {
    final uri = Uri.tryParse(apiBaseUrl);
    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty;
  }

  /// Active AI model identifier
  static String get model {
    if (_overrideModel != null && _overrideModel!.isNotEmpty) {
      return _overrideModel!;
    }
    return defaultModelName;
  }

  /// Indicates if a valid backend endpoint is configured.
  static bool get isConfigured => apiBaseUrl.isNotEmpty;

  /// Backward-compatible API key accessor (backend manages Groq secret).
  static String get apiKey => _overrideApiKey ?? 'backend_managed_secret';
  static bool get hasApiKey {
    if (_overrideApiKey != null) return _overrideApiKey!.isNotEmpty;
    return isConfigured;
  }

  /// Set runtime overrides for debug testing or dynamic endpoint switching.
  static void setConfig({String? apiBaseUrl, String? model, String? apiKey}) {
    if (apiBaseUrl != null) _overrideApiBaseUrl = sanitizeUrl(apiBaseUrl);
    if (model != null) _overrideModel = model.trim();
    if (apiKey != null) _overrideApiKey = apiKey.trim();

    if (kDebugMode) {
      debugPrint('[AppConfig] API Base URL set to: ${AppConfig.apiBaseUrl}');
    }
  }

  /// Reset all runtime overrides back to environment/default settings.
  static void resetOverrides() {
    _overrideApiBaseUrl = null;
    _overrideModel = null;
    _overrideApiKey = null;
  }

  /// Initialize and log current API target.
  static Future<void> init() async {
    resetOverrides();
    if (kDebugMode) {
      debugPrint('[AppConfig] CreateDiff API target: $apiBaseUrl');
    }
  }
}
