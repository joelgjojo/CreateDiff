class CreativeDirectorInsight {
  final String audienceInsight;
  final String contentAngle;
  final String storyStructure;
  final String improvementSuggestion;
  final String reasoning;

  const CreativeDirectorInsight({
    this.audienceInsight = '',
    this.contentAngle = '',
    this.storyStructure = '',
    this.improvementSuggestion = '',
    this.reasoning = '',
  });

  factory CreativeDirectorInsight.fromJson(Map<String, dynamic> j) => CreativeDirectorInsight(
    audienceInsight: j['audienceInsight'] as String? ?? j['audience_insight'] as String? ?? '',
    contentAngle: j['contentAngle'] as String? ?? j['content_angle'] as String? ?? '',
    storyStructure: j['storyStructure'] as String? ?? j['story_structure'] as String? ?? '',
    improvementSuggestion: j['improvementSuggestion'] as String? ?? j['improvement_suggestion'] as String? ?? '',
    reasoning: j['reasoning'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'audienceInsight': audienceInsight,
    'contentAngle': contentAngle,
    'storyStructure': storyStructure,
    'improvementSuggestion': improvementSuggestion,
    'reasoning': reasoning,
  };
}

class ContentReview {
  final String hookAnalysis;
  final String clarityAnalysis;
  final String audienceFit;
  final String disclaimer;
  final List<String> improvementSuggestions;

  const ContentReview({
    this.hookAnalysis = '',
    this.clarityAnalysis = '',
    this.audienceFit = '',
    this.improvementSuggestions = const [],
    this.disclaimer = 'AI analysis only — not real performance prediction.',
  });

  factory ContentReview.fromJson(Map<String, dynamic> j) => ContentReview(
    hookAnalysis: j['hookAnalysis'] as String? ?? j['hook_analysis'] as String? ?? '',
    clarityAnalysis: j['clarityAnalysis'] as String? ?? j['clarity_analysis'] as String? ?? '',
    audienceFit: j['audienceFit'] as String? ?? j['audience_fit'] as String? ?? '',
    improvementSuggestions: (j['improvementSuggestions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        (j['improvement_suggestions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        const [],
    disclaimer: j['disclaimer'] as String? ?? 'AI analysis only — not real performance prediction.',
  );

  Map<String, dynamic> toJson() => {
    'hookAnalysis': hookAnalysis,
    'clarityAnalysis': clarityAnalysis,
    'audienceFit': audienceFit,
    'improvementSuggestions': improvementSuggestions,
    'disclaimer': disclaimer,
  };
}

class RepurposedContent {
  final String instagramCaption;
  final String linkedinPost;
  final String youtubeDescription;
  final List<String> xThread;
  final List<String> blogOutline;

  const RepurposedContent({
    this.instagramCaption = '',
    this.linkedinPost = '',
    this.youtubeDescription = '',
    this.xThread = const [],
    this.blogOutline = const [],
  });

  factory RepurposedContent.fromJson(Map<String, dynamic> j) => RepurposedContent(
    instagramCaption: j['instagramCaption'] as String? ?? j['instagram_caption'] as String? ?? '',
    linkedinPost: j['linkedinPost'] as String? ?? j['linkedin_post'] as String? ?? '',
    youtubeDescription: j['youtubeDescription'] as String? ?? j['youtube_description'] as String? ?? '',
    xThread: (j['xThread'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        (j['x_thread'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        const [],
    blogOutline: (j['blogOutline'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        (j['blog_outline'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        const [],
  );

  Map<String, dynamic> toJson() => {
    'instagramCaption': instagramCaption,
    'linkedinPost': linkedinPost,
    'youtubeDescription': youtubeDescription,
    'xThread': xThread,
    'blogOutline': blogOutline,
  };
}
