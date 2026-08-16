import 'dart:io';

/// Secure runtime configuration for AI providers (xAI Grok).
///
/// Secrets are NEVER hardcoded into Dart source code or tracked by Git.
/// Configuration is resolved dynamically from:
/// 1. Dart compile-time environment defines (`--dart-define=XAI_API_KEY=...`)
/// 2. Local `.env` file (strictly excluded in `.gitignore`)
/// 3. System environment variables
class AIConfig {
  AIConfig._();

  static String _apiKey = '';
  static String _model = 'grok-4.5';
  static String _baseUrl = 'https://api.x.ai/v1';

  static String get apiKey => _apiKey;
  static String get model => _model;
  static String get baseUrl => _baseUrl;
  static bool get hasApiKey => _apiKey.isNotEmpty;

  /// Initialize AI environment settings.
  static Future<void> init() async {
    // 1. Try compile-time environment define
    const envKey = String.fromEnvironment('XAI_API_KEY');
    const envModel = String.fromEnvironment('XAI_MODEL', defaultValue: 'grok-4.5');
    const envUrl = String.fromEnvironment('XAI_BASE_URL', defaultValue: 'https://api.x.ai/v1');

    if (envKey.isNotEmpty) {
      _apiKey = envKey.trim();
    }
    if (envModel.isNotEmpty) {
      _model = envModel.trim();
    }
    if (envUrl.isNotEmpty) {
      _baseUrl = envUrl.trim();
    }

    // 2. If no compile-time key, attempt to read local .env file (for local development)
    if (_apiKey.isEmpty) {
      try {
        final envFile = File('.env');
        if (await envFile.exists()) {
          final lines = await envFile.readAsLines();
          for (final line in lines) {
            final trimmed = line.trim();
            if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
            final eqIdx = trimmed.indexOf('=');
            if (eqIdx > 0) {
              final key = trimmed.substring(0, eqIdx).trim();
              final val = trimmed.substring(eqIdx + 1).trim();
              if (key == 'XAI_API_KEY' && val.isNotEmpty) {
                _apiKey = val;
              } else if (key == 'XAI_MODEL' && val.isNotEmpty) {
                _model = val;
              } else if (key == 'XAI_BASE_URL' && val.isNotEmpty) {
                _baseUrl = val;
              }
            }
          }
        }
      } catch (_) {
        // Silently continue if .env is not accessible in sandboxed/release environments
      }
    }

    // 3. Fallback to System environment variables if running locally
    if (_apiKey.isEmpty) {
      try {
        final sysKey = Platform.environment['XAI_API_KEY'];
        if (sysKey != null && sysKey.isNotEmpty) {
          _apiKey = sysKey.trim();
        }
        final sysModel = Platform.environment['XAI_MODEL'];
        if (sysModel != null && sysModel.isNotEmpty) {
          _model = sysModel.trim();
        }
      } catch (_) {
        // Ignored on platforms without process environment
      }
    }
  }

  /// Manually override configuration at runtime (e.g. for testing)
  static void setConfig({String? apiKey, String? model, String? baseUrl}) {
    if (apiKey != null) _apiKey = apiKey.trim();
    if (model != null) _model = model.trim();
    if (baseUrl != null) _baseUrl = baseUrl.trim();
  }
}
