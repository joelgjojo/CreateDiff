import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/creator_profile.dart';
import 'session_token_store.dart';

/// Structured output from the Intent Understanding Engine.
class CreatorIntent {
  final String idea;
  final String platform;
  final String contentType;
  final String audience;
  final String tone;
  final String language;
  final String visualDirection;
  final String contentGoal;

  const CreatorIntent({
    required this.idea,
    required this.platform,
    required this.contentType,
    required this.audience,
    required this.tone,
    required this.language,
    required this.visualDirection,
    required this.contentGoal,
  });

  factory CreatorIntent.fromJson(Map<String, dynamic> json) {
    return CreatorIntent(
      idea: json['idea'] as String? ?? '',
      platform: json['platform'] as String? ?? 'Instagram',
      contentType: json['contentType'] as String? ?? json['content_type'] as String? ?? 'Reel',
      audience: json['audience'] as String? ?? 'Students & Creators',
      tone: json['tone'] as String? ?? 'Educational & Actionable',
      language: json['language'] as String? ?? 'English',
      visualDirection: json['visualDirection'] as String? ?? json['visual_direction'] as String? ?? 'Modern minimalist',
      contentGoal: json['contentGoal'] as String? ?? json['content_goal'] as String? ?? 'Audience Growth',
    );
  }

  Map<String, dynamic> toJson() => {
        'idea': idea,
        'platform': platform,
        'contentType': contentType,
        'audience': audience,
        'tone': tone,
        'language': language,
        'visualDirection': visualDirection,
        'contentGoal': contentGoal,
      };
}

/// Zero-Prompt Creator Workflow service: transforms raw creator thoughts or
/// speech transcriptions into structured creation parameters.
class IntentUnderstandingService {
  IntentUnderstandingService._();

  static HttpClient _createClient() {
    return HttpClient()..connectionTimeout = const Duration(seconds: 15);
  }

  static String get _backendBaseUrl => AppConfig.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');

  /// Heuristic parser for instant / offline extraction.
  static CreatorIntent heuristicExtract(String rawPrompt, CreatorProfile profile) {
    final lower = rawPrompt.toLowerCase();

    // Platform detection
    var platform = profile.preferredPlatforms.isNotEmpty ? profile.preferredPlatforms.first : 'Instagram';
    if (lower.contains('youtube') || lower.contains('yt')) {
      platform = 'YouTube';
    } else if (lower.contains('linkedin')) {
      platform = 'LinkedIn';
    } else if (lower.contains('twitter') || lower.contains('x.com') || lower.contains('tweet')) {
      platform = 'X / Twitter';
    } else if (lower.contains('instagram') || lower.contains('ig')) {
      platform = 'Instagram';
    }

    // Format detection
    var contentType = 'Reel';
    if (lower.contains('carousel') || lower.contains('slides')) {
      contentType = 'Carousel';
    } else if (lower.contains('story') || lower.contains('stories')) {
      contentType = 'Story';
    } else if (lower.contains('short')) {
      contentType = 'Short';
    } else if (lower.contains('post') || lower.contains('caption')) {
      contentType = 'Post';
    } else if (lower.contains('article') || lower.contains('newsletter')) {
      contentType = 'Article';
    }

    // Language detection
    var language = profile.primaryLanguage.isNotEmpty ? profile.primaryLanguage : 'English';
    if (lower.contains('malayalam') || lower.contains('മലയാളം')) {
      language = 'Malayalam';
    } else if (lower.contains('manglish')) {
      language = 'Manglish';
    } else if (lower.contains('hindi') || lower.contains('हिंदी') || lower.contains('hinglish')) {
      language = 'Hindi';
    } else if (lower.contains('english')) {
      language = 'English';
    }

    final audience = lower.contains('student') || lower.contains('college')
        ? 'College students & early career learners'
        : (profile.targetAudience.isNotEmpty ? profile.targetAudience : 'Digital creators & ambitious builders');

    final tone = lower.contains('explain') || lower.contains('how to') || lower.contains('tips')
        ? 'Educational & Step-by-step'
        : (profile.tone.isNotEmpty ? profile.tone : 'Energetic & Actionable');

    // Clean idea
    var clean = rawPrompt
        .replaceAll(
          RegExp(
            r'\b(make|create|generate|write|a|an|in|for|reel|carousel|post|story|short|youtube|instagram|linkedin|malayalam|manglish|hindi|english)\b',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
    if (clean.length < 3) clean = rawPrompt.trim();

    return CreatorIntent(
      idea: clean,
      platform: platform,
      contentType: contentType,
      audience: audience,
      tone: tone,
      language: language,
      visualDirection: 'Modern high-contrast dark aesthetic with luminous accents',
      contentGoal: profile.contentGoals.isNotEmpty ? profile.contentGoals.first : 'Audience Growth & Engagement',
    );
  }

  /// Extracts structured creator intent via backend API with offline fallback.
  static Future<CreatorIntent> extractIntent({
    required String rawPrompt,
    required CreatorProfile profile,
  }) async {
    if (rawPrompt.trim().isEmpty) {
      return heuristicExtract(rawPrompt, profile);
    }

    final endpoint = '$_backendBaseUrl/api/v1/intent/extract';
    final client = _createClient();

    try {
      final uri = Uri.parse(endpoint);
      final request = await client.postUrl(uri);

      final token = SessionTokenStore.accessToken;
      if (token != null && token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');

      final payload = {
        'prompt': rawPrompt.trim(),
        'creator_context': {
          'name': profile.creatorName,
          'niche': profile.niche,
          'tone': profile.tone,
          'primary_language': profile.primaryLanguage,
          'target_audience': profile.targetAudience,
        },
      };

      request.add(utf8.encode(jsonEncode(payload)));
      final response = await request.close().timeout(const Duration(seconds: 10));
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        return CreatorIntent.fromJson(data);
      }
      return heuristicExtract(rawPrompt, profile);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[IntentUnderstandingService] Fallback to heuristic parser: $e');
      }
      return heuristicExtract(rawPrompt, profile);
    } finally {
      client.close();
    }
  }
}
