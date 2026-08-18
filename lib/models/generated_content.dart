import 'visual_intelligence.dart';
import 'quality_metadata.dart';

class CarouselSlide {
  final int slideNumber;
  final String headline;
  final String bodyText;
  final String visualCue;

  const CarouselSlide({
    this.slideNumber = 1,
    this.headline = '',
    this.bodyText = '',
    this.visualCue = '',
  });

  CarouselSlide copyWith({
    int? slideNumber,
    String? headline,
    String? bodyText,
    String? visualCue,
  }) {
    return CarouselSlide(
      slideNumber: slideNumber ?? this.slideNumber,
      headline: headline ?? this.headline,
      bodyText: bodyText ?? this.bodyText,
      visualCue: visualCue ?? this.visualCue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slideNumber': slideNumber,
      'headline': headline,
      'bodyText': bodyText,
      'visualCue': visualCue,
    };
  }

  factory CarouselSlide.fromJson(Map<String, dynamic> json) {
    return CarouselSlide(
      slideNumber: (json['slideNumber'] as num?)?.toInt() ??
          (json['slide_number'] as num?)?.toInt() ??
          1,
      headline: json['headline'] as String? ?? '',
      bodyText: json['bodyText'] as String? ??
          json['body_text'] as String? ??
          json['body'] as String? ??
          '',
      visualCue: json['visualCue'] as String? ??
          json['visual_cue'] as String? ??
          '',
    );
  }
}

class GeneratedContent {
  final List<String> hooks;
  final String caption;
  final List<String> ctas;
  final List<String> hashtagsHighReach;
  final List<String> hashtagsMediumReach;
  final List<String> hashtagsNiche;
  final String coverText;
  final List<String> variations;
  // Platform-specific rich outputs
  final String? script;
  final List<String> sceneDirections;
  final List<CarouselSlide> slides;
  final List<String> titleOptions;
  final String? thumbnailText;
  final List<String> storyPrompts;
  // Intelligence layers
  final VisualIntelligence? visualIntelligence;
  final QualityMetadata? quality;

  const GeneratedContent({
    this.hooks = const [],
    this.caption = '',
    this.ctas = const [],
    this.hashtagsHighReach = const [],
    this.hashtagsMediumReach = const [],
    this.hashtagsNiche = const [],
    this.coverText = '',
    this.variations = const [],
    this.script,
    this.sceneDirections = const [],
    this.slides = const [],
    this.titleOptions = const [],
    this.thumbnailText,
    this.storyPrompts = const [],
    this.visualIntelligence,
    this.quality,
  });

  GeneratedContent copyWith({
    List<String>? hooks,
    String? caption,
    List<String>? ctas,
    List<String>? hashtagsHighReach,
    List<String>? hashtagsMediumReach,
    List<String>? hashtagsNiche,
    String? coverText,
    List<String>? variations,
    String? script,
    List<String>? sceneDirections,
    List<CarouselSlide>? slides,
    List<String>? titleOptions,
    String? thumbnailText,
    List<String>? storyPrompts,
    VisualIntelligence? visualIntelligence,
    QualityMetadata? quality,
  }) {
    return GeneratedContent(
      hooks: hooks ?? this.hooks,
      caption: caption ?? this.caption,
      ctas: ctas ?? this.ctas,
      hashtagsHighReach: hashtagsHighReach ?? this.hashtagsHighReach,
      hashtagsMediumReach: hashtagsMediumReach ?? this.hashtagsMediumReach,
      hashtagsNiche: hashtagsNiche ?? this.hashtagsNiche,
      coverText: coverText ?? this.coverText,
      variations: variations ?? this.variations,
      script: script ?? this.script,
      sceneDirections: sceneDirections ?? this.sceneDirections,
      slides: slides ?? this.slides,
      titleOptions: titleOptions ?? this.titleOptions,
      thumbnailText: thumbnailText ?? this.thumbnailText,
      storyPrompts: storyPrompts ?? this.storyPrompts,
      visualIntelligence: visualIntelligence ?? this.visualIntelligence,
      quality: quality ?? this.quality,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hooks': hooks,
      'caption': caption,
      'ctas': ctas,
      'hashtagsHighReach': hashtagsHighReach,
      'hashtagsMediumReach': hashtagsMediumReach,
      'hashtagsNiche': hashtagsNiche,
      'coverText': coverText,
      'variations': variations,
      if (script != null) 'script': script,
      'sceneDirections': sceneDirections,
      'slides': slides.map((s) => s.toJson()).toList(),
      'titleOptions': titleOptions,
      if (thumbnailText != null) 'thumbnailText': thumbnailText,
      'storyPrompts': storyPrompts,
      if (visualIntelligence != null) 'visualIntelligence': visualIntelligence!.toJson(),
      if (quality != null) 'quality': quality!.toJson(),
    };
  }

  factory GeneratedContent.fromJson(Map<String, dynamic> json) {
    return GeneratedContent(
      hooks: (json['hooks'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['hooks_options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      caption: json['caption'] as String? ?? '',
      ctas: (json['ctas'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['cta'] != null ? [json['cta'].toString()] : []),
      hashtagsHighReach: (json['hashtagsHighReach'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['hashtags_high_reach'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      hashtagsMediumReach: (json['hashtagsMediumReach'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['hashtags_medium_reach'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      hashtagsNiche: (json['hashtagsNiche'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['hashtags_niche'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      coverText: json['coverText'] as String? ?? json['cover_text'] as String? ?? '',
      variations: (json['variations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      script: json['script'] as String?,
      sceneDirections: (json['sceneDirections'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['scene_directions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      slides: (json['slides'] as List<dynamic>?)
              ?.map((s) => CarouselSlide.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      titleOptions: (json['titleOptions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['title_options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      thumbnailText: json['thumbnailText'] as String? ?? json['thumbnail_text'] as String?,
      storyPrompts: (json['storyPrompts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['story_prompts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      visualIntelligence: json['visualIntelligence'] != null
          ? VisualIntelligence.fromJson(json['visualIntelligence'] as Map<String, dynamic>)
          : (json['visual_intelligence'] != null
              ? VisualIntelligence.fromJson(json['visual_intelligence'] as Map<String, dynamic>)
              : null),
      quality: json['quality'] != null
          ? QualityMetadata.fromJson(json['quality'] as Map<String, dynamic>)
          : null,
    );
  }
}

