import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/creator_profile.dart';
import '../models/generated_content.dart';
import 'ai_config.dart';

/// Explicit status codes representing the AI generation lifecycle and failure reasons.
enum AIGenerationStatus {
  idle,
  generating,
  success,
  missingApiKey,
  invalidApiKey,
  rateLimited,
  networkError,
  serverError,
  invalidResponse,
  unknownError,
}

/// Detailed exception thrown when AI generation cannot be completed.
class AIServiceException implements Exception {
  final AIGenerationStatus status;
  final String message;
  final int? statusCode;
  final String? rawResponse;

  const AIServiceException({
    required this.status,
    required this.message,
    this.statusCode,
    this.rawResponse,
  });

  @override
  String toString() => 'AIServiceException($status: $message, code: $statusCode)';
}

/// Observability model for developer debugging and runtime verification.
class AIDebugLog {
  final String provider;
  final String model;
  final DateTime timestamp;
  final AIGenerationStatus status;
  final int? statusCode;
  final String? errorMessage;
  final int durationMs;
  final int promptLength;
  final int responseLength;

  const AIDebugLog({
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

/// The CreateDiff AI Studio Service.
///
/// Communicates directly with AI providers (xAI Grok / Groq) via standard OpenAI-compatible Chat Completions.
/// Strictly distinguishes every success and failure state with zero silent fake fallbacks.
class AIService {
  AIService._();

  static AIDebugLog? _lastDebugLog;
  static AIDebugLog? get lastDebugLog => _lastDebugLog;

  /// Dedicated CreateDiff Studio System Prompt.
  static String buildSystemPrompt({required CreatorProfile profile}) {
    final buffer = StringBuffer();
    buffer.writeln('You are the core AI Content Engine for CreateDiff — a premium mobile creator and design studio.');
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

  /// Extracts the real human-readable error message from an API response body.
  static String _extractServerErrorMessage(String responseBody, int statusCode) {
    try {
      final parsed = jsonDecode(responseBody);
      if (parsed is Map<String, dynamic>) {
        // OpenAI / xAI / Groq error envelope: {"error": {"message": "...", "type": "...", "code": "..."}}
        if (parsed['error'] is Map) {
          final errorObj = parsed['error'] as Map<String, dynamic>;
          final msg = errorObj['message']?.toString();
          if (msg != null && msg.isNotEmpty) {
            return msg;
          }
        }
        // Direct string error: {"error": "..."}
        if (parsed['error'] is String && (parsed['error'] as String).isNotEmpty) {
          return parsed['error'] as String;
        }
        // Direct message: {"message": "..."}
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

  /// Generates a personalized content pack using real AI API.
  /// Throws [AIServiceException] on any failure — never silently generates mock content.
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

    final provider = AIConfig.providerName;
    final model = AIConfig.model;
    final endpoint = '${AIConfig.baseUrl}/chat/completions';

    // 1. Verify API Key
    if (!AIConfig.hasApiKey) {
      if (kDebugMode) {
        debugPrint('[CreateDiff AI] Error: API Key is missing. Launch with --dart-define=GROK_API_KEY=your_key');
      }

      _lastDebugLog = AIDebugLog(
        provider: provider,
        model: model,
        timestamp: DateTime.now(),
        status: AIGenerationStatus.missingApiKey,
        errorMessage: 'Missing GROK_API_KEY compile-time define',
        durationMs: 0,
        promptLength: 0,
        responseLength: 0,
      );

      throw const AIServiceException(
        status: AIGenerationStatus.missingApiKey,
        message: 'API Key is not configured. Please launch the app with: flutter run --dart-define=GROK_API_KEY=your_key',
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

    // Debug logging for request dispatch (NEVER logs API key)
    if (kDebugMode) {
      debugPrint('==================== [CreateDiff AI Request] ====================');
      debugPrint('[CreateDiff AI] Provider: $provider');
      debugPrint('[CreateDiff AI] Model: $model');
      debugPrint('[CreateDiff AI] Endpoint: $endpoint');
      debugPrint('[CreateDiff AI] Prompt Length: $totalPromptLength chars');
      debugPrint('================================================================');
    }

    try {
      final uri = Uri.parse(endpoint);
      final request = await client.postUrl(uri);

      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer ${AIConfig.apiKey}');

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

      // Debug logging for response
      if (kDebugMode) {
        debugPrint('==================== [CreateDiff AI Response] ====================');
        debugPrint('[CreateDiff AI] HTTP Status: $statusCode');
        debugPrint('[CreateDiff AI] Latency: ${stopwatch.elapsedMilliseconds} ms');
        debugPrint('[CreateDiff AI] Response Body: $responseBody');
        debugPrint('================================================================');
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
              _lastDebugLog = AIDebugLog(
                provider: provider,
                model: model,
                timestamp: DateTime.now(),
                status: AIGenerationStatus.success,
                statusCode: 200,
                durationMs: stopwatch.elapsedMilliseconds,
                promptLength: totalPromptLength,
                responseLength: responseBody.length,
              );
              return parsed;
            }
          }
        }

        final parseError = 'Malformed JSON or missing required fields in AI response';
        if (kDebugMode) {
          debugPrint('[CreateDiff AI] Parsed Error: $parseError');
        }

        _lastDebugLog = AIDebugLog(
          provider: provider,
          model: model,
          timestamp: DateTime.now(),
          status: AIGenerationStatus.invalidResponse,
          statusCode: 200,
          errorMessage: parseError,
          durationMs: stopwatch.elapsedMilliseconds,
          promptLength: totalPromptLength,
          responseLength: responseBody.length,
        );
        throw AIServiceException(
          status: AIGenerationStatus.invalidResponse,
          message: 'The AI model returned an unexpected output format. Please try again.',
          statusCode: 200,
          rawResponse: responseBody,
        );
      } else {
        final serverError = _extractServerErrorMessage(responseBody, statusCode);

        if (kDebugMode) {
          debugPrint('[CreateDiff AI] Parsed Error: $serverError');
        }

        AIGenerationStatus failureStatus;
        if (statusCode == 401 || statusCode == 403) {
          failureStatus = AIGenerationStatus.invalidApiKey;
        } else if (statusCode == 429) {
          failureStatus = AIGenerationStatus.rateLimited;
        } else {
          failureStatus = AIGenerationStatus.serverError;
        }

        _lastDebugLog = AIDebugLog(
          provider: provider,
          model: model,
          timestamp: DateTime.now(),
          status: failureStatus,
          statusCode: statusCode,
          errorMessage: serverError,
          durationMs: stopwatch.elapsedMilliseconds,
          promptLength: totalPromptLength,
          responseLength: responseBody.length,
        );

        throw AIServiceException(
          status: failureStatus,
          message: serverError,
          statusCode: statusCode,
          rawResponse: responseBody,
        );
      }
    } on SocketException catch (e) {
      stopwatch.stop();
      final networkError = 'Network connection failed: ${e.message}';
      if (kDebugMode) {
        debugPrint('[CreateDiff AI] Parsed Error: $networkError');
      }
      _lastDebugLog = AIDebugLog(
        provider: provider,
        model: model,
        timestamp: DateTime.now(),
        status: AIGenerationStatus.networkError,
        errorMessage: networkError,
        durationMs: stopwatch.elapsedMilliseconds,
        promptLength: totalPromptLength,
        responseLength: 0,
      );
      throw AIServiceException(
        status: AIGenerationStatus.networkError,
        message: networkError,
      );
    } on TimeoutException {
      stopwatch.stop();
      final timeoutError = 'Request timed out after 35 seconds';
      if (kDebugMode) {
        debugPrint('[CreateDiff AI] Parsed Error: $timeoutError');
      }
      _lastDebugLog = AIDebugLog(
        provider: provider,
        model: model,
        timestamp: DateTime.now(),
        status: AIGenerationStatus.networkError,
        errorMessage: timeoutError,
        durationMs: stopwatch.elapsedMilliseconds,
        promptLength: totalPromptLength,
        responseLength: 0,
      );
      throw const AIServiceException(
        status: AIGenerationStatus.networkError,
        message: 'The AI generation request timed out. Please check your internet connection.',
      );
    } catch (e) {
      if (e is AIServiceException) rethrow;
      stopwatch.stop();
      final unknownError = e.toString();
      if (kDebugMode) {
        debugPrint('[CreateDiff AI] Parsed Error: $unknownError');
      }
      _lastDebugLog = AIDebugLog(
        provider: provider,
        model: model,
        timestamp: DateTime.now(),
        status: AIGenerationStatus.unknownError,
        errorMessage: unknownError,
        durationMs: stopwatch.elapsedMilliseconds,
        promptLength: totalPromptLength,
        responseLength: 0,
      );
      throw AIServiceException(
        status: AIGenerationStatus.unknownError,
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
