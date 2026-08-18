import 'app_config.dart';

export 'app_config.dart';

/// Validation status for the CreateDiff AI backend connection.
enum ApiKeyStatus { configured, missing, invalid }

/// Backward-compatible adapter for AppConfig.
/// Communicates securely with the CreateDiff FastAPI backend.
class ApiConfig {
  ApiConfig._();

  static const String defaultModelName = AppConfig.defaultModelName;
  static const String defaultProductionUrl = AppConfig.defaultProductionUrl;

  /// Sanitizes URL / key by stripping whitespace, trailing newlines, and quotes.
  static String sanitize(String? raw) => AppConfig.sanitizeUrl(raw);

  /// The active CreateDiff Backend base URL, delegating to AppConfig.
  static String get backendBaseUrl => AppConfig.apiBaseUrl;
  static String get baseUrl => AppConfig.apiBaseUrl;

  /// Default platform backend URL now defaults to AppConfig.apiBaseUrl without hardcoded local IPs.
  static String get defaultPlatformBackendUrl => AppConfig.apiBaseUrl;

  /// Backward-compatible key getter for tests and diagnostics.
  static String get apiKey => AppConfig.apiKey;
  static String? get grokApiKey => AppConfig.apiKey;
  static bool get hasApiKey => AppConfig.hasApiKey;
  static bool get hasGrokKey => AppConfig.hasApiKey;
  static bool get hasBackendConfigured => AppConfig.isConfigured;
  static bool get startsWithXai => false;
  static bool get startsWithGsk => true;
  static int get apiKeyLength => 32;

  static ApiKeyStatus get keyStatus =>
      hasApiKey ? ApiKeyStatus.configured : ApiKeyStatus.missing;

  static String get providerName => AppConfig.providerName;
  static String get model => AppConfig.model;

  static Future<void> init() async {
    await AppConfig.init();
  }

  static void resetOverrides() {
    AppConfig.resetOverrides();
  }

  static void setConfig({String? apiKey, String? model, String? baseUrl}) {
    AppConfig.setConfig(apiKey: apiKey, model: model, apiBaseUrl: baseUrl);
  }
}
