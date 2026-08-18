class VisualIntelligence {
  final String visualStyle;
  final String layoutSuggestion;
  final String thumbnailDirection;
  final String typographySuggestion;
  final List<String> colorPalette;
  final String designMood;
  final List<String> brandConsistencySuggestions;
  final String visualHierarchy;
  final String thumbnailStrategy;
  final String imageDirection;

  const VisualIntelligence({
    this.visualStyle = 'Modern Creator Minimalist',
    this.layoutSuggestion = 'Bold top headline with focal graphic',
    this.thumbnailDirection = 'High-contrast typography with creator reaction',
    this.typographySuggestion = 'Geometric sans-serif with tracked caps',
    this.colorPalette = const ['#080A0F', '#4F43F9', '#7066FF', '#00B894'],
    this.designMood = 'High energy, educational, authentic',
    this.brandConsistencySuggestions = const [],
    this.visualHierarchy = 'Lead with the hook, then supporting proof and CTA',
    this.thumbnailStrategy = 'Use one clear promise with high contrast',
    this.imageDirection = 'Use authentic creator-led imagery or product context',
  });

  VisualIntelligence copyWith({
    String? visualStyle,
    String? layoutSuggestion,
    String? thumbnailDirection,
    String? typographySuggestion,
    List<String>? colorPalette,
    String? designMood,
    List<String>? brandConsistencySuggestions,
    String? visualHierarchy,
    String? thumbnailStrategy,
    String? imageDirection,
  }) {
    return VisualIntelligence(
      visualStyle: visualStyle ?? this.visualStyle,
      layoutSuggestion: layoutSuggestion ?? this.layoutSuggestion,
      thumbnailDirection: thumbnailDirection ?? this.thumbnailDirection,
      typographySuggestion: typographySuggestion ?? this.typographySuggestion,
      colorPalette: colorPalette ?? this.colorPalette,
      designMood: designMood ?? this.designMood,
      brandConsistencySuggestions: brandConsistencySuggestions ?? this.brandConsistencySuggestions,
      visualHierarchy: visualHierarchy ?? this.visualHierarchy,
      thumbnailStrategy: thumbnailStrategy ?? this.thumbnailStrategy,
      imageDirection: imageDirection ?? this.imageDirection,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visualStyle': visualStyle,
      'layoutSuggestion': layoutSuggestion,
      'thumbnailDirection': thumbnailDirection,
      'typographySuggestion': typographySuggestion,
      'colorPalette': colorPalette,
      'designMood': designMood,
      'brandConsistencySuggestions': brandConsistencySuggestions,
      'visualHierarchy': visualHierarchy,
      'thumbnailStrategy': thumbnailStrategy,
      'imageDirection': imageDirection,
    };
  }

  factory VisualIntelligence.fromJson(Map<String, dynamic> json) {
    return VisualIntelligence(
      visualStyle: json['visualStyle'] as String? ??
          json['visual_style'] as String? ??
          'Modern Creator Minimalist',
      layoutSuggestion: json['layoutSuggestion'] as String? ??
          json['layout_suggestion'] as String? ??
          'Bold top headline with focal graphic',
      thumbnailDirection: json['thumbnailDirection'] as String? ??
          json['thumbnail_direction'] as String? ??
          'High-contrast typography with creator reaction',
      typographySuggestion: json['typographySuggestion'] as String? ??
          json['typography_suggestion'] as String? ??
          'Geometric sans-serif with tracked caps',
      colorPalette: (json['colorPalette'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['color_palette'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['#080A0F', '#4F43F9', '#7066FF', '#00B894'],
      designMood: json['designMood'] as String? ??
          json['design_mood'] as String? ??
          'High energy, educational, authentic',
      brandConsistencySuggestions: (json['brandConsistencySuggestions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['brand_consistency_suggestions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      visualHierarchy: json['visualHierarchy'] as String? ??
          json['visual_hierarchy'] as String? ??
          'Lead with the hook, then supporting proof and CTA',
      thumbnailStrategy: json['thumbnailStrategy'] as String? ??
          json['thumbnail_strategy'] as String? ??
          'Use one clear promise with high contrast',
      imageDirection: json['imageDirection'] as String? ??
          json['image_direction'] as String? ??
          'Use authentic creator-led imagery or product context',
    );
  }
}
