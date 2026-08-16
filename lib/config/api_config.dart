import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Explicit validation states for the Grok API Key.
enum ApiKeyStatus {
  configured,
  missing,
  invalid,
}

/// Runtime and compile-time configuration for the xAI Grok integration.
class ApiConfig {
  ApiConfig._();

  static const String defaultXAIUrl = 'https://api.x.ai/v1';
  static const String defaultXAIModel = 'grok-beta';

  static String _overrideApiKey = '';
  static String _overrideModel = '';
  static String _overrideBaseUrl = '';
  static bool _hasExplicitOverride = false;

  /// Sanitizes key by stripping whitespace, trailing newlines, and enclosing quotes.
  static String sanitize(String? raw) {
    if (raw == null) return '';
    var clean = raw.trim();
    if ((clean.startsWith('"') && clean.endsWith('"')) ||
        (clean.startsWith("'") && clean.endsWith("'"))) {
      clean = clean.substring(1, clean.length - 1).trim();
    }
    return clean;
  }

  /// Returns the active API key with quotes and whitespace stripped.
  static String get apiKey {
    if (_hasExplicitOverride) {
      return sanitize(_overrideApiKey);
    }

    // 1. Try flutter_dotenv
    try {
      final envVal = dotenv.env['GROK_API_KEY'] ?? dotenv.env['XAI_API_KEY'];
      if (envVal != null && envVal.trim().isNotEmpty) {
        return sanitize(envVal);
      }
    } catch (_) {}

    // 2. Try compile-time environment define
    const dartDefineKey = String.fromEnvironment(
      'GROK_API_KEY',
      defaultValue: String.fromEnvironment('XAI_API_KEY'),
    );
    if (dartDefineKey.trim().isNotEmpty) {
      return sanitize(dartDefineKey);
    }

    return sanitize(_overrideApiKey);
  }

  static String? get grokApiKey => hasApiKey ? apiKey : null;
  static bool get hasApiKey => apiKey.isNotEmpty;
  static bool get hasGrokKey => hasApiKey;
  static bool get startsWithXai => apiKey.startsWith('xai-');
  static int get apiKeyLength => apiKey.length;

  static ApiKeyStatus get keyStatus {
    if (!hasApiKey) return ApiKeyStatus.missing;
    if (apiKey.length < 10) return ApiKeyStatus.invalid;
    return ApiKeyStatus.configured;
  }

  static String get providerName => 'xAI Grok';

  static String get baseUrl {
    if (_hasExplicitOverride && _overrideBaseUrl.isNotEmpty) {
      return _overrideBaseUrl;
    }
    try {
      final envUrl = dotenv.env['GROK_BASE_URL'] ?? dotenv.env['XAI_BASE_URL'];
      if (envUrl != null && envUrl.trim().isNotEmpty) {
        return envUrl.trim();
      }
    } catch (_) {}

    const dartDefineUrl = String.fromEnvironment(
      'GROK_BASE_URL',
      defaultValue: String.fromEnvironment('XAI_BASE_URL'),
    );
    if (dartDefineUrl.trim().isNotEmpty) {
      return dartDefineUrl.trim();
    }

    return defaultXAIUrl;
  }

  static String get model {
    if (_hasExplicitOverride && _overrideModel.isNotEmpty) {
      return _overrideModel;
    }
    try {
      final envModel = dotenv.env['GROK_MODEL'] ?? dotenv.env['XAI_MODEL'];
      if (envModel != null && envModel.trim().isNotEmpty) {
        return envModel.trim();
      }
    } catch (_) {}

    const dartDefineModel = String.fromEnvironment(
      'GROK_MODEL',
      defaultValue: String.fromEnvironment('XAI_MODEL'),
    );
    if (dartDefineModel.trim().isNotEmpty) {
      return dartDefineModel.trim();
    }

    return defaultXAIModel;
  }

  static Future<void> init() async {
    _hasExplicitOverride = false;

    try {
      final _ = dotenv.env;
    } catch (_) {
      try {
        await dotenv.load(fileName: '.env');
      } catch (_) {}
    }

    if (kDebugMode) {
      if (hasApiKey) {
        debugPrint('Grok key loaded successfully (length: $apiKeyLength, starts with "xai-": $startsWithXai)');
      } else {
        debugPrint('Grok key missing in .env / launch configuration');
      }
    }
  }

  static void setConfig({String? apiKey, String? model, String? baseUrl}) {
    _hasExplicitOverride = apiKey != null || model != null || baseUrl != null;
    if (apiKey != null) _overrideApiKey = apiKey.trim();
    if (model != null) _overrideModel = model.trim();
    if (baseUrl != null) _overrideBaseUrl = baseUrl.trim();

    if (kDebugMode) {
      if (hasApiKey) {
        debugPrint('Grok key loaded successfully (length: $apiKeyLength, starts with "xai-": $startsWithXai)');
      } else {
        debugPrint('Grok key missing in .env / launch configuration');
      }
    }
  }
}
