class QualityMetadata {
  final int hookStrength;
  final int platformFit;
  final int audienceFit;
  final int originality;
  final int overallScore;
  final List<String> issues;
  final bool retried;

  const QualityMetadata({
    this.hookStrength = 85,
    this.platformFit = 88,
    this.audienceFit = 86,
    this.originality = 84,
    this.overallScore = 86,
    this.issues = const [],
    this.retried = false,
  });

  QualityMetadata copyWith({
    int? hookStrength,
    int? platformFit,
    int? audienceFit,
    int? originality,
    int? overallScore,
    List<String>? issues,
    bool? retried,
  }) {
    return QualityMetadata(
      hookStrength: hookStrength ?? this.hookStrength,
      platformFit: platformFit ?? this.platformFit,
      audienceFit: audienceFit ?? this.audienceFit,
      originality: originality ?? this.originality,
      overallScore: overallScore ?? this.overallScore,
      issues: issues ?? this.issues,
      retried: retried ?? this.retried,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hookStrength': hookStrength,
      'platformFit': platformFit,
      'audienceFit': audienceFit,
      'originality': originality,
      'overallScore': overallScore,
      'issues': issues,
      'retried': retried,
    };
  }

  factory QualityMetadata.fromJson(Map<String, dynamic> json) {
    return QualityMetadata(
      hookStrength: (json['hookStrength'] as num?)?.toInt() ??
          (json['hook_strength'] as num?)?.toInt() ??
          85,
      platformFit: (json['platformFit'] as num?)?.toInt() ??
          (json['platform_fit'] as num?)?.toInt() ??
          88,
      audienceFit: (json['audienceFit'] as num?)?.toInt() ??
          (json['audience_fit'] as num?)?.toInt() ??
          86,
      originality: (json['originality'] as num?)?.toInt() ?? 84,
      overallScore: (json['overallScore'] as num?)?.toInt() ??
          (json['overall_score'] as num?)?.toInt() ??
          86,
      issues: (json['issues'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      retried: json['retried'] as bool? ?? false,
    );
  }
}
