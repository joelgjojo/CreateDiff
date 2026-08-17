import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Validation status for the CreateDiff AI backend connection.
enum ApiKeyStatus { configured, missing, invalid }

/// Runtime configuration for CreateDiff AI Engine Backend.
/// Communicates securely with the CreateDiff FastAPI backend proxy.
class ApiConfig {
  ApiConfig._();

  static const String defaultLocalUrl = 'http://127.0.0.1:8000';
  static const String defaultAndroidEmulatorUrl = 'http://10.0.2.2:8000';
  static const String defaultModelName = 'openai/gpt-oss-120b';

  static String? _overrideBackendUrl;
  static String? _overrideApiKey;
  static String? _overrideModel;
  static String? _overrideBaseUrl;

  /// Determines default localhost address depending on host platform.
  static String get defaultPlatformBackendUrl {
    if (!kIsWeb) {
      try {
        if (Platform.isAndroid) {
          return defaultAndroidEmulatorUrl;
        }
      } catch (_) {}
    }
    return defaultLocalUrl;
  }

  /// Sanitizes URL / key by stripping whitespace, trailing newlines, and quotes.
  static String sanitize(String? raw) {
    if (raw == null) return '';
    var clean = raw.trim();
    if ((clean.startsWith('"') && clean.endsWith('"')) ||
        (clean.startsWith("'") && clean.endsWith("'"))) {
      clean = clean.substring(1, clean.length - 1).trim();
    }
    return clean;
  }

  /// The active CreateDiff Backend base URL.
  static String get backendBaseUrl {
    if (_overrideBackendUrl != null && _overrideBackendUrl!.isNotEmpty) {
      return sanitize(_overrideBackendUrl);
    }
    if (_overrideBaseUrl != null && _overrideBaseUrl!.isNotEmpty) {
      return sanitize(_overrideBaseUrl);
    }

    // Development and production URLs are intentionally separate. A physical
    // Android device needs the host Mac's LAN address, while an Android
    // emulator reaches the host through 10.0.2.2.
    final configuredUrl = _configuredUrl(
      dotenvKey: kReleaseMode
          ? 'CREATE_DIFF_PRODUCTION_API_BASE_URL'
          : 'CREATE_DIFF_DEV_API_BASE_URL',
      dartDefineKey: kReleaseMode
          ? 'CREATE_DIFF_PRODUCTION_API_BASE_URL'
          : 'CREATE_DIFF_DEV_API_BASE_URL',
    );
    if (configuredUrl.isNotEmpty) return configuredUrl;

    // 1. Backward-compatible development-only alias. It is never used by a
    // production build, so production configuration remains explicit.
    if (!kReleaseMode) {
      final legacyDevelopmentUrl = _configuredUrl(
        dotenvKey: 'CREATE_DIFF_API_BASE_URL',
        dartDefineKey: 'CREATE_DIFF_API_BASE_URL',
      );
      if (legacyDevelopmentUrl.isNotEmpty) return legacyDevelopmentUrl;
    }

    // A release build must be given an explicit production endpoint rather
    // than accidentally talking to a local development server.
    return kReleaseMode ? '' : defaultPlatformBackendUrl;
  }

  static String _configuredUrl({
    required String dotenvKey,
    required String dartDefineKey,
  }) {
    // Try flutter_dotenv first.
    try {
      final envUrl = dotenv.env[dotenvKey];
      if (envUrl != null && envUrl.trim().isNotEmpty) {
        return sanitize(envUrl);
      }
    } catch (_) {}

    // Try the matching compile-time environment define.
    final dartDefineUrl = _dartDefine(dartDefineKey);
    if (dartDefineUrl.trim().isNotEmpty) {
      return sanitize(dartDefineUrl);
    }

    return '';
  }

  static String _dartDefine(String key) {
    if (key == 'CREATE_DIFF_DEV_API_BASE_URL') {
      return const String.fromEnvironment('CREATE_DIFF_DEV_API_BASE_URL');
    }
    if (key == 'CREATE_DIFF_PRODUCTION_API_BASE_URL') {
      return const String.fromEnvironment(
        'CREATE_DIFF_PRODUCTION_API_BASE_URL',
      );
    }
    return const String.fromEnvironment('CREATE_DIFF_API_BASE_URL');
  }

  static String get baseUrl => backendBaseUrl;

  /// Backward-compatible key getter for tests and diagnostics.
  static String get apiKey {
    if (_overrideApiKey != null) return sanitize(_overrideApiKey);
    return 'backend_managed_secret';
  }

  static String? get grokApiKey => apiKey;
  static bool get hasApiKey {
    if (_overrideApiKey != null) return _overrideApiKey!.isNotEmpty;
    if (_overrideBackendUrl != null) return _overrideBackendUrl!.isNotEmpty;
    return hasBackendConfigured;
  }

  static bool get hasGrokKey => hasApiKey;
  static bool get hasBackendConfigured => backendBaseUrl.isNotEmpty;
  static bool get startsWithXai => false;
  static bool get startsWithGsk => true;
  static int get apiKeyLength => 32;

  static ApiKeyStatus get keyStatus =>
      hasApiKey ? ApiKeyStatus.configured : ApiKeyStatus.missing;

  static String get providerName => 'CreateDiff Cloud AI';

  static String get model {
    if (_overrideModel != null && _overrideModel!.isNotEmpty) {
      return _overrideModel!;
    }
    return defaultModelName;
  }

  static Future<void> init() async {
    _overrideBackendUrl = null;
    _overrideApiKey = null;
    _overrideModel = null;
    _overrideBaseUrl = null;

    try {
      final _ = dotenv.env;
    } catch (_) {
      try {
        await dotenv.load(fileName: '.env');
      } catch (_) {}
    }

    if (kDebugMode) {
      debugPrint('CreateDiff Backend configured -> $backendBaseUrl');
    }
  }

  static void resetOverrides() {
    _overrideBackendUrl = null;
    _overrideApiKey = null;
    _overrideModel = null;
    _overrideBaseUrl = null;
  }

  static void setConfig({String? apiKey, String? model, String? baseUrl}) {
    if (apiKey != null) _overrideApiKey = apiKey.trim();
    if (model != null) _overrideModel = model.trim();
    if (baseUrl != null) {
      _overrideBaseUrl = baseUrl.trim();
      _overrideBackendUrl = baseUrl.trim();
    }

    if (kDebugMode) {
      debugPrint('CreateDiff API config updated -> $backendBaseUrl');
    }
  }
}
