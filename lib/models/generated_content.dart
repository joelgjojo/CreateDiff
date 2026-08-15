class GeneratedContent {
  final List<String> hooks;
  final String caption;
  final List<String> ctas;
  final List<String> hashtagsHighReach;
  final List<String> hashtagsMediumReach;
  final List<String> hashtagsNiche;
  final String coverText;
  final List<String> variations;

  const GeneratedContent({
    this.hooks = const [],
    this.caption = '',
    this.ctas = const [],
    this.hashtagsHighReach = const [],
    this.hashtagsMediumReach = const [],
    this.hashtagsNiche = const [],
    this.coverText = '',
    this.variations = const [],
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
    );
  }
}
