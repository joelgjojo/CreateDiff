class LanguageProfile {
  final String language;
  final String preferredStyle;
  final String audienceType;
  final String regionalContext;
  final String communicationTone;

  const LanguageProfile({
    this.language = 'English',
    this.preferredStyle = 'Conversational',
    this.audienceType = 'General audience',
    this.regionalContext = '',
    this.communicationTone = '',
  });

  Map<String, dynamic> toJson() => {'language': language, 'preferredStyle': preferredStyle, 'audienceType': audienceType, 'regionalContext': regionalContext, 'communicationTone': communicationTone};
  factory LanguageProfile.fromJson(Map<String, dynamic> json) => LanguageProfile(
    language: json['language'] as String? ?? 'English',
    preferredStyle: json['preferredStyle'] as String? ?? 'Conversational',
    audienceType: json['audienceType'] as String? ?? 'General audience',
    regionalContext: json['regionalContext'] as String? ?? '',
    communicationTone: json['communicationTone'] as String? ?? '',
  );
}

class CreatorMemory {
  final List<String> successfulPatterns;
  final List<String> preferredHooks;
  final List<String> preferredFormats;
  final List<String> avoidPatterns;
  final List<String> brandRules;

  const CreatorMemory({this.successfulPatterns = const [], this.preferredHooks = const [], this.preferredFormats = const [], this.avoidPatterns = const [], this.brandRules = const []});

  bool get isBuilding => successfulPatterns.isEmpty && preferredHooks.isEmpty && preferredFormats.isEmpty && avoidPatterns.isEmpty && brandRules.isEmpty;
  CreatorMemory copyWith({List<String>? successfulPatterns, List<String>? preferredHooks, List<String>? preferredFormats, List<String>? avoidPatterns, List<String>? brandRules}) => CreatorMemory(
    successfulPatterns: successfulPatterns ?? this.successfulPatterns,
    preferredHooks: preferredHooks ?? this.preferredHooks,
    preferredFormats: preferredFormats ?? this.preferredFormats,
    avoidPatterns: avoidPatterns ?? this.avoidPatterns,
    brandRules: brandRules ?? this.brandRules,
  );
  Map<String, dynamic> toJson() => {'successfulPatterns': successfulPatterns, 'preferredHooks': preferredHooks, 'preferredFormats': preferredFormats, 'avoidPatterns': avoidPatterns, 'brandRules': brandRules};
  factory CreatorMemory.fromJson(Map<String, dynamic> json) => CreatorMemory(
    successfulPatterns: _list(json['successfulPatterns']), preferredHooks: _list(json['preferredHooks']), preferredFormats: _list(json['preferredFormats']), avoidPatterns: _list(json['avoidPatterns']), brandRules: _list(json['brandRules']),
  );
  static List<String> _list(dynamic value) => value is List ? value.map((e) => e.toString()).toList() : const [];
}

/// Brand DNA captures deep creator identity, visual aesthetics, audience psychology, and regional context.
class BrandDNA {
  final String writingStyle;
  final String visualIdentity;
  final String creatorPersonality;
  final String audienceProfile;
  final List<String> preferredColors;
  final List<String> successfulContentPatterns;
  final String culturalContext;

  const BrandDNA({
    this.writingStyle = 'Actionable, clear, authentic',
    this.visualIdentity = 'Modern minimalist, clean typography, high contrast',
    this.creatorPersonality = 'Educator & Creative Strategist',
    this.audienceProfile = 'Ambitious students & digital creators',
    this.preferredColors = const ['#4F43F9', '#7066FF'],
    this.successfulContentPatterns = const [],
    this.culturalContext = 'Pan-India & Regional Creator Ecosystem',
  });

  BrandDNA copyWith({
    String? writingStyle,
    String? visualIdentity,
    String? creatorPersonality,
    String? audienceProfile,
    List<String>? preferredColors,
    List<String>? successfulContentPatterns,
    String? culturalContext,
  }) {
    return BrandDNA(
      writingStyle: writingStyle ?? this.writingStyle,
      visualIdentity: visualIdentity ?? this.visualIdentity,
      creatorPersonality: creatorPersonality ?? this.creatorPersonality,
      audienceProfile: audienceProfile ?? this.audienceProfile,
      preferredColors: preferredColors ?? this.preferredColors,
      successfulContentPatterns: successfulContentPatterns ?? this.successfulContentPatterns,
      culturalContext: culturalContext ?? this.culturalContext,
    );
  }

  Map<String, dynamic> toJson() => {
        'writingStyle': writingStyle,
        'visualIdentity': visualIdentity,
        'creatorPersonality': creatorPersonality,
        'audienceProfile': audienceProfile,
        'preferredColors': preferredColors,
        'successfulContentPatterns': successfulContentPatterns,
        'culturalContext': culturalContext,
      };

  factory BrandDNA.fromJson(Map<String, dynamic> json) => BrandDNA(
        writingStyle: json['writingStyle'] as String? ?? 'Actionable, clear, authentic',
        visualIdentity: json['visualIdentity'] as String? ?? 'Modern minimalist, clean typography, high contrast',
        creatorPersonality: json['creatorPersonality'] as String? ?? 'Educator & Creative Strategist',
        audienceProfile: json['audienceProfile'] as String? ?? 'Ambitious students & digital creators',
        preferredColors: CreatorMemory._list(json['preferredColors']).isNotEmpty
            ? CreatorMemory._list(json['preferredColors'])
            : const ['#4F43F9', '#7066FF'],
        successfulContentPatterns: CreatorMemory._list(json['successfulContentPatterns']),
        culturalContext: json['culturalContext'] as String? ?? 'Pan-India & Regional Creator Ecosystem',
      );
}
