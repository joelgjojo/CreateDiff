import 'package:flutter/material.dart';
import 'creator_intelligence.dart';

class CreatorProfile {
  final String id;
  final String creatorName;
  final String username;
  final String niche;
  final String category;
  final String targetAudience;
  final List<String> preferredPlatforms;
  final String primaryLanguage;
  final String secondaryLanguage;
  final String tone;
  final List<String> contentGoals;
  final String contentStyle;
  final String brandDescription;
  final String preferredCTAStyle;
  final String emojiUsage; // 'none', 'minimal', 'moderate', 'heavy'
  final Color primaryColor;
  final Color secondaryColor;
  final String logoUrl;
  final String websiteUrl;
  final String instagramHandle;
  final String youtubeHandle;
  final LanguageProfile languageProfile;
  final CreatorMemory creatorMemory;
  final BrandDNA brandDNA;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CreatorProfile({
    this.id = 'default_creator_profile',
    this.creatorName = '',
    this.username = '',
    this.niche = 'Technology',
    this.category = 'Content Creator',
    this.targetAudience = 'Creators and small businesses',
    this.preferredPlatforms = const ['Instagram', 'YouTube', 'LinkedIn'],
    this.primaryLanguage = 'English',
    this.secondaryLanguage = '',
    this.tone = 'Educational',
    this.contentGoals = const ['Audience Growth', 'Community Engagement'],
    this.contentStyle = 'Actionable and inspiring',
    this.brandDescription = '',
    this.preferredCTAStyle = 'Direct',
    this.emojiUsage = 'moderate',
    this.primaryColor = const Color(0xFF4F43F9),
    this.secondaryColor = const Color(0xFF7066FF),
    this.logoUrl = '',
    this.websiteUrl = '',
    this.instagramHandle = '',
    this.youtubeHandle = '',
    this.languageProfile = const LanguageProfile(),
    this.creatorMemory = const CreatorMemory(),
    this.brandDNA = const BrandDNA(),
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? const _DefaultDateTime(),
        updatedAt = updatedAt ?? createdAt ?? const _DefaultDateTime();

  String get handle => username.isNotEmpty ? username : '@creator';

  CreatorProfile copyWith({
    String? id,
    String? creatorName,
    String? username,
    String? niche,
    String? category,
    String? targetAudience,
    List<String>? preferredPlatforms,
    String? primaryLanguage,
    String? secondaryLanguage,
    String? tone,
    List<String>? contentGoals,
    String? contentStyle,
    String? brandDescription,
    String? preferredCTAStyle,
    String? emojiUsage,
    Color? primaryColor,
    Color? secondaryColor,
    String? logoUrl,
    String? websiteUrl,
    String? instagramHandle,
    String? youtubeHandle,
    LanguageProfile? languageProfile,
    CreatorMemory? creatorMemory,
    BrandDNA? brandDNA,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreatorProfile(
      id: id ?? this.id,
      creatorName: creatorName ?? this.creatorName,
      username: username ?? this.username,
      niche: niche ?? this.niche,
      category: category ?? this.category,
      targetAudience: targetAudience ?? this.targetAudience,
      preferredPlatforms: preferredPlatforms ?? this.preferredPlatforms,
      primaryLanguage: primaryLanguage ?? this.primaryLanguage,
      secondaryLanguage: secondaryLanguage ?? this.secondaryLanguage,
      tone: tone ?? this.tone,
      contentGoals: contentGoals ?? this.contentGoals,
      contentStyle: contentStyle ?? this.contentStyle,
      brandDescription: brandDescription ?? this.brandDescription,
      preferredCTAStyle: preferredCTAStyle ?? this.preferredCTAStyle,
      emojiUsage: emojiUsage ?? this.emojiUsage,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      logoUrl: logoUrl ?? this.logoUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      youtubeHandle: youtubeHandle ?? this.youtubeHandle,
      languageProfile: languageProfile ?? this.languageProfile,
      creatorMemory: creatorMemory ?? this.creatorMemory,
      brandDNA: brandDNA ?? this.brandDNA,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorName': creatorName,
      'username': username,
      'niche': niche,
      'category': category,
      'targetAudience': targetAudience,
      'preferredPlatforms': preferredPlatforms,
      'primaryLanguage': primaryLanguage,
      'secondaryLanguage': secondaryLanguage,
      'tone': tone,
      'contentGoals': contentGoals,
      'contentStyle': contentStyle,
      'brandDescription': brandDescription,
      'preferredCTAStyle': preferredCTAStyle,
      'emojiUsage': emojiUsage,
      'primaryColor': primaryColor.toARGB32(),
      'secondaryColor': secondaryColor.toARGB32(),
      'logoUrl': logoUrl,
      'websiteUrl': websiteUrl,
      'instagramHandle': instagramHandle,
      'youtubeHandle': youtubeHandle,
      'languageProfile': languageProfile.toJson(),
      'creatorMemory': creatorMemory.toJson(),
      'brandDNA': brandDNA.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CreatorProfile.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime(2026, 1, 1)
        : DateTime(2026, 1, 1);

    final updated = json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'] as String) ?? created
        : created;

    return CreatorProfile(
      id: json['id'] as String? ?? 'default_creator_profile',
      creatorName: json['creatorName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      niche: json['niche'] as String? ?? 'Technology',
      category: json['category'] as String? ?? 'Content Creator',
      targetAudience: json['targetAudience'] as String? ?? 'Creators and small businesses',
      preferredPlatforms: (json['preferredPlatforms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['preferred_platforms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Instagram', 'YouTube', 'LinkedIn'],
      primaryLanguage: json['primaryLanguage'] as String? ?? 'English',
      secondaryLanguage: json['secondaryLanguage'] as String? ?? '',
      tone: json['tone'] as String? ?? 'Educational',
      contentGoals: (json['contentGoals'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['content_goals'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Audience Growth', 'Community Engagement'],
      contentStyle: json['contentStyle'] as String? ?? 'Actionable and inspiring',
      brandDescription: json['brandDescription'] as String? ?? '',
      preferredCTAStyle: json['preferredCTAStyle'] as String? ?? 'Direct',
      emojiUsage: json['emojiUsage'] as String? ?? 'moderate',
      primaryColor: json['primaryColor'] != null
          ? Color(json['primaryColor'] as int)
          : const Color(0xFF4F43F9),
      secondaryColor: json['secondaryColor'] != null
          ? Color(json['secondaryColor'] as int)
          : const Color(0xFF7066FF),
      logoUrl: json['logoUrl'] as String? ?? '',
      websiteUrl: json['websiteUrl'] as String? ?? '',
      instagramHandle: json['instagramHandle'] as String? ?? '',
      youtubeHandle: json['youtubeHandle'] as String? ?? '',
      languageProfile: json['languageProfile'] is Map<String, dynamic> ? LanguageProfile.fromJson(json['languageProfile'] as Map<String, dynamic>) : LanguageProfile(language: json['primaryLanguage'] as String? ?? 'English'),
      creatorMemory: json['creatorMemory'] is Map<String, dynamic> ? CreatorMemory.fromJson(json['creatorMemory'] as Map<String, dynamic>) : const CreatorMemory(),
      brandDNA: json['brandDNA'] is Map<String, dynamic> ? BrandDNA.fromJson(json['brandDNA'] as Map<String, dynamic>) : const BrandDNA(),
      createdAt: created,
      updatedAt: updated,
    );
  }
}

class _DefaultDateTime implements DateTime {
  const _DefaultDateTime();

  DateTime get _d => DateTime(2026, 1, 1);

  @override
  dynamic noSuchMethod(Invocation invocation) => invocation.memberName == #toIso8601String
      ? '2026-01-01T00:00:00.000'
      : _d;
}
