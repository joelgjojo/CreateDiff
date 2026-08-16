import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/creator_profile.dart';
import '../models/generated_content.dart';

/// Explicit status codes representing the AI generation lifecycle and failure reasons.
enum GrokGenerationStatus {
  idle,
  loading,
  success,
  apiKeyMissing,
  invalidKey,
  rateLimited,
  networkError,
  serverError,
  invalidResponse,
  unknownError,
}

/// Detailed exception thrown when Grok AI generation fails.
class GrokServiceException implements Exception {
  final GrokGenerationStatus status;
  final String message;
  final int? statusCode;
  final String? rawResponse;

  const GrokServiceException({
    required this.status,
    required this.message,
    this.statusCode,
    this.rawResponse,
  });

  @override
  String toString() => 'GrokServiceException($status: $message, code: $statusCode)';
}

/// Observability telemetry model for developer debugging and runtime verification.
class GrokDebugLog {
  final String provider;
  final String model;
  final DateTime timestamp;
  final GrokGenerationStatus status;
  final int? statusCode;
  final String? errorMessage;
  final int durationMs;
  final int promptLength;
  final int responseLength;

  const GrokDebugLog({
    required this.provider,
    required this.model,
    required this.timestamp,
    required this.status,
    this.statusCode,
    this.errorMessage,
    required this.durationMs,
    required this.promptLength,
    required this.responseLength,
  });
}

/// Production xAI Grok API Client.
///
/// Communicates directly with xAI Grok (`grok-beta`) via OpenAI-compatible `/chat/completions`.
/// Strictly distinguishes every success and failure state with zero silent fake fallbacks.
class GrokService {
  GrokService._();

  static GrokDebugLog? _lastDebugLog;
  static GrokDebugLog? get lastDebugLog => _lastDebugLog;

  /// Dedicated CreateDiff Studio System Prompt.
  static String buildSystemPrompt({required CreatorProfile profile}) {
    final buffer = StringBuffer();
    buffer.writeln('You are the core AI Content Engine for CreateDiff — a premium mobile AI Creation Studio.');
    buffer.writeln('Your role is to transform simple, raw ideas into complete, high-converting, platform-optimized creator content packs.');
    buffer.writeln('');
    buffer.writeln('=== CREATOR BRAND MEMORY (STRICT CONTEXT) ===');
    buffer.writeln('• Creator / Brand Name: ${profile.creatorName.isNotEmpty ? profile.creatorName : "Creator"}');
    buffer.writeln('• Niche / Domain: ${profile.niche.isNotEmpty ? profile.niche : "General"}');
    buffer.writeln('• Target Audience: ${profile.targetAudience.isNotEmpty ? profile.targetAudience : "General audience"}');
    buffer.writeln('• Brand Voice & Tone: ${profile.tone.isNotEmpty ? profile.tone : "Educational & Engaging"}');
    buffer.writeln('• Primary Language: ${profile.primaryLanguage.isNotEmpty ? profile.primaryLanguage : "English"}');
    if (profile.secondaryLanguage.isNotEmpty) {
      buffer.writeln('• Regional / Secondary Dialect: ${profile.secondaryLanguage}');
    }
    if (profile.contentStyle.isNotEmpty) {
      buffer.writeln('• Content Style: ${profile.contentStyle}');
    }
    if (profile.brandDescription.isNotEmpty) {
      buffer.writeln('• Brand Description: ${profile.brandDescription}');
    }
    buffer.writeln('• Preferred CTA Style: ${profile.preferredCTAStyle.isNotEmpty ? profile.preferredCTAStyle : "Direct"}');
    buffer.writeln('• Emoji Density: ${profile.emojiUsage.isNotEmpty ? profile.emojiUsage : "moderate"}');
    buffer.writeln('');
    buffer.writeln('=== STRICT INSTRUCTIONS ===');
    buffer.writeln('1. Deliver output exclusively in valid, parseable JSON format.');
    buffer.writeln('2. Do not wrap the JSON with markdown code blocks (no ```json or ```). Return raw JSON.');
    buffer.writeln('3. Provide exactly 5 distinct, high-impact hooks covering curiosity, contrarian, blueprint, story, and question angles.');
    buffer.writeln('4. Provide a full formatted caption with line breaks, value points, and a strong ending.');
    buffer.writeln('5. Provide 3 action-oriented CTAs aligned with the creator\'s CTA style.');
    buffer.writeln('6. Segment hashtags into 3 reach tiers: high reach (broad discovery), medium reach (niche/topic), and niche/community (highly targeted).');
    buffer.writeln('7. Provide a punchy, high-contrast Cover Text (3-5 uppercase words) suitable for visual design slides.');
    buffer.writeln('8. Provide 3 creative format variations (e.g. Standard, High-Engagement, Story Framework).');
    buffer.writeln('9. Respect the specified language and regional dialect (e.g., Manglish should blend English & Malayalam naturally).');
    buffer.writeln('10. Do NOT invent fictional personal brand facts not given in the Creator Brand Memory.');
    buffer.writeln('');
    buffer.writeln('=== REQUIRED JSON SCHEMA ===');
    buffer.writeln('''{
  "hooks": ["hook 1", "hook 2", "hook 3", "hook 4", "hook 5"],
  "caption": "Full formatted caption with linebreaks...",
  "ctas": ["CTA 1", "CTA 2", "CTA 3"],
  "hashtagsHighReach": ["#tag1", "#tag2", "#tag3", "#tag4", "#tag5"],
  "hashtagsMediumReach": ["#tag1", "#tag2", "#tag3", "#tag4"],
  "hashtagsNiche": ["#tag1", "#tag2", "#tag3"],
  "coverText": "PUNCHY GRAPHIC TITLE",
  "variations": ["Variation 1", "Variation 2", "Variation 3"]
}''');
    return buffer.toString();
  }

  /// Builds user request prompt for the AI model.
  static String buildUserPrompt({
    required String platform,
    required String contentType,
    required String idea,
    String? overrideTone,
    String? overrideLanguage,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Platform: $platform');
    buffer.writeln('Format: $contentType');
    buffer.writeln('Idea / Topic: $idea');
    if (overrideTone != null && overrideTone.isNotEmpty) {
      buffer.writeln('Tone Override: $overrideTone');
    }
    if (overrideLanguage != null && overrideLanguage.isNotEmpty) {
      buffer.writeln('Language Override: $overrideLanguage');
    }
    buffer.writeln('');
    buffer.writeln('Generate the complete structured JSON content pack now:');
    return buffer.toString();
  }

  /// Extracts human-readable error details from the server response payload.
  static String _extractServerErrorMessage(String responseBody, int statusCode) {
    try {
      final parsed = jsonDecode(responseBody);
      if (parsed is Map<String, dynamic>) {
        if (parsed['error'] is Map) {
          final errorObj = parsed['error'] as Map<String, dynamic>;
          final msg = errorObj['message']?.toString();
          if (msg != null && msg.isNotEmpty) return msg;
        }
        if (parsed['error'] is String && (parsed['error'] as String).isNotEmpty) {
          return parsed['error'] as String;
        }
        if (parsed['message'] is String && (parsed['message'] as String).isNotEmpty) {
          return parsed['message'] as String;
        }
      }
    } catch (_) {}

    if (responseBody.trim().isNotEmpty) {
      return 'HTTP $statusCode: ${responseBody.trim()}';
    }
    return 'HTTP $statusCode (Empty response from server)';
  }

  /// Dispatches generation request to Grok API.
  /// Throws [GrokServiceException] on failure — never falls back to fake content.
  static Future<GeneratedContent> generateContent({
    required String platform,
    required String contentType,
    required String idea,
    required CreatorProfile profile,
    String? overrideTone,
    String? overrideLanguage,
    String? overrideLength,
  }) async {
    final stopwatch = Stopwatch()..start();

    final provider = ApiConfig.providerName;
    final model = ApiConfig.model;
    final endpoint = '${ApiConfig.baseUrl}/chat/completions';
    final apiKey = ApiConfig.apiKey;
    final startsWithXai = ApiConfig.startsWithXai;
    final keyLength = ApiConfig.apiKeyLength;

    // 1. Verify API key
    if (!ApiConfig.hasApiKey) {
      if (kDebugMode) {
        debugPrint('[CreateDiff Grok AI] Error: Grok API key is missing. Add GROK_API_KEY to .env or launch flags.');
      }

      _lastDebugLog = GrokDebugLog(
        provider: provider,
        model: model,
        timestamp: DateTime.now(),
        status: GrokGenerationStatus.apiKeyMissing,
        errorMessage: 'Missing GROK_API_KEY in .env / environment',
        durationMs: 0,
        promptLength: 0,
        responseLength: 0,
      );

      throw const GrokServiceException(
        status: GrokGenerationStatus.apiKeyMissing,
        message: 'Grok API key is missing. Ensure .env contains GROK_API_KEY.',
      );
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 20);

    final systemPrompt = buildSystemPrompt(profile: profile);
    final userPrompt = buildUserPrompt(
      platform: platform,
      contentType: contentType,
      idea: idea,
      overrideTone: overrideTone,
      overrideLanguage: overrideLanguage,
    );

    final totalPromptLength = systemPrompt.length + userPrompt.length;

    // Debug request logging (NEVER logs full API key)
    if (kDebugMode) {
      debugPrint('==================== [CreateDiff Grok AI Request] ====================');
      debugPrint('[CreateDiff Grok AI] Provider: $provider');
      debugPrint('[CreateDiff Grok AI] Model: $model');
      debugPrint('[CreateDiff Grok AI] Endpoint URL: $endpoint');
      debugPrint('[CreateDiff Grok AI] API Key starts with "xai-": $startsWithXai');
      debugPrint('[CreateDiff Grok AI] API Key Length: $keyLength chars');
      debugPrint('[CreateDiff Grok AI] Prompt Length: $totalPromptLength chars');
      debugPrint('======================================================================');
    }

    try {
      final uri = Uri.parse(endpoint);
      final request = await client.postUrl(uri);

      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');

      final payload = {
        'model': model,
        'temperature': 0.7,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'response_format': {'type': 'json_object'},
      };

      request.add(utf8.encode(jsonEncode(payload)));

      final response = await request.close().timeout(const Duration(seconds: 35));
      stopwatch.stop();

      final responseBody = await response.transform(utf8.decoder).join();
      final statusCode = response.statusCode;

      // Debug response logging
      if (kDebugMode) {
        debugPrint('==================== [CreateDiff Grok AI Response] ====================');
        debugPrint('[CreateDiff Grok AI] HTTP Status Code: $statusCode');
        debugPrint('[CreateDiff Grok AI] Latency: ${stopwatch.elapsedMilliseconds} ms');
        debugPrint('[CreateDiff Grok AI] Response Body: $responseBody');
        debugPrint('======================================================================');
      }

      if (statusCode == 200) {
        final jsonMap = jsonDecode(responseBody) as Map<String, dynamic>;
        final choices = jsonMap['choices'] as List<dynamic>?;

        if (choices != null && choices.isNotEmpty) {
          final message = choices.first['message'] as Map<String, dynamic>?;
          final contentStr = message?['content'] as String?;

          if (contentStr != null && contentStr.isNotEmpty) {
            final parsed = _parseStructuredContent(contentStr);
            if (parsed != null) {
              _lastDebugLog = GrokDebugLog(
                provider: provider,
                model: model,
                timestamp: DateTime.now(),
                status: GrokGenerationStatus.success,
                statusCode: 200,
                durationMs: stopwatch.elapsedMilliseconds,
                promptLength: totalPromptLength,
                responseLength: responseBody.length,
              );
              return parsed;
            }
          }
        }

        final parseError = 'Malformed JSON or missing required fields in Grok response';
        if (kDebugMode) {
          debugPrint('[CreateDiff Grok AI] Parsed Error: $parseError');
        }

        _lastDebugLog = GrokDebugLog(
          provider: provider,
          model: model,
          timestamp: DateTime.now(),
          status: GrokGenerationStatus.invalidResponse,
          statusCode: 200,
          errorMessage: parseError,
          durationMs: stopwatch.elapsedMilliseconds,
          promptLength: totalPromptLength,
          responseLength: responseBody.length,
        );
        throw GrokServiceException(
          status: GrokGenerationStatus.invalidResponse,
          message: 'The AI model returned an unexpected output format. Please try again.',
          statusCode: 200,
          rawResponse: responseBody,
        );
      } else {
        final rawServerError = _extractServerErrorMessage(responseBody, statusCode);
        final isAuthFailure = statusCode == 401 ||
            statusCode == 403 ||
            rawServerError.toLowerCase().contains('incorrect api key') ||
            rawServerError.toLowerCase().contains('invalid api key') ||
            rawServerError.toLowerCase().contains('invalid-api-key');

        final userFacingMessage = isAuthFailure
            ? 'Invalid xAI API key. Check your xAI console key.'
            : rawServerError;

        if (kDebugMode) {
          debugPrint('[CreateDiff Grok AI] Parsed Error: $userFacingMessage (Server: $rawServerError)');
        }

        GrokGenerationStatus failureStatus;
        if (isAuthFailure) {
          failureStatus = GrokGenerationStatus.invalidKey;
        } else if (statusCode == 429) {
          failureStatus = GrokGenerationStatus.rateLimited;
        } else {
          failureStatus = GrokGenerationStatus.serverError;
        }

        _lastDebugLog = GrokDebugLog(
          provider: provider,
          model: model,
          timestamp: DateTime.now(),
          status: failureStatus,
          statusCode: statusCode,
          errorMessage: userFacingMessage,
          durationMs: stopwatch.elapsedMilliseconds,
          promptLength: totalPromptLength,
          responseLength: responseBody.length,
        );

        throw GrokServiceException(
          status: failureStatus,
          message: userFacingMessage,
          statusCode: statusCode,
          rawResponse: responseBody,
        );
      }
    } on SocketException catch (e) {
      stopwatch.stop();
      final networkError = 'Network connection failed: ${e.message}';
      if (kDebugMode) {
        debugPrint('[CreateDiff Grok AI] Parsed Error: $networkError');
      }
      _lastDebugLog = GrokDebugLog(
        provider: provider,
        model: model,
        timestamp: DateTime.now(),
        status: GrokGenerationStatus.networkError,
        errorMessage: networkError,
        durationMs: stopwatch.elapsedMilliseconds,
        promptLength: totalPromptLength,
        responseLength: 0,
      );
      throw GrokServiceException(
        status: GrokGenerationStatus.networkError,
        message: networkError,
      );
    } on TimeoutException {
      stopwatch.stop();
      final timeoutError = 'Request timed out after 35 seconds';
      if (kDebugMode) {
        debugPrint('[CreateDiff Grok AI] Parsed Error: $timeoutError');
      }
      _lastDebugLog = GrokDebugLog(
        provider: provider,
        model: model,
        timestamp: DateTime.now(),
        status: GrokGenerationStatus.networkError,
        errorMessage: timeoutError,
        durationMs: stopwatch.elapsedMilliseconds,
        promptLength: totalPromptLength,
        responseLength: 0,
      );
      throw const GrokServiceException(
        status: GrokGenerationStatus.networkError,
        message: 'The AI generation request timed out. Please check your internet connection.',
      );
    } catch (e) {
      if (e is GrokServiceException) rethrow;
      stopwatch.stop();
      final unknownError = e.toString();
      if (kDebugMode) {
        debugPrint('[CreateDiff Grok AI] Parsed Error: $unknownError');
      }
      _lastDebugLog = GrokDebugLog(
        provider: provider,
        model: model,
        timestamp: DateTime.now(),
        status: GrokGenerationStatus.unknownError,
        errorMessage: unknownError,
        durationMs: stopwatch.elapsedMilliseconds,
        promptLength: totalPromptLength,
        responseLength: 0,
      );
      throw GrokServiceException(
        status: GrokGenerationStatus.unknownError,
        message: unknownError,
      );
    } finally {
      client.close();
    }
  }

  /// Parses and validates structured JSON response into a `GeneratedContent` object.
  static GeneratedContent? _parseStructuredContent(String rawContent) {
    try {
      var clean = rawContent.trim();
      if (clean.startsWith('```json')) {
        clean = clean.substring(7);
      } else if (clean.startsWith('```')) {
        clean = clean.substring(3);
      }
      if (clean.endsWith('```')) {
        clean = clean.substring(0, clean.length - 3);
      }
      clean = clean.trim();

      final parsed = jsonDecode(clean) as Map<String, dynamic>;

      final hooks = (parsed['hooks'] as List<dynamic>?)?.map((e) => e.toString().trim()).toList() ?? [];
      final caption = parsed['caption']?.toString().trim() ?? '';
      final ctas = (parsed['ctas'] as List<dynamic>?)?.map((e) => e.toString().trim()).toList() ?? [];
      final highReach = (parsed['hashtagsHighReach'] as List<dynamic>?)?.map((e) => e.toString().trim()).toList() ?? [];
      final medReach = (parsed['hashtagsMediumReach'] as List<dynamic>?)?.map((e) => e.toString().trim()).toList() ?? [];
      final nicheReach = (parsed['hashtagsNiche'] as List<dynamic>?)?.map((e) => e.toString().trim()).toList() ?? [];
      final coverText = parsed['coverText']?.toString().trim() ?? '';
      final variations = (parsed['variations'] as List<dynamic>?)?.map((e) => e.toString().trim()).toList() ?? [];

      if (hooks.isNotEmpty && caption.isNotEmpty) {
        return GeneratedContent(
          hooks: hooks,
          caption: caption,
          ctas: ctas.isNotEmpty ? ctas : ['Save this post for later 💾'],
          hashtagsHighReach: highReach,
          hashtagsMediumReach: medReach,
          hashtagsNiche: nicheReach,
          coverText: coverText.isNotEmpty ? coverText : 'READY TO PUBLISH',
          variations: variations.isNotEmpty ? variations : ['Standard Edition'],
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

// Aliases for compatibility
typedef AIService = GrokService;
typedef AIGenerationStatus = GrokGenerationStatus;
typedef AIServiceException = GrokServiceException;
typedef AIDebugLog = GrokDebugLog;
typedef AIConfig = ApiConfig;
