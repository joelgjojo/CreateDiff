import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/creator_profile.dart';
import 'session_token_store.dart';
import 'performance_intelligence_service.dart';

class CreatorIdeaSuggestion {
  final String topic;
  final String platform;
  final String contentType;
  final String hookIdea;
  final String strategicAngle;
  final String whyItWorks;

  const CreatorIdeaSuggestion({
    required this.topic,
    required this.platform,
    required this.contentType,
    required this.hookIdea,
    required this.strategicAngle,
    required this.whyItWorks,
  });

  factory CreatorIdeaSuggestion.fromJson(Map<String, dynamic> json) {
    return CreatorIdeaSuggestion(
      topic: json['topic'] as String? ?? '',
      platform: json['platform'] as String? ?? 'Instagram',
      contentType: json['contentType'] as String? ?? json['content_type'] as String? ?? 'Reel',
      hookIdea: json['hookIdea'] as String? ?? json['hook_idea'] as String? ?? '',
      strategicAngle: json['strategicAngle'] as String? ?? json['strategic_angle'] as String? ?? '',
      whyItWorks: json['whyItWorks'] as String? ?? json['why_it_works'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'platform': platform,
        'contentType': contentType,
        'hookIdea': hookIdea,
        'strategicAngle': strategicAngle,
        'whyItWorks': whyItWorks,
      };
}

class AssistantSuggestionResult {
  final String strategySummary;
  final List<CreatorIdeaSuggestion> suggestions;
  final bool isColdStartFallback;
  final String sourceLabel;

  const AssistantSuggestionResult({
    required this.strategySummary,
    required this.suggestions,
    required this.isColdStartFallback,
    required this.sourceLabel,
  });

  factory AssistantSuggestionResult.fromJson(Map<String, dynamic> json) {
    final rawSuggestions = json['suggestions'] as List<dynamic>? ?? [];
    return AssistantSuggestionResult(
      strategySummary: json['strategySummary'] as String? ?? json['strategy_summary'] as String? ?? 'Personalized creator strategy',
      suggestions: rawSuggestions.map((s) => CreatorIdeaSuggestion.fromJson(s as Map<String, dynamic>)).toList(),
      isColdStartFallback: json['isColdStartFallback'] as bool? ?? json['is_cold_start_fallback'] as bool? ?? false,
      sourceLabel: json['sourceLabel'] as String? ?? json['source_label'] as String? ?? 'Personalized Creator AI',
    );
  }
}

/// AI Creator Assistant: Acts as an always-on Chief Content Strategist,
/// providing tailored weekly concepts, angle analysis, and cold-start fallback.
class CreatorAssistantService {
  CreatorAssistantService._();

  static HttpClient _createClient() => HttpClient()..connectionTimeout = const Duration(seconds: 15);
  static String get _backendBaseUrl => AppConfig.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');

  /// Generates deterministic cold-start fallback ideas when offline or without backend.
  static AssistantSuggestionResult heuristicSuggestions(CreatorProfile profile, {bool isColdStart = true}) {
    final niche = profile.niche.isNotEmpty ? profile.niche : 'Tech & Creative Strategy';
    final platform = profile.preferredPlatforms.isNotEmpty ? profile.preferredPlatforms.first : 'Instagram';

    return AssistantSuggestionResult(
      strategySummary: isColdStart
          ? 'Foundational strategic roadmap tailored for your "$niche" domain.'
          : 'Performance-optimized recommendation loop for "$niche" based on creator feedback signals.',
      suggestions: [
        CreatorIdeaSuggestion(
          topic: 'The 3 Biggest Mistakes Beginners Make in $niche',
          platform: platform,
          contentType: 'Reel',
          hookIdea: 'If you are starting out in $niche, STOP doing these 3 things.',
          strategicAngle: 'Mistake-Correction Hook + High Retention',
          whyItWorks: 'Negative bias hooks generate 2.4x higher watch time on short-form algorithms.',
        ),
        CreatorIdeaSuggestion(
          topic: 'My Exact Step-by-Step Execution Framework for $niche',
          platform: platform,
          contentType: 'Carousel',
          hookIdea: 'Swipe through for the entire blueprint I wish I had on day one.',
          strategicAngle: 'Actionable Educational Value + High Save Rate',
          whyItWorks: 'Step-by-step swipeable blueprints drive bookmarking and algorithmic distribution.',
        ),
        CreatorIdeaSuggestion(
          topic: 'Why Common Advice in $niche is Outdated in 2026',
          platform: 'YouTube',
          contentType: 'Short',
          hookIdea: 'Most creators in $niche are doing this completely backwards.',
          strategicAngle: 'Contrarian Perspective + Authority Building',
          whyItWorks: 'Challenging common wisdom creates strong audience engagement and comment discussion.',
        ),
      ],
      isColdStartFallback: isColdStart,
      sourceLabel: isColdStart ? 'Profile-based starting suggestions' : 'Performance-Tuned AI Partner',
    );
  }

  /// Fetches smart assistant suggestions from backend with automatic cold start handling.
  static Future<AssistantSuggestionResult> fetchWeeklySuggestions({
    required CreatorProfile profile,
    String? customQuery,
  }) async {
    final hasHistory = await PerformanceIntelligenceService.hasPerformanceHistory();
    final endpoint = '$_backendBaseUrl/api/v1/assistant/suggest';
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
        'query': customQuery ?? 'What should I create next week?',
        'hasPerformanceHistory': hasHistory,
        'creator_context': {
          'name': profile.creatorName,
          'niche': profile.niche,
          'target_audience': profile.targetAudience,
          'tone': profile.tone,
          'content_goals': profile.contentGoals,
          'brandDNA': profile.brandDNA.toJson(),
        },
      };

      request.add(utf8.encode(jsonEncode(payload)));
      final response = await request.close().timeout(const Duration(seconds: 12));
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        return AssistantSuggestionResult.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CreatorAssistantService] Fallback to heuristic suggestions: $e');
      }
    } finally {
      client.close();
    }

    return heuristicSuggestions(profile, isColdStart: !hasHistory);
  }
}
