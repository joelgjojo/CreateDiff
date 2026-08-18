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
