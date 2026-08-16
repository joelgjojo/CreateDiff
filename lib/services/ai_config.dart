import 'package:flutter/foundation.dart';

/// Secure compile-time and runtime configuration for AI providers (xAI Grok / Groq).
///
/// API keys are supplied via `--dart-define=GROK_API_KEY=...`.
/// This prevents hardcoding secrets in source code or relying on unbundled `.env` files.
class AIConfig {
  AIConfig._();

  static const String _defaultXAIUrl = 'https://api.x.ai/v1';
  static const String _defaultGroqUrl = 'https://api.groq.com/openai/v1';

  static const String _defaultXAIModel = 'grok-beta';
  static const String _defaultGroqModel = 'llama-3.3-70b-versatile';

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

  /// Returns true if the configured key is a Groq key (starts with 'gsk_').
  static bool get isGroqKey => apiKey.startsWith('gsk_');

  /// The active AI Provider name.
  static String get providerName {
    if (isGroqKey) return 'Groq';
    return 'xAI Grok';
  }

  /// Active Base URL.
  static String get baseUrl {
    if (_baseUrl.trim().isNotEmpty) return _baseUrl.trim();
    if (isGroqKey) return _defaultGroqUrl;
    return _defaultXAIUrl;
  }

  /// Active Model identifier.
  static String get model {
    if (_model.trim().isNotEmpty) return _model.trim();
    if (isGroqKey) return _defaultGroqModel;
    return _defaultXAIModel;
  }

  /// Initializes AI configuration and outputs debug status without exposing secrets.
  static Future<void> init() async {
    _apiKey = const String.fromEnvironment(
      'GROK_API_KEY',
      defaultValue: String.fromEnvironment('XAI_API_KEY'),
    ).trim();

    final modelEnv = const String.fromEnvironment(
      'GROK_MODEL',
      defaultValue: String.fromEnvironment('XAI_MODEL'),
    ).trim();
    if (modelEnv.isNotEmpty) {
      _model = modelEnv;
    }

    final urlEnv = const String.fromEnvironment(
      'GROK_BASE_URL',
      defaultValue: String.fromEnvironment('XAI_BASE_URL'),
    ).trim();
    if (urlEnv.isNotEmpty) {
      _baseUrl = urlEnv;
    }

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
