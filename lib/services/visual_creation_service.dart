import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/creator_profile.dart';
import 'session_token_store.dart';

class ReelCoverDirection {
  final String coverConcept;
  final String headline;
  final String composition;
  final String typography;
  final List<String> colorPalette;
  final String visualHierarchy;

  const ReelCoverDirection({
    required this.coverConcept,
    required this.headline,
    required this.composition,
    required this.typography,
    required this.colorPalette,
    required this.visualHierarchy,
  });

  factory ReelCoverDirection.fromJson(Map<String, dynamic> json) {
    return ReelCoverDirection(
      coverConcept: json['cover_concept'] as String? ?? json['coverConcept'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      composition: json['composition'] as String? ?? '',
      typography: json['typography'] as String? ?? '',
      colorPalette: (json['color_palette'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['colorPalette'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['#080A0F', '#4F43F9', '#7066FF', '#00B894'],
      visualHierarchy: json['visual_hierarchy'] as String? ?? json['visualHierarchy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'cover_concept': coverConcept,
        'headline': headline,
        'composition': composition,
        'typography': typography,
        'color_palette': colorPalette,
        'visual_hierarchy': visualHierarchy,
      };
}

class YouTubeThumbnailDirection {
  final String thumbnailIdea;
  final String textPlacement;
  final String emotionExpression;
  final String compositionGuide;
  final String attentionStrategy;

  const YouTubeThumbnailDirection({
    required this.thumbnailIdea,
    required this.textPlacement,
    required this.emotionExpression,
    required this.compositionGuide,
    required this.attentionStrategy,
  });

  factory YouTubeThumbnailDirection.fromJson(Map<String, dynamic> json) {
    return YouTubeThumbnailDirection(
      thumbnailIdea: json['thumbnail_idea'] as String? ?? json['thumbnailIdea'] as String? ?? '',
      textPlacement: json['text_placement'] as String? ?? json['textPlacement'] as String? ?? '',
      emotionExpression: json['emotion_expression'] as String? ?? json['emotionExpression'] as String? ?? '',
      compositionGuide: json['composition_guide'] as String? ?? json['compositionGuide'] as String? ?? '',
      attentionStrategy: json['attention_strategy'] as String? ?? json['attentionStrategy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'thumbnail_idea': thumbnailIdea,
        'text_placement': textPlacement,
        'emotion_expression': emotionExpression,
        'composition_guide': compositionGuide,
        'attention_strategy': attentionStrategy,
      };
}

class CarouselSlideDesign {
  final int slideNumber;
  final String headline;
  final String bodyText;
  final String visualDirection;

  const CarouselSlideDesign({
    required this.slideNumber,
    required this.headline,
    required this.bodyText,
    required this.visualDirection,
  });

  factory CarouselSlideDesign.fromJson(Map<String, dynamic> json) {
    return CarouselSlideDesign(
      slideNumber: json['slide_number'] as int? ?? json['slideNumber'] as int? ?? 1,
      headline: json['headline'] as String? ?? '',
      bodyText: json['body_text'] as String? ?? json['bodyText'] as String? ?? '',
      visualDirection: json['visual_direction'] as String? ?? json['visualDirection'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'slide_number': slideNumber,
        'headline': headline,
        'body_text': bodyText,
        'visual_direction': visualDirection,
      };
}

class CarouselBlueprint {
  final String title;
  final int totalSlides;
  final List<String> colorPalette;
  final List<CarouselSlideDesign> slides;

  const CarouselBlueprint({
    required this.title,
    required this.totalSlides,
    required this.colorPalette,
    required this.slides,
  });

  factory CarouselBlueprint.fromJson(Map<String, dynamic> json) {
    return CarouselBlueprint(
      title: json['title'] as String? ?? '',
      totalSlides: json['total_slides'] as int? ?? json['totalSlides'] as int? ?? 4,
      colorPalette: (json['color_palette'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['#080A0F', '#4F43F9', '#7066FF'],
      slides: (json['slides'] as List<dynamic>?)
              ?.map((e) => CarouselSlideDesign.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'total_slides': totalSlides,
        'color_palette': colorPalette,
        'slides': slides.map((s) => s.toJson()).toList(),
      };
}

class VisualDirectionResult {
  final String formatType;
  final ReelCoverDirection? reelCover;
  final YouTubeThumbnailDirection? youtubeThumbnail;
  final CarouselBlueprint? carousel;
  final List<String> designNotes;

  const VisualDirectionResult({
    required this.formatType,
    this.reelCover,
    this.youtubeThumbnail,
    this.carousel,
    this.designNotes = const [],
  });

  factory VisualDirectionResult.fromJson(Map<String, dynamic> json) {
    return VisualDirectionResult(
      formatType: json['format_type'] as String? ?? json['formatType'] as String? ?? 'reel_cover',
      reelCover: json['reel_cover'] != null
          ? ReelCoverDirection.fromJson(json['reel_cover'] as Map<String, dynamic>)
          : (json['reelCover'] != null ? ReelCoverDirection.fromJson(json['reelCover'] as Map<String, dynamic>) : null),
      youtubeThumbnail: json['youtube_thumbnail'] != null
          ? YouTubeThumbnailDirection.fromJson(json['youtube_thumbnail'] as Map<String, dynamic>)
          : (json['youtubeThumbnail'] != null ? YouTubeThumbnailDirection.fromJson(json['youtubeThumbnail'] as Map<String, dynamic>) : null),
      carousel: json['carousel'] != null
          ? CarouselBlueprint.fromJson(json['carousel'] as Map<String, dynamic>)
          : null,
      designNotes: (json['design_notes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['designNotes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }
}

/// Creative Production Engine (Text-Direction Only per cost-control boundary).
class VisualCreationService {
  VisualCreationService._();

  static HttpClient _createClient() => HttpClient()..connectionTimeout = const Duration(seconds: 15);
  static String get _backendBaseUrl => AppConfig.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');

  /// Offline heuristic fallback for Reel Cover direction
  static VisualDirectionResult heuristicReelCover(String topic, String? hook, CreatorProfile profile) {
    final headline = (hook != null && hook.isNotEmpty) ? hook : topic;
    return VisualDirectionResult(
      formatType: 'reel_cover',
      reelCover: ReelCoverDirection(
        coverConcept: 'Cinematic creator framing with high-contrast text overlay',
        headline: headline.length > 30 ? headline.substring(0, 30).toUpperCase() : headline.toUpperCase(),
        composition: 'Subject centered in lower 60%, bold typography in top 30% safety zone',
        typography: 'Ultra-bold geometric sans-serif (Space Grotesk / Plus Jakarta Sans)',
        colorPalette: profile.brandDNA.preferredColors.isNotEmpty
            ? profile.brandDNA.preferredColors
            : const ['#080A0F', '#4F43F9', '#7066FF', '#00B894'],
        visualHierarchy: '1. Headline Text -> 2. Creator Expression -> 3. Luminous Accent Border',
      ),
      designNotes: const [
        'Keep typography strictly within 9:16 safe margins',
        'Use soft blue-violet drop shadow on white headline text',
      ],
    );
  }

  /// Offline heuristic fallback for YouTube Thumbnail direction
  static VisualDirectionResult heuristicThumbnail(String topic, String? hook, CreatorProfile profile) {
    final headline = (hook != null && hook.isNotEmpty) ? hook : topic;
    return VisualDirectionResult(
      formatType: 'youtube_thumbnail',
      youtubeThumbnail: YouTubeThumbnailDirection(
        thumbnailIdea: 'High-contrast revelation concept with curiosity trigger',
        textPlacement: 'Top-left 3 words max: ${headline.length > 20 ? headline.substring(0, 20).toUpperCase() : headline.toUpperCase()}',
        emotionExpression: 'High-energy curiosity / realization expression toward camera',
        compositionGuide: 'Subject on right third, 3D illustrative element on left third, high-contrast glow',
        attentionStrategy: 'Pattern interrupt with saturated blue-violet neon accent and bold contrasting text',
      ),
      designNotes: const [
        'Standard YouTube 16:9 canvas (1280x720)',
        'Ensure 3-word headline is readable on mobile feeds (100px width)',
      ],
    );
  }

  /// Offline heuristic fallback for Carousel Blueprint
  static VisualDirectionResult heuristicCarousel(String topic, String? hook, CreatorProfile profile) {
    final title = (hook != null && hook.isNotEmpty) ? hook : topic;
    return VisualDirectionResult(
      formatType: 'carousel',
      carousel: CarouselBlueprint(
        title: title,
        totalSlides: 4,
        colorPalette: profile.brandDNA.preferredColors.isNotEmpty
            ? profile.brandDNA.preferredColors
            : const ['#080A0F', '#4F43F9', '#7066FF'],
        slides: [
          CarouselSlideDesign(
            slideNumber: 1,
            headline: title.length > 35 ? title.substring(0, 35).toUpperCase() : title.toUpperCase(),
            bodyText: 'The essential creator breakdown on $topic.',
            visualDirection: 'Hook cover: Minimalist dark canvas with electric blue highlight badge',
          ),
          const CarouselSlideDesign(
            slideNumber: 2,
            headline: 'The Common Bottleneck',
            bodyText: 'Most creators fail here because they overlook fundamental principles.',
            visualDirection: 'Contrast diagram showing common pitfall vs proven strategy',
          ),
          const CarouselSlideDesign(
            slideNumber: 3,
            headline: 'The 3-Step Execution Framework',
            bodyText: '1. Structure intention\n2. Iterate rapidly\n3. Optimize with analytics',
            visualDirection: 'Numbered glass cards with luminous border glow',
          ),
          const CarouselSlideDesign(
            slideNumber: 4,
            headline: 'Save & Apply This Strategy',
            bodyText: 'Double tap to bookmark for your next creation cycle.',
            visualDirection: 'Clean CTA card with bookmark icon and creator handle lockup',
          ),
        ],
      ),
      designNotes: const [
        'Render slides in 1:1 or 4:5 aspect ratio',
        'Maintain clean 24px inner padding across all slides',
      ],
    );
  }

  /// Request visual text design direction from backend API with offline fallback.
  static Future<VisualDirectionResult> generateDirection({
    required String formatType,
    required String topic,
    String? hook,
    required CreatorProfile profile,
  }) async {
    final endpoint = '$_backendBaseUrl/api/v1/visual/direction';
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
        'format_type': formatType,
        'topic': topic,
        'hook': hook,
        'creator_context': {
          'name': profile.creatorName,
          'niche': profile.niche,
          'brandDNA': profile.brandDNA.toJson(),
        },
      };

      request.add(utf8.encode(jsonEncode(payload)));
      final response = await request.close().timeout(const Duration(seconds: 12));
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        return VisualDirectionResult.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[VisualCreationService] Fallback to heuristic visual direction: $e');
      }
    } finally {
      client.close();
    }

    // Offline fallback
    if (formatType.contains('thumb') || formatType.contains('youtube')) {
      return heuristicThumbnail(topic, hook, profile);
    } else if (formatType.contains('carousel')) {
      return heuristicCarousel(topic, hook, profile);
    }
    return heuristicReelCover(topic, hook, profile);
  }
}
