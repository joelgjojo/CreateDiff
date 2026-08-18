class CampaignDayItem {
  final int day;
  final String title;
  final String topic;
  final String platform;
  final String contentType;
  final String hookAngle;
  final String outline;
  final String strategicIntent;
  final bool isCreated;

  const CampaignDayItem({
    required this.day,
    required this.title,
    required this.topic,
    this.platform = 'Instagram',
    this.contentType = 'Reel',
    this.hookAngle = '',
    this.outline = '',
    this.strategicIntent = 'Audience Growth',
    this.isCreated = false,
  });

  CampaignDayItem copyWith({
    int? day,
    String? title,
    String? topic,
    String? platform,
    String? contentType,
    String? hookAngle,
    String? outline,
    String? strategicIntent,
    bool? isCreated,
  }) {
    return CampaignDayItem(
      day: day ?? this.day,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      platform: platform ?? this.platform,
      contentType: contentType ?? this.contentType,
      hookAngle: hookAngle ?? this.hookAngle,
      outline: outline ?? this.outline,
      strategicIntent: strategicIntent ?? this.strategicIntent,
      isCreated: isCreated ?? this.isCreated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'title': title,
      'topic': topic,
      'platform': platform,
      'contentType': contentType,
      'hookAngle': hookAngle,
      'outline': outline,
      'strategicIntent': strategicIntent,
      'isCreated': isCreated,
    };
  }

  factory CampaignDayItem.fromJson(Map<String, dynamic> json) {
    return CampaignDayItem(
      day: (json['day'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? 'Content Topic',
      topic: json['topic'] as String? ?? '',
      platform: json['platform'] as String? ?? 'Instagram',
      contentType: json['contentType'] as String? ??
          json['content_type'] as String? ??
          'Reel',
      hookAngle: json['hookAngle'] as String? ??
          json['hook_angle'] as String? ??
          '',
      outline: json['outline'] as String? ?? '',
      strategicIntent: json['strategicIntent'] as String? ??
          json['strategic_intent'] as String? ??
          'Audience Growth',
      isCreated: json['isCreated'] as bool? ?? false,
    );
  }
}

class CampaignPlan {
  final String id;
  final String campaignTitle;
  final String campaignGoal;
  final int durationDays;
  final String platform;
  final String strategySummary;
  final List<CampaignDayItem> days;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CampaignPlan({
    required this.id,
    required this.campaignTitle,
    required this.campaignGoal,
    required this.durationDays,
    this.platform = 'All',
    this.strategySummary = '',
    required this.days,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  CampaignPlan copyWith({
    String? id,
    String? campaignTitle,
    String? campaignGoal,
    int? durationDays,
    String? platform,
    String? strategySummary,
    List<CampaignDayItem>? days,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CampaignPlan(
      id: id ?? this.id,
      campaignTitle: campaignTitle ?? this.campaignTitle,
      campaignGoal: campaignGoal ?? this.campaignGoal,
      durationDays: durationDays ?? this.durationDays,
      platform: platform ?? this.platform,
      strategySummary: strategySummary ?? this.strategySummary,
      days: days ?? this.days,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaignTitle': campaignTitle,
      'campaignGoal': campaignGoal,
      'durationDays': durationDays,
      'platform': platform,
      'strategySummary': strategySummary,
      'days': days.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CampaignPlan.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now();
    final updated = json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'] as String) ?? created
        : created;

    return CampaignPlan(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      campaignTitle: json['campaignTitle'] as String? ??
          json['campaign_title'] as String? ??
          'Content Campaign',
      campaignGoal: json['campaignGoal'] as String? ??
          json['campaign_goal'] as String? ??
          '',
      durationDays: (json['durationDays'] as num?)?.toInt() ??
          (json['duration_days'] as num?)?.toInt() ??
          7,
      platform: json['platform'] as String? ?? 'All',
      strategySummary: json['strategySummary'] as String? ??
          json['strategy_summary'] as String? ??
          '',
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => CampaignDayItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: created,
      updatedAt: updated,
    );
  }
}
