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
  retrying,
  success,
  apiKeyMissing,
  invalidKey,
  rateLimited,
  networkError,
  serverError,
  invalidResponse,
  unknownError,
}

/// Alias for general AI generation status
typedef AIGenerationStatus = GrokGenerationStatus;

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
  final int attemptCount;

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
    this.attemptCount = 1,
  });
}

/// Production xAI Grok API Client with Exponential Backoff & Retry Engine.
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
    buffer.writeln('=== LANGUAGE & REGIONAL RULES ===');
    buffer.writeln('• Content Language separation: Write hooks, captions, and cover text in the creator\'s chosen language/dialect (e.g. Malayalam script, Manglish, Hindi, English).');
    buffer.writeln('• If Primary Language is "Manglish": Write in English script blended naturally with Malayalam vocabulary and modern Kerala creator slang (e.g. "Nammal", "Machane", "Scene", "Kidu", "Poli", "Set aayi"). Keep it authentic, energetic, and relatable.');
    buffer.writeln('• If Primary Language is "Malayalam": Write in native Malayalam script (മലയാളം) with fluent, natural phrasing suited for social media.');
    buffer.writeln('• If Primary Language is "Hindi" or "Hinglish": Use conversational Hindi/Hinglish with modern creator terminology.');
    buffer.writeln('• If Primary Language is "Tamil" / "Telugu": Use natural, culturally resonant phrasing.');
    buffer.writeln('• If Primary Language is "English": Use modern, punchy creator English with active verbs, conversational flow, and zero corporate jargon.');
    buffer.writeln('');
    buffer.writeln('=== PLATFORM & FORMAT INTELLIGENCE ===');
    buffer.writeln('• Instagram Reel: Fast-paced hooks (visual + audio cues in first 3s), punchy caption with white space, and engagement prompt.');
    buffer.writeln('• Instagram Carousel / Post: Slide-by-slide value breakdown, educational nuggets, and a save/share CTA.');
    buffer.writeln('• Instagram Story: Interactive poll/question ideas and quick conversational hooks.');
    buffer.writeln('• YouTube Short: Immediate intrigue, continuous pacing, and loop-friendly structure.');
    buffer.writeln('• YouTube Video: Comprehensive outline with chapter structure, value delivery, and SEO-friendly description.');
    buffer.writeln('• LinkedIn Post / Article: Strong 1-2 line opening hook, insight-dense bullet points, double line breaks, and conversation-starter CTA.');
    buffer.writeln('');
    buffer.writeln('=== HASHTAG STRATEGY (STRICT CATEGORIES) ===');
    buffer.writeln('• IMPORTANT: Hashtags must follow social platform discoverability standards.');
    buffer.writeln('• Write hashtags primarily in English/Latin characters for maximum search indexing (e.g. #KeralaFood, #MalayaliCreator, #TechInMalayalam, #IndianCreators) instead of non-indexed regional script, unless explicitly requested.');
    buffer.writeln('• hashtagsHighReach: Exactly 5 broad discovery tags (1M+ reach, high volume).');
    buffer.writeln('• hashtagsMediumReach: Exactly 4 category/industry-specific tags (50K–1M reach).');
    buffer.writeln('• hashtagsNiche: Exactly 3 community/hyper-targeted tags (<50K reach).');
    buffer.writeln('');
    buffer.writeln('=== STRICT OUTPUT INSTRUCTIONS ===');
    buffer.writeln('1. Deliver output exclusively in valid, parseable JSON format.');
    buffer.writeln('2. Do not wrap the JSON with markdown code blocks (no ```json or ```). Return raw JSON.');
    buffer.writeln('3. Provide exactly 5 distinct, high-impact hooks covering curiosity, contrarian, blueprint, story, and question angles.');
    buffer.writeln('4. Provide a full formatted caption with clean line breaks, value points, and a strong ending.');
    buffer.writeln('5. Provide 3 action-oriented CTAs aligned with the creator\'s CTA style.');
    buffer.writeln('6. Segment hashtags into 3 reach tiers: high reach (broad discovery), medium reach (niche/topic), and niche/community (highly targeted).');
    buffer.writeln('7. Provide a punchy, high-contrast Cover Text (3-5 uppercase words) suitable for visual design slides.');
    buffer.writeln('8. Provide 3 creative format variations (e.g. Standard, High-Engagement, Story Framework).');
    buffer.writeln('9. Respect the specified language and regional dialect.');
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
    String? overrideLength,
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
    if (overrideLength != null && overrideLength.isNotEmpty) {
      buffer.writeln('Length Preference: $overrideLength');
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

  /// Dispatches generation request to Grok/Groq API with Exponential Backoff Retry.
  /// Progressive timeouts: Attempt 1 = 10s, Attempt 2 = 20s, Attempt 3 = 35s.
  static Future<GeneratedContent> generateContent({
    required String platform,
    required String contentType,
    required String idea,
    required CreatorProfile profile,
    String? overrideTone,
    String? overrideLanguage,
    String? overrideLength,
    void Function(int attempt, int maxAttempts)? onRetry,
  }) async {
    final apiKey = ApiConfig.apiKey;
    final baseUrl = ApiConfig.baseUrl;
    final endpoint = baseUrl.endsWith('/chat/completions')
        ? baseUrl
        : (baseUrl.endsWith('/') ? '${baseUrl}chat/completions' : '$baseUrl/chat/completions');
    final model = ApiConfig.model;
    final provider = ApiConfig.providerName;

    // Strict missing API key validation
    if (apiKey.isEmpty) {
      _lastDebugLog = GrokDebugLog(
        provider: provider,
        model: model,
        timestamp: DateTime.now(),
        status: GrokGenerationStatus.apiKeyMissing,
        errorMessage: 'API Key not configured',
        durationMs: 0,
        promptLength: 0,
        responseLength: 0,
      );
      throw const GrokServiceException(
        status: GrokGenerationStatus.apiKeyMissing,
        message: 'AI features unavailable — API not configured.',
      );
    }

    final systemPrompt = buildSystemPrompt(profile: profile);
    final userPrompt = buildUserPrompt(
      platform: platform,
      contentType: contentType,
      idea: idea,
      overrideTone: overrideTone,
      overrideLanguage: overrideLanguage,
      overrideLength: overrideLength,
    );

    final totalPromptLength = systemPrompt.length + userPrompt.length;
    final startsWithXai = apiKey.startsWith('xai-');
    final keyLength = apiKey.length;

    // Retry settings: 3 total attempts
    const maxAttempts = 3;
    final timeouts = [
      const Duration(seconds: 10),
      const Duration(seconds: 20),
      const Duration(seconds: 35),
    ];

    GrokServiceException? lastException;
    final overallStopwatch = Stopwatch()..start();

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      final attemptTimeout = timeouts[attempt - 1];

      if (kDebugMode) {
        debugPrint('==================== [CreateDiff Grok AI Request (Attempt $attempt/$maxAttempts)] ====================');
        debugPrint('[CreateDiff Grok AI] Provider: $provider');
        debugPrint('[CreateDiff Grok AI] Model: $model');
        debugPrint('[CreateDiff Grok AI] Endpoint URL: $endpoint');
        debugPrint('[CreateDiff Grok AI] Timeout: ${attemptTimeout.inSeconds}s');
        debugPrint('[CreateDiff Grok AI] API Key starts with "xai-": $startsWithXai (len: $keyLength)');
        debugPrint('======================================================================');
      }

      if (attempt > 1) {
        onRetry?.call(attempt, maxAttempts);
        // Exponential backoff delay: 600ms, 1200ms
        await Future.delayed(Duration(milliseconds: 600 * (1 << (attempt - 2))));
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

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

        final response = await request.close().timeout(attemptTimeout);
        final responseBody = await response.transform(utf8.decoder).join();
        final statusCode = response.statusCode;

        if (kDebugMode) {
          debugPrint('==================== [CreateDiff Grok AI Response (Attempt $attempt)] ====================');
          debugPrint('[CreateDiff Grok AI] HTTP Status Code: $statusCode');
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
                overallStopwatch.stop();
                _lastDebugLog = GrokDebugLog(
                  provider: provider,
                  model: model,
                  timestamp: DateTime.now(),
                  status: GrokGenerationStatus.success,
                  statusCode: 200,
                  durationMs: overallStopwatch.elapsedMilliseconds,
                  promptLength: totalPromptLength,
                  responseLength: responseBody.length,
                  attemptCount: attempt,
                );
                return parsed;
              }
            }
          }

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

          if (isAuthFailure) {
            final authMsg = provider.contains('xAI')
                ? 'Invalid xAI API key. Check your xAI console key.'
                : 'Invalid API configuration. Check your API key in settings.';
            _lastDebugLog = GrokDebugLog(
              provider: provider,
              model: model,
              timestamp: DateTime.now(),
              status: GrokGenerationStatus.invalidKey,
              statusCode: statusCode,
              errorMessage: authMsg,
              durationMs: overallStopwatch.elapsedMilliseconds,
              promptLength: totalPromptLength,
              responseLength: responseBody.length,
              attemptCount: attempt,
            );
            // Do NOT retry authentication failures
            throw GrokServiceException(
              status: GrokGenerationStatus.invalidKey,
              message: authMsg,
              statusCode: statusCode,
              rawResponse: responseBody,
            );
          }

          if (statusCode == 429) {
            String rateLimitMsg = 'AI service temporarily busy. Rate limit exceeded.';
            final retryAfter = response.headers.value('retry-after');
            if (retryAfter != null && retryAfter.trim().isNotEmpty) {
              final seconds = int.tryParse(retryAfter.trim());
              if (seconds != null && seconds > 0) {
                rateLimitMsg = 'Rate limit exceeded. Try again in $seconds seconds.';
              }
            }
            throw GrokServiceException(
              status: GrokGenerationStatus.rateLimited,
              message: rateLimitMsg,
              statusCode: statusCode,
              rawResponse: responseBody,
            );
          }

          // Transient server error (500, 502, 503, 504) -> retry eligible
          lastException = GrokServiceException(
            status: GrokGenerationStatus.serverError,
            message: 'AI provider temporarily unavailable. Please retry shortly.',
            statusCode: statusCode,
            rawResponse: responseBody,
          );
        }
      } on SocketException catch (e) {
        lastException = GrokServiceException(
          status: GrokGenerationStatus.networkError,
          message: 'No internet connection detected. Check your network (${e.message}).',
        );
      } on TimeoutException {
        lastException = GrokServiceException(
          status: GrokGenerationStatus.networkError,
          message: 'AI generation timed out (${attemptTimeout.inSeconds}s). Tap to retry.',
        );
      } catch (e) {
        if (e is GrokServiceException) {
          if (e.status == GrokGenerationStatus.invalidKey ||
              e.status == GrokGenerationStatus.apiKeyMissing ||
              e.status == GrokGenerationStatus.rateLimited) {
            rethrow; // Non-retryable
          }
          lastException = e;
        } else {
          lastException = GrokServiceException(
            status: GrokGenerationStatus.unknownError,
            message: e.toString(),
          );
        }
      } finally {
        client.close(force: true);
      }
    }

    overallStopwatch.stop();
    final finalError = lastException ??
        const GrokServiceException(
          status: GrokGenerationStatus.unknownError,
          message: 'Unable to generate content. Please check your connection and retry.',
        );

    _lastDebugLog = GrokDebugLog(
      provider: provider,
      model: model,
      timestamp: DateTime.now(),
      status: finalError.status,
      statusCode: finalError.statusCode,
      errorMessage: finalError.message,
      durationMs: overallStopwatch.elapsedMilliseconds,
      promptLength: totalPromptLength,
      responseLength: 0,
      attemptCount: maxAttempts,
    );

    throw finalError;
  }

  /// Strict parser that validates JSON keys and types against schema.
  static GeneratedContent? _parseStructuredContent(String rawContent) {
    try {
      String sanitized = rawContent.trim();
      if (sanitized.startsWith('```json')) {
        sanitized = sanitized.substring(7);
      } else if (sanitized.startsWith('```')) {
        sanitized = sanitized.substring(3);
      }
      if (sanitized.endsWith('```')) {
        sanitized = sanitized.substring(0, sanitized.length - 3);
      }
      sanitized = sanitized.trim();

      final decoded = jsonDecode(sanitized);
      if (decoded is! Map<String, dynamic>) return null;

      final hooksList = _parseStringList(decoded['hooks']);
      final caption = decoded['caption'] as String? ?? '';
      final ctasList = _parseStringList(decoded['ctas']);
      final coverText = decoded['coverText'] as String? ?? '';
      final variationsList = _parseStringList(decoded['variations']);

      List<String> highReach = _parseStringList(decoded['hashtagsHighReach']);
      List<String> medReach = _parseStringList(decoded['hashtagsMediumReach']);
      List<String> nicheReach = _parseStringList(decoded['hashtagsNiche']);

      if (highReach.isEmpty && medReach.isEmpty && nicheReach.isEmpty) {
        final legacyTags = _parseStringList(decoded['hashtags']);
        if (legacyTags.isNotEmpty) {
          final count = legacyTags.length;
          highReach = legacyTags.take((count * 0.4).ceil()).toList();
          medReach = legacyTags.skip(highReach.length).take((count * 0.35).ceil()).toList();
          nicheReach = legacyTags.skip(highReach.length + medReach.length).toList();
        }
      }

      if (hooksList.isEmpty && caption.isEmpty) {
        return null;
      }

      return GeneratedContent(
        hooks: hooksList.isNotEmpty ? hooksList : ['Compelling hook for your audience'],
        caption: caption.isNotEmpty ? caption : 'Engaging story caption...',
        ctas: ctasList.isNotEmpty ? ctasList : ['Save this post', 'Follow for more'],
        hashtagsHighReach: highReach,
        hashtagsMediumReach: medReach,
        hashtagsNiche: nicheReach,
        coverText: coverText.isNotEmpty ? coverText : 'CONTENT TITLE',
        variations: variationsList,
      );
    } catch (_) {
      return null;
    }
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString().trim()).where((s) => s.isNotEmpty).toList();
    }
    return [];
  }
}
