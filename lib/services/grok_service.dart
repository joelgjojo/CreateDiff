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

/// Detailed exception thrown when CreateDiff AI generation fails.
class GrokServiceException implements Exception {
  final GrokGenerationStatus status;
  final String message;
  final int? statusCode;
  final String? rawResponse;
  final String? requestId;

  const GrokServiceException({
    required this.status,
    required this.message,
    this.statusCode,
    this.rawResponse,
    this.requestId,
  });

  @override
  String toString() => 'GrokServiceException($status: $message, code: $statusCode, req: $requestId)';
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
  final String? requestId;

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
    this.requestId,
  });
}

/// Production CreateDiff API Client communicating securely with CreateDiff FastAPI Backend.
class GrokService {
  GrokService._();

  static GrokDebugLog? _lastDebugLog;
  static GrokDebugLog? get lastDebugLog => _lastDebugLog;

  /// Dedicated CreateDiff Studio System Prompt (Server-side mirror & client utility).
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

  /// Dispatches generation request to CreateDiff Backend API (`POST /api/v1/generate`).
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
    final backendBaseUrl = ApiConfig.backendBaseUrl.replaceAll(RegExp(r'/+$'), '');
    final endpoint = '$backendBaseUrl/api/v1/generate';
    final provider = ApiConfig.providerName;
    final model = ApiConfig.model;

    if (!ApiConfig.hasApiKey || backendBaseUrl.isEmpty) {
      _lastDebugLog = GrokDebugLog(
        provider: provider,
        model: model,
        timestamp: DateTime.now(),
        status: GrokGenerationStatus.apiKeyMissing,
        errorMessage: 'AI features unavailable — API not configured.',
        durationMs: 0,
        promptLength: 0,
        responseLength: 0,
      );
      throw const GrokServiceException(
        status: GrokGenerationStatus.apiKeyMissing,
        message: 'AI features unavailable — API not configured.',
      );
    }

    final creatorContextMap = {
      'name': profile.creatorName,
      'username': profile.username,
      'niche': profile.niche,
      'category': profile.category,
      'targetAudience': profile.targetAudience,
      'primaryLanguage': profile.primaryLanguage,
      'secondaryLanguage': profile.secondaryLanguage,
      'tone': profile.tone,
      'contentStyle': profile.contentStyle,
      'brandDescription': profile.brandDescription,
      'preferredCTAStyle': profile.preferredCTAStyle,
      'emojiUsage': profile.emojiUsage,
    };

    final payload = {
      'platform': platform,
      'contentType': contentType,
      'idea': idea,
      if (overrideTone != null && overrideTone.isNotEmpty) 'overrideTone': overrideTone,
      if (overrideLanguage != null && overrideLanguage.isNotEmpty) 'overrideLanguage': overrideLanguage,
      if (overrideLength != null && overrideLength.isNotEmpty) 'overrideLength': overrideLength,
      'creatorContext': creatorContextMap,
    };

    final serializedPayload = jsonEncode(payload);
    final overallStopwatch = Stopwatch()..start();

    // 65-second total timeout to handle Render free-tier cold starts smoothly
    const timeoutDuration = Duration(seconds: 65);
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);

    try {
      if (kDebugMode) {
        debugPrint('==================== [CreateDiff Backend AI Request] ====================');
        debugPrint('[CreateDiff Client] Endpoint: $endpoint');
        debugPrint('[CreateDiff Client] Platform: $platform | Format: $contentType');
        debugPrint('=========================================================================');
      }

      final uri = Uri.parse(endpoint);
      final request = await client.postUrl(uri);

      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      request.headers.set('X-Request-ID', 'cd-mob-${DateTime.now().millisecondsSinceEpoch}');

      request.add(utf8.encode(serializedPayload));

      final response = await request.close().timeout(timeoutDuration);
      final responseBody = await response.transform(utf8.decoder).join();
      final statusCode = response.statusCode;
      final requestId = response.headers.value('x-request-id');

      if (kDebugMode) {
        debugPrint('==================== [CreateDiff Backend AI Response] ====================');
        debugPrint('[CreateDiff Client] HTTP Status Code: $statusCode (req: $requestId)');
        debugPrint('==========================================================================');
      }

      if (statusCode == 200) {
        final jsonMap = jsonDecode(responseBody) as Map<String, dynamic>;
        final parsed = GeneratedContent.fromJson(jsonMap);
        overallStopwatch.stop();

        _lastDebugLog = GrokDebugLog(
          provider: provider,
          model: model,
          timestamp: DateTime.now(),
          status: GrokGenerationStatus.success,
          statusCode: 200,
          durationMs: overallStopwatch.elapsedMilliseconds,
          promptLength: serializedPayload.length,
          responseLength: responseBody.length,
          attemptCount: 1,
          requestId: requestId,
        );

        return parsed;
      } else {
        final serverErrorMsg = _extractServerErrorMessage(responseBody, statusCode);

        if (statusCode == 400 || statusCode == 422) {
          throw GrokServiceException(
            status: GrokGenerationStatus.invalidResponse,
            message: serverErrorMsg.isNotEmpty ? serverErrorMsg : 'Invalid generation parameters. Please check your topic/idea and try again.',
            statusCode: statusCode,
            rawResponse: responseBody,
            requestId: requestId,
          );
        }

        if (statusCode == 429) {
          throw GrokServiceException(
            status: GrokGenerationStatus.rateLimited,
            message: serverErrorMsg.isNotEmpty ? serverErrorMsg : 'Generation rate limit exceeded. Please wait a moment before trying again.',
            statusCode: statusCode,
            rawResponse: responseBody,
            requestId: requestId,
          );
        }

        if (statusCode == 504) {
          throw GrokServiceException(
            status: GrokGenerationStatus.networkError,
            message: 'AI generation timed out. The server was busy or waking up. Please tap to retry.',
            statusCode: statusCode,
            rawResponse: responseBody,
            requestId: requestId,
          );
        }

        throw GrokServiceException(
          status: GrokGenerationStatus.serverError,
          message: serverErrorMsg.isNotEmpty ? serverErrorMsg : 'AI service temporarily unavailable. Please retry shortly.',
          statusCode: statusCode,
          rawResponse: responseBody,
          requestId: requestId,
        );
      }
    } on SocketException catch (e) {
      throw GrokServiceException(
        status: GrokGenerationStatus.networkError,
        message: 'No internet connection detected or backend unavailable. Check your network (${e.message}).',
      );
    } on TimeoutException {
      throw const GrokServiceException(
        status: GrokGenerationStatus.networkError,
        message: 'Request timed out while connecting to the AI backend. Please tap to retry.',
      );
    } catch (e) {
      if (e is GrokServiceException) rethrow;
      throw GrokServiceException(
        status: GrokGenerationStatus.unknownError,
        message: e.toString(),
      );
    } finally {
      client.close(force: true);
    }
  }
}
