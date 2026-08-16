import 'package:flutter/foundation.dart';

/// Explicit validation states for the Grok API Key.
enum ApiKeyStatus {
  configured,
  missing,
  invalid,
}

/// Secure compile-time and runtime configuration for CreateDiff AI Engine (xAI Grok).
class ApiConfig {
  ApiConfig._();

  static const String defaultXAIUrl = 'https://api.x.ai/v1';
  static const String defaultGroqUrl = 'https://api.groq.com/openai/v1';

  static const String defaultXAIModel = 'grok-beta';
  static const String defaultGroqModel = 'llama-3.3-70b-versatile';

  static String _apiKey = const String.fromEnvironment(
    'GROK_API_KEY',
    defaultValue: String.fromEnvironment('XAI_API_KEY'),
  );

  static String _model = const String.fromEnvironment(
    'GROK_MODEL',
    defaultValue: String.fromEnvironment('XAI_MODEL'),
  );

  static String _baseUrl = const String.fromEnvironment(
    'GROK_BASE_URL',
    defaultValue: String.fromEnvironment('XAI_BASE_URL'),
  );

  static String get apiKey => _apiKey.trim();
  static bool get hasApiKey => apiKey.isNotEmpty;

  /// Returns the validation state of the API key.
  static ApiKeyStatus get keyStatus {
    if (!hasApiKey) return ApiKeyStatus.missing;
    if (apiKey.length < 10) return ApiKeyStatus.invalid;
    return ApiKeyStatus.configured;
  }

  /// Returns true if the key is a Groq key (starts with 'gsk_').
  static bool get isGroqKey => apiKey.startsWith('gsk_');

  /// Active AI Provider name.
  static String get providerName => isGroqKey ? 'Groq' : 'xAI Grok';

  /// Active Base URL.
  static String get baseUrl {
    if (_baseUrl.trim().isNotEmpty) return _baseUrl.trim();
    if (isGroqKey) return defaultGroqUrl;
    return defaultXAIUrl;
  }

  /// Active Model identifier.
  static String get model {
    if (_model.trim().isNotEmpty) return _model.trim();
    if (isGroqKey) return defaultGroqModel;
    return defaultXAIModel;
  }

  /// Initializes the AI configuration and outputs debug log.
  static Future<void> init() async {
    _apiKey = const String.fromEnvironment(
      'GROK_API_KEY',
      defaultValue: String.fromEnvironment('XAI_API_KEY'),
    ).trim();

    final modelEnv = const String.fromEnvironment(
      'GROK_MODEL',
      defaultValue: String.fromEnvironment('XAI_MODEL'),
    ).trim();
    if (modelEnv.isNotEmpty) _model = modelEnv;

    final urlEnv = const String.fromEnvironment(
      'GROK_BASE_URL',
      defaultValue: String.fromEnvironment('XAI_BASE_URL'),
    ).trim();
    if (urlEnv.isNotEmpty) _baseUrl = urlEnv;

    if (kDebugMode) {
      if (hasApiKey) {
        debugPrint('Grok key loaded');
      } else {
        debugPrint('Grok key missing');
      }
    }
  }

  /// Override configuration at runtime (e.g. for Developer Debug Panel or automated tests).
  static void setConfig({String? apiKey, String? model, String? baseUrl}) {
    if (apiKey != null) _apiKey = apiKey.trim();
    if (model != null) _model = model.trim();
    if (baseUrl != null) _baseUrl = baseUrl.trim();

    if (kDebugMode) {
      if (hasApiKey) {
        debugPrint('Grok key loaded');
      } else {
        debugPrint('Grok key missing');
      }
    }
  }
}
