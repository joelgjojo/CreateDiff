import 'generated_content.dart';

class ContentProject {
  final String id;
  final String platform;
  final String contentType;
  final String idea;
  final DateTime createdAt;
  final String status; // 'generating', 'generated', 'designed', 'exported'
  final GeneratedContent? generatedContent;
  final String selectedDesignTemplate;
  final String selectedDesignStyle;
  final String language;
  final String tone;

  const ContentProject({
    required this.id,
    required this.platform,
    required this.contentType,
    required this.idea,
    required this.createdAt,
    this.status = 'generated',
    this.generatedContent,
    this.selectedDesignTemplate = '',
    this.selectedDesignStyle = 'minimal',
    this.language = 'English',
    this.tone = 'Educational',
  });

  ContentProject copyWith({
    String? id,
    String? platform,
    String? contentType,
    String? idea,
    DateTime? createdAt,
    String? status,
    GeneratedContent? generatedContent,
    String? selectedDesignTemplate,
    String? selectedDesignStyle,
    String? language,
    String? tone,
  }) {
    return ContentProject(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      contentType: contentType ?? this.contentType,
      idea: idea ?? this.idea,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      generatedContent: generatedContent ?? this.generatedContent,
      selectedDesignTemplate: selectedDesignTemplate ?? this.selectedDesignTemplate,
      selectedDesignStyle: selectedDesignStyle ?? this.selectedDesignStyle,
      language: language ?? this.language,
      tone: tone ?? this.tone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform,
      'contentType': contentType,
      'idea': idea,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'generatedContent': generatedContent?.toJson(),
      'selectedDesignTemplate': selectedDesignTemplate,
      'selectedDesignStyle': selectedDesignStyle,
      'language': language,
      'tone': tone,
    };
  }

  factory ContentProject.fromJson(Map<String, dynamic> json) {
    return ContentProject(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      platform: json['platform'] as String? ?? 'Instagram',
      contentType: json['contentType'] as String? ?? 'Reel',
      idea: json['idea'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] as String? ?? 'generated',
      generatedContent: json['generatedContent'] != null
          ? GeneratedContent.fromJson(json['generatedContent'] as Map<String, dynamic>)
          : null,
      selectedDesignTemplate: json['selectedDesignTemplate'] as String? ?? '',
      selectedDesignStyle: json['selectedDesignStyle'] as String? ?? 'minimal',
      language: json['language'] as String? ?? 'English',
      tone: json['tone'] as String? ?? 'Educational',
    );
  }
}
