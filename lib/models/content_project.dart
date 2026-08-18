import 'generated_content.dart';

class ContentProject {
  final String id;
  final String platform;
  final String contentType;
  final String idea;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // 'generating', 'generated', 'designed', 'exported', 'draft'
  final GeneratedContent? generatedContent;
  final String selectedDesignTemplate;
  final String selectedDesignStyle;
  final String language;
  final String tone;
  final bool isDeleted;
  final DateTime? deletedAt;
  final bool isFavorite;
  final bool isDraft;
  final String? campaignId;
  final int? qualityScore;

  const ContentProject({
    required this.id,
    required this.platform,
    required this.contentType,
    required this.idea,
    required this.createdAt,
    DateTime? updatedAt,
    this.status = 'generated',
    this.generatedContent,
    this.selectedDesignTemplate = '',
    this.selectedDesignStyle = 'minimal',
    this.language = 'English',
    this.tone = 'Educational',
    this.isDeleted = false,
    this.deletedAt,
    this.isFavorite = false,
    this.isDraft = false,
    this.campaignId,
    this.qualityScore,
  }) : updatedAt = updatedAt ?? createdAt;

  ContentProject copyWith({
    String? id,
    String? platform,
    String? contentType,
    String? idea,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    GeneratedContent? generatedContent,
    String? selectedDesignTemplate,
    String? selectedDesignStyle,
    String? language,
    String? tone,
    bool? isDeleted,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    bool? isFavorite,
    bool? isDraft,
    String? campaignId,
    int? qualityScore,
  }) {
    return ContentProject(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      contentType: contentType ?? this.contentType,
      idea: idea ?? this.idea,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      generatedContent: generatedContent ?? this.generatedContent,
      selectedDesignTemplate: selectedDesignTemplate ?? this.selectedDesignTemplate,
      selectedDesignStyle: selectedDesignStyle ?? this.selectedDesignStyle,
      language: language ?? this.language,
      tone: tone ?? this.tone,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      isFavorite: isFavorite ?? this.isFavorite,
      isDraft: isDraft ?? this.isDraft,
      campaignId: campaignId ?? this.campaignId,
      qualityScore: qualityScore ?? this.qualityScore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform,
      'contentType': contentType,
      'idea': idea,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status,
      'generatedContent': generatedContent?.toJson(),
      'selectedDesignTemplate': selectedDesignTemplate,
      'selectedDesignStyle': selectedDesignStyle,
      'language': language,
      'tone': tone,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'isFavorite': isFavorite,
      'isDraft': isDraft,
      'campaignId': campaignId,
      'qualityScore': qualityScore ?? generatedContent?.quality?.overallScore,
    };
  }

  factory ContentProject.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now();

    final updated = json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'] as String) ?? created
        : created;

    final deleted = json['deletedAt'] != null
        ? DateTime.tryParse(json['deletedAt'] as String)
        : null;

    final generated = json['generatedContent'] != null
        ? GeneratedContent.fromJson(json['generatedContent'] as Map<String, dynamic>)
        : null;

    return ContentProject(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      platform: json['platform'] as String? ?? 'Instagram',
      contentType: json['contentType'] as String? ?? 'Reel',
      idea: json['idea'] as String? ?? '',
      createdAt: created,
      updatedAt: updated,
      status: json['status'] as String? ?? 'generated',
      generatedContent: generated,
      selectedDesignTemplate: json['selectedDesignTemplate'] as String? ?? '',
      selectedDesignStyle: json['selectedDesignStyle'] as String? ?? 'minimal',
      language: json['language'] as String? ?? 'English',
      tone: json['tone'] as String? ?? 'Educational',
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: deleted,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isDraft: json['isDraft'] as bool? ?? false,
      campaignId: json['campaignId'] as String?,
      qualityScore: (json['qualityScore'] as num?)?.toInt() ??
          generated?.quality?.overallScore,
    );
  }
}

