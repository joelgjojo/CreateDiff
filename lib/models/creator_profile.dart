import 'package:flutter/material.dart';

class CreatorProfile {
  final String creatorName;
  final String username;
  final String niche;
  final String category;
  final String targetAudience;
  final String primaryLanguage;
  final String secondaryLanguage;
  final String tone;
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

  const CreatorProfile({
    this.creatorName = '',
    this.username = '',
    this.niche = 'Technology',
    this.category = 'Content Creator',
    this.targetAudience = 'Creators and small businesses',
    this.primaryLanguage = 'English',
    this.secondaryLanguage = '',
    this.tone = 'Educational',
    this.contentStyle = 'Actionable and inspiring',
    this.brandDescription = '',
    this.preferredCTAStyle = 'Direct',
    this.emojiUsage = 'moderate',
    this.primaryColor = const Color(0xFF6C5CE7),
    this.secondaryColor = const Color(0xFFA29BFE),
    this.logoUrl = '',
    this.websiteUrl = '',
    this.instagramHandle = '',
    this.youtubeHandle = '',
  });

  String get handle => username.isNotEmpty ? username : '@creator';

  CreatorProfile copyWith({
    String? creatorName,
    String? username,
    String? niche,
    String? category,
    String? targetAudience,
    String? primaryLanguage,
    String? secondaryLanguage,
    String? tone,
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
  }) {
    return CreatorProfile(
      creatorName: creatorName ?? this.creatorName,
      username: username ?? this.username,
      niche: niche ?? this.niche,
      category: category ?? this.category,
      targetAudience: targetAudience ?? this.targetAudience,
      primaryLanguage: primaryLanguage ?? this.primaryLanguage,
      secondaryLanguage: secondaryLanguage ?? this.secondaryLanguage,
      tone: tone ?? this.tone,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creatorName': creatorName,
      'username': username,
      'niche': niche,
      'category': category,
      'targetAudience': targetAudience,
      'primaryLanguage': primaryLanguage,
      'secondaryLanguage': secondaryLanguage,
      'tone': tone,
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
    };
  }

  factory CreatorProfile.fromJson(Map<String, dynamic> json) {
    return CreatorProfile(
      creatorName: json['creatorName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      niche: json['niche'] as String? ?? 'Technology',
      category: json['category'] as String? ?? 'Content Creator',
      targetAudience: json['targetAudience'] as String? ?? 'Creators and small businesses',
      primaryLanguage: json['primaryLanguage'] as String? ?? 'English',
      secondaryLanguage: json['secondaryLanguage'] as String? ?? '',
      tone: json['tone'] as String? ?? 'Educational',
      contentStyle: json['contentStyle'] as String? ?? 'Actionable and inspiring',
      brandDescription: json['brandDescription'] as String? ?? '',
      preferredCTAStyle: json['preferredCTAStyle'] as String? ?? 'Direct',
      emojiUsage: json['emojiUsage'] as String? ?? 'moderate',
      primaryColor: json['primaryColor'] != null
          ? Color(json['primaryColor'] as int)
          : const Color(0xFF6C5CE7),
      secondaryColor: json['secondaryColor'] != null
          ? Color(json['secondaryColor'] as int)
          : const Color(0xFFA29BFE),
      logoUrl: json['logoUrl'] as String? ?? '',
      websiteUrl: json['websiteUrl'] as String? ?? '',
      instagramHandle: json['instagramHandle'] as String? ?? '',
      youtubeHandle: json['youtubeHandle'] as String? ?? '',
    );
  }
}
