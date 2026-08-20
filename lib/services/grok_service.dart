import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/creator_profile.dart';
import '../models/generated_content.dart';
import '../models/campaign_plan.dart';
import 'session_token_store.dart';

/// Explicit status codes representing the AI generation lifecycle and failure reasons.
enum GrokGenerationStatus {
  idle,
  loading,
  retrying,
  success,
  apiKeyMissing,
  invalidApiUrl,
  invalidKey,
  rateLimited,
  timeout,
  backendUnavailable,
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
    if (profile.preferredPlatforms.isNotEmpty) {
      buffer.writeln('• Preferred Platforms: ${profile.preferredPlatforms.join(", ")}');
    }
    if (profile.contentGoals.isNotEmpty) {
      buffer.writeln('• Content Goals: ${profile.contentGoals.join(", ")}');
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

  /// Sanitizes network errors so internal IP addresses or confusing raw socket exceptions are not shown to users.
  static String sanitizeNetworkErrorMessage(dynamic error) {
    if (error is SocketException) {
      final osMsg = error.osError?.message.toLowerCase() ?? '';
      final msg = error.message.toLowerCase();
      if (msg.contains('failed host lookup') ||
          osMsg.contains('nodename') ||
          osMsg.contains('servname')) {
        return 'Unable to resolve CreateDiff AI backend. Please check your internet connection or API settings.';
      }
      if (osMsg.contains('connection refused') || msg.contains('connection refused')) {
        return 'Unable to reach CreateDiff AI Studio server. The service may be starting up or temporarily offline. Please try again.';
      }
      if (msg.contains('network is unreachable') || osMsg.contains('network is unreachable')) {
        return 'No active internet connection detected. Please connect to Wi-Fi or cellular data and try again.';
      }
      return 'Unable to connect to CreateDiff AI Studio. Please check your internet connection and try again.';
    }
    if (error is HandshakeException || error is CertificateException) {
      return 'Secure connection could not be established with CreateDiff AI Studio. Please check your network security settings.';
    }
    if (error is TimeoutException) {
      return 'The AI Studio request timed out. Please tap to retry.';
    }
    if (error is FormatException) {
      return 'Received an unexpected response format from the AI server. Please tap to retry.';
    }
    final rawStr = error.toString();
    // Strip any IP addresses (e.g. 10.0.2.2, 127.0.0.1, 192.168.x.x, etc.)
    return rawStr.replaceAll(RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(:\d+)?\b'), '[server]');
  }

  static String _messageForStatusCode(int statusCode, String serverErrorMsg) {
    if (statusCode == 401) return 'Authentication failed. Please sign in again.';
    if (statusCode == 429) return serverErrorMsg.isNotEmpty ? serverErrorMsg : 'Too many requests. Please try again shortly.';
    if (statusCode >= 500) return 'CreateDiff AI Studio is temporarily unavailable. Please try again shortly.';
    return serverErrorMsg;
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
        if (parsed['detail'] is String && (parsed['detail'] as String).isNotEmpty) {
          return parsed['detail'] as String;
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
    int maxAttempts = 2,
    void Function(int attempt, int maxAttempts)? onRetry,
  }) async {
    final backendBaseUrl = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    final endpoint = '$backendBaseUrl/api/v1/generate';
    final provider = AppConfig.providerName;
    final model = AppConfig.model;

    if (!AppConfig.hasValidApiBaseUrl) {
      throw const GrokServiceException(
        status: GrokGenerationStatus.invalidApiUrl,
        message: 'CreateDiff AI Studio has an invalid API URL. Please update the app configuration.',
      );
    }

    if (!AppConfig.hasApiKey || !AppConfig.isConfigured || backendBaseUrl.isEmpty) {
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
      'preferredPlatforms': profile.preferredPlatforms,
      'primaryLanguage': profile.primaryLanguage,
      'secondaryLanguage': profile.secondaryLanguage,
      'tone': profile.tone,
      'contentGoals': profile.contentGoals,
      'contentStyle': profile.contentStyle,
      'brandDescription': profile.brandDescription,
      'preferredCTAStyle': profile.preferredCTAStyle,
      'emojiUsage': profile.emojiUsage,
      'languageProfile': profile.languageProfile.toJson(),
      'creatorMemory': profile.creatorMemory.toJson(),
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
    const timeoutDuration = Duration(seconds: 65);

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
      try {
        if (kDebugMode) {
          debugPrint('==================== [CreateDiff Backend AI Request (Attempt $attempt/$maxAttempts)] ====================');
          debugPrint('[CreateDiff Client] Endpoint: $endpoint');
          debugPrint('[CreateDiff Client] API host: ${Uri.parse(endpoint).host} | Path: ${Uri.parse(endpoint).path}');
          debugPrint('[CreateDiff Client] Platform: $platform | Format: $contentType');
          debugPrint('=========================================================================');
        }

        final uri = Uri.parse(endpoint);
        final request = await client.postUrl(uri);

        request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
        final accessToken = SessionTokenStore.accessToken;
        if (accessToken != null && accessToken.isNotEmpty) {
          request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
        }
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
            attemptCount: attempt,
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

          if (statusCode == 401) {
            throw GrokServiceException(
              status: GrokGenerationStatus.invalidKey,
              message: _messageForStatusCode(statusCode, serverErrorMsg),
              statusCode: statusCode,
              rawResponse: responseBody,
              requestId: requestId,
            );
          }

          if (statusCode == 403) {
            throw GrokServiceException(
              status: GrokGenerationStatus.serverError,
              message: serverErrorMsg.isNotEmpty ? serverErrorMsg : 'Access denied. Please check your permissions.',
              statusCode: statusCode,
              rawResponse: responseBody,
              requestId: requestId,
            );
          }

          if (statusCode == 429) {
            throw GrokServiceException(
              status: GrokGenerationStatus.rateLimited,
              message: _messageForStatusCode(statusCode, serverErrorMsg),
              statusCode: statusCode,
              rawResponse: responseBody,
              requestId: requestId,
            );
          }

          // Retry on 502/503/504 if attempts remain
          if ((statusCode >= 500) && attempt < maxAttempts) {
            onRetry?.call(attempt + 1, maxAttempts);
            await Future.delayed(const Duration(milliseconds: 600));
            continue;
          }

          final ex = GrokServiceException(
            status: statusCode == 502 || statusCode == 503
                ? GrokGenerationStatus.backendUnavailable
                : GrokGenerationStatus.serverError,
            message: _messageForStatusCode(statusCode, serverErrorMsg),
            statusCode: statusCode,
            rawResponse: responseBody,
            requestId: requestId,
          );

          _lastDebugLog = GrokDebugLog(
            provider: provider,
            model: model,
            timestamp: DateTime.now(),
            status: ex.status,
            statusCode: statusCode,
            errorMessage: ex.message,
            durationMs: overallStopwatch.elapsedMilliseconds,
            promptLength: serializedPayload.length,
            responseLength: responseBody.length,
            attemptCount: attempt,
            requestId: requestId,
          );

          throw ex;
        }
      } catch (e) {
        if (e is GrokServiceException) {
          rethrow;
        }

        // If it's a network error/timeout and attempts remain, retry once
        if (attempt < maxAttempts) {
          onRetry?.call(attempt + 1, maxAttempts);
          await Future.delayed(const Duration(milliseconds: 600));
          continue;
        }

        if (kDebugMode) {
          debugPrint('[CreateDiff Client] Connection exception: ${e.runtimeType}');
        }

        final sanitizedMessage = sanitizeNetworkErrorMessage(e);
        final status = e is TimeoutException
            ? GrokGenerationStatus.timeout
            : (e is SocketException || e is HandshakeException)
                ? GrokGenerationStatus.backendUnavailable
                : GrokGenerationStatus.unknownError;

        _lastDebugLog = GrokDebugLog(
          provider: provider,
          model: model,
          timestamp: DateTime.now(),
          status: status,
          errorMessage: sanitizedMessage,
          durationMs: overallStopwatch.elapsedMilliseconds,
          promptLength: serializedPayload.length,
          responseLength: 0,
          attemptCount: attempt,
        );

        throw GrokServiceException(
          status: status,
          message: sanitizedMessage,
        );
      } finally {
        client.close(force: true);
      }
    }

    throw const GrokServiceException(
      status: GrokGenerationStatus.networkError,
      message: 'Unable to connect to CreateDiff AI Studio. Please tap to retry.',
    );
  }

  /// Dispatches campaign planning request to CreateDiff Backend API (`POST /api/v1/campaign/plan`).
  static Future<CampaignPlan> planCampaign({
    required String goal,
    int durationDays = 7,
    String? platform,
    String? niche,
    required CreatorProfile profile,
    int maxAttempts = 2,
    void Function(int attempt, int maxAttempts)? onRetry,
  }) async {
    final backendBaseUrl = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    final endpoint = '$backendBaseUrl/api/v1/campaign/plan';

    if (!AppConfig.hasApiKey || !AppConfig.isConfigured || backendBaseUrl.isEmpty) {
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
      'preferredPlatforms': profile.preferredPlatforms,
      'primaryLanguage': profile.primaryLanguage,
      'secondaryLanguage': profile.secondaryLanguage,
      'tone': profile.tone,
      'contentGoals': profile.contentGoals,
      'contentStyle': profile.contentStyle,
      'brandDescription': profile.brandDescription,
      'preferredCTAStyle': profile.preferredCTAStyle,
      'emojiUsage': profile.emojiUsage,
      'languageProfile': profile.languageProfile.toJson(),
      'creatorMemory': profile.creatorMemory.toJson(),
    };

    final payload = {
      'goal': goal,
      'durationDays': durationDays,
      'platform': platform ?? 'All',
      if (niche != null && niche.isNotEmpty) 'niche': niche,
      'creatorContext': creatorContextMap,
    };

    final serializedPayload = jsonEncode(payload);
    const timeoutDuration = Duration(seconds: 70);

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
      try {
        final uri = Uri.parse(endpoint);
        final request = await client.postUrl(uri);

        request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
        final accessToken = SessionTokenStore.accessToken;
        if (accessToken != null && accessToken.isNotEmpty) {
          request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
        }
        request.headers.set('X-Request-ID', 'cd-camp-${DateTime.now().millisecondsSinceEpoch}');

        request.add(utf8.encode(serializedPayload));

        final response = await request.close().timeout(timeoutDuration);
        final responseBody = await response.transform(utf8.decoder).join();
        final statusCode = response.statusCode;
        final requestId = response.headers.value('x-request-id');

        if (statusCode == 200) {
          final jsonMap = jsonDecode(responseBody) as Map<String, dynamic>;
          return CampaignPlan.fromJson(jsonMap);
        } else {
          final serverErrorMsg = _extractServerErrorMessage(responseBody, statusCode);

          if (statusCode >= 500 && attempt < maxAttempts) {
            onRetry?.call(attempt + 1, maxAttempts);
            await Future.delayed(const Duration(milliseconds: 600));
            continue;
          }

          if (statusCode == 401) {
            throw GrokServiceException(
              status: GrokGenerationStatus.serverError,
              message: serverErrorMsg.isNotEmpty ? serverErrorMsg : 'Please sign in to continue.',
              statusCode: statusCode,
              requestId: requestId,
            );
          }

          if (statusCode == 403) {
            throw GrokServiceException(
              status: GrokGenerationStatus.serverError,
              message: serverErrorMsg.isNotEmpty ? serverErrorMsg : 'Access denied. Please check your permissions.',
              statusCode: statusCode,
              requestId: requestId,
            );
          }

          if (statusCode == 429) {
            throw GrokServiceException(
              status: GrokGenerationStatus.rateLimited,
              message: serverErrorMsg.isNotEmpty ? serverErrorMsg : 'Campaign planner rate limit exceeded. Please wait a moment.',
              statusCode: statusCode,
              requestId: requestId,
            );
          }
          throw GrokServiceException(
            status: GrokGenerationStatus.serverError,
            message: serverErrorMsg.isNotEmpty ? serverErrorMsg : 'Unable to generate campaign plan.',
            statusCode: statusCode,
            requestId: requestId,
          );
        }
      } catch (e) {
        if (e is GrokServiceException) rethrow;

        if (attempt < maxAttempts) {
          onRetry?.call(attempt + 1, maxAttempts);
          await Future.delayed(const Duration(milliseconds: 600));
          continue;
        }

        final sanitizedMessage = sanitizeNetworkErrorMessage(e);
        throw GrokServiceException(
          status: GrokGenerationStatus.networkError,
          message: sanitizedMessage,
        );
      } finally {
        client.close(force: true);
      }
    }

    throw const GrokServiceException(
      status: GrokGenerationStatus.networkError,
      message: 'Campaign generation could not connect to server. Please tap to retry.',
    );
  }
}
