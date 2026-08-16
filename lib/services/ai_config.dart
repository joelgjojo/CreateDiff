import 'package:flutter/foundation.dart';

/// Secure runtime configuration for xAI Grok.
///
/// API keys are supplied at build/launch time via `--dart-define` flags.
/// This prevents hardcoding secrets in source code, APK assets, or version control.
///
/// Launch command:
/// ```bash
/// flutter run --dart-define=GROK_API_KEY=your_xai_api_key
/// ```
class AIConfig {
  AIConfig._();

  // Compile-time environment configuration
  static const String _defaultModel = 'grok-4.5';
  static const String _defaultBaseUrl = 'https://api.x.ai/v1';

  static String _apiKey = const String.fromEnvironment(
    'GROK_API_KEY',
    defaultValue: String.fromEnvironment('XAI_API_KEY'),
  );

  static String _model = const String.fromEnvironment(
    'GROK_MODEL',
    defaultValue: String.fromEnvironment(
      'XAI_MODEL',
      defaultValue: _defaultModel,
    ),
  );

  static String _baseUrl = const String.fromEnvironment(
    'GROK_BASE_URL',
    defaultValue: String.fromEnvironment(
      'XAI_BASE_URL',
      defaultValue: _defaultBaseUrl,
    ),
  );

  static String get apiKey => _apiKey.trim();
  static String get model => _model.trim().isNotEmpty ? _model.trim() : _defaultModel;
  static String get baseUrl => _baseUrl.trim().isNotEmpty ? _baseUrl.trim() : _defaultBaseUrl;
  static bool get hasApiKey => apiKey.isNotEmpty;

  /// Initializes the AI configuration and logs status in debug mode.
  static Future<void> init() async {
    // If not set via compile-time define, ensure values are clean
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
      debugPrint('[CreateDiff Grok AI] Initialized. Provider: xAI Grok, Model: $model, Key configured: $hasApiKey');
    }
  }

  /// Override configuration at runtime (e.g. for Developer Debug Panel or automated tests).
  static void setConfig({String? apiKey, String? model, String? baseUrl}) {
    if (apiKey != null) _apiKey = apiKey.trim();
    if (model != null && model.trim().isNotEmpty) _model = model.trim();
    if (baseUrl != null && baseUrl.trim().isNotEmpty) _baseUrl = baseUrl.trim();

    if (kDebugMode) {
      debugPrint('[CreateDiff Grok AI] Runtime config updated. Model: $_model, Key configured: $hasApiKey');
    }
  }
}
