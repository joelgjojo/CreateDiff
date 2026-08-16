import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Explicit validation states for the Grok API Key.
enum ApiKeyStatus {
  configured,
  missing,
  invalid,
}

/// Runtime and compile-time configuration for CreateDiff AI Engine (xAI Grok & Groq).
class ApiConfig {
  ApiConfig._();

  static const String defaultXAIUrl = 'https://api.x.ai/v1';
  static const String defaultGroqUrl = 'https://api.groq.com/openai/v1';

  static const String defaultXAIModel = 'grok-beta';
  static const String defaultGroqModel = 'llama-3.3-70b-versatile';

  static String? _overrideApiKey;
  static String? _overrideModel;
  static String? _overrideBaseUrl;

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
    if (_overrideApiKey != null) {
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

    return '';
  }

  static String? get grokApiKey => hasApiKey ? apiKey : null;
  static bool get hasApiKey => apiKey.isNotEmpty;
  static bool get hasGrokKey => hasApiKey;
  static bool get startsWithXai => apiKey.startsWith('xai-');
  static bool get startsWithGsk => apiKey.startsWith('gsk_');
  static int get apiKeyLength => apiKey.length;

  static ApiKeyStatus get keyStatus {
    if (!hasApiKey) return ApiKeyStatus.missing;
    if (apiKey.length < 10) return ApiKeyStatus.invalid;
    return ApiKeyStatus.configured;
  }

  static String get providerName {
    if (startsWithGsk) return 'Groq';
    return 'xAI Grok';
  }

  static String get baseUrl {
    if (_overrideBaseUrl != null && _overrideBaseUrl!.isNotEmpty) {
      return _overrideBaseUrl!;
    }
    try {
      final envUrl = dotenv.env['GROK_BASE_URL'] ?? dotenv.env['XAI_BASE_URL'];
      if (envUrl != null && envUrl.trim().isNotEmpty) {
        final trimmed = envUrl.trim();
        // If it's a Groq key (gsk_) and URL is xAI default, route to Groq endpoint
        if (startsWithGsk && (trimmed == defaultXAIUrl || trimmed.contains('api.x.ai'))) {
          return defaultGroqUrl;
        }
        return trimmed;
      }
    } catch (_) {}

    const dartDefineUrl = String.fromEnvironment(
      'GROK_BASE_URL',
      defaultValue: String.fromEnvironment('XAI_BASE_URL'),
    );
    if (dartDefineUrl.trim().isNotEmpty) {
      final trimmed = dartDefineUrl.trim();
      if (startsWithGsk && (trimmed == defaultXAIUrl || trimmed.contains('api.x.ai'))) {
        return defaultGroqUrl;
      }
      return trimmed;
    }

    if (startsWithGsk) {
      return defaultGroqUrl;
    }
    return defaultXAIUrl;
  }

  static String get model {
    if (_overrideModel != null && _overrideModel!.isNotEmpty) {
      return _overrideModel!;
    }
    try {
      final envModel = dotenv.env['GROK_MODEL'] ?? dotenv.env['XAI_MODEL'];
      if (envModel != null && envModel.trim().isNotEmpty) {
        final trimmed = envModel.trim();
        // If Groq key and model is grok-*, route to llama-3.3-70b-versatile
        if (startsWithGsk && trimmed.startsWith('grok')) {
          return defaultGroqModel;
        }
        return trimmed;
      }
    } catch (_) {}

    const dartDefineModel = String.fromEnvironment(
      'GROK_MODEL',
      defaultValue: String.fromEnvironment('XAI_MODEL'),
    );
    if (dartDefineModel.trim().isNotEmpty) {
      final trimmed = dartDefineModel.trim();
      if (startsWithGsk && trimmed.startsWith('grok')) {
        return defaultGroqModel;
      }
      return trimmed;
    }

    if (startsWithGsk) {
      return defaultGroqModel;
    }
    return defaultXAIModel;
  }

  static Future<void> init() async {
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
      if (hasApiKey) {
        debugPrint('Grok key loaded successfully (length: $apiKeyLength, provider: $providerName, endpoint: $baseUrl)');
      } else {
        debugPrint('Grok key missing in .env / launch configuration');
      }
    }
  }

  static void resetOverrides() {
    _overrideApiKey = null;
    _overrideModel = null;
    _overrideBaseUrl = null;
  }

  static void setConfig({String? apiKey, String? model, String? baseUrl}) {
    if (apiKey != null) _overrideApiKey = apiKey.trim();
    if (model != null) _overrideModel = model.trim();
    if (baseUrl != null) _overrideBaseUrl = baseUrl.trim();

    if (kDebugMode) {
      if (hasApiKey) {
        debugPrint('Grok key loaded successfully (length: $apiKeyLength, provider: $providerName, endpoint: $baseUrl)');
      } else {
        debugPrint('Grok key missing in .env / launch configuration');
      }
    }
  }
}
