import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'session_token_store.dart';

class ContentFeedbackItem {
  final String contentId;
  final String platform;
  final String contentType;
  final String feedback; // 'worked' or 'did_not_work'
  final String? notes;
  final DateTime createdAt;

  const ContentFeedbackItem({
    required this.contentId,
    required this.platform,
    required this.contentType,
    required this.feedback,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'contentId': contentId,
        'platform': platform,
        'contentType': contentType,
        'feedback': feedback,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ContentFeedbackItem.fromJson(Map<String, dynamic> json) => ContentFeedbackItem(
        contentId: json['contentId'] as String? ?? '',
        platform: json['platform'] as String? ?? 'Instagram',
        contentType: json['contentType'] as String? ?? 'Reel',
        feedback: json['feedback'] as String? ?? 'worked',
        notes: json['notes'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

/// Performance Intelligence Service: manages content performance feedback,
/// local learning store, and continuous model improvement telemetry.
class PerformanceIntelligenceService {
  PerformanceIntelligenceService._();

  static const String _storageKey = 'creatediff_performance_feedback_v1';
  static HttpClient _createClient() => HttpClient()..connectionTimeout = const Duration(seconds: 10);
  static String get _backendBaseUrl => AppConfig.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');

  /// Records content feedback in local persistence and synchronizes with backend.
  static Future<void> recordFeedback({
    required String contentId,
    required String platform,
    required String contentType,
    required String feedback, // 'worked' or 'did_not_work'
    String? notes,
  }) async {
    final item = ContentFeedbackItem(
      contentId: contentId,
      platform: platform,
      contentType: contentType,
      feedback: feedback,
      notes: notes,
      createdAt: DateTime.now(),
    );

    // 1. Save locally
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_storageKey) ?? [];
      rawList.add(jsonEncode(item.toJson()));
      await prefs.setStringList(_storageKey, rawList);
    } catch (e) {
      if (kDebugMode) debugPrint('[PerformanceIntelligenceService] Local store warning: $e');
    }

    // 2. Sync with backend API
    final endpoint = '$_backendBaseUrl/api/v1/feedback';
    final client = _createClient();

    try {
      final uri = Uri.parse(endpoint);
      final request = await client.postUrl(uri);

      final token = SessionTokenStore.accessToken;
      if (token != null && token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');

      final payload = {
        'contentId': contentId,
        'platform': platform,
        'contentType': contentType,
        'feedback': feedback,
        'notes': notes,
      };

      request.add(utf8.encode(jsonEncode(payload)));
      await request.close().timeout(const Duration(seconds: 5));
    } catch (e) {
      if (kDebugMode) debugPrint('[PerformanceIntelligenceService] Backend sync notice: $e');
    } finally {
      client.close();
    }
  }

  /// Retrieves all recorded feedback items.
  static Future<List<ContentFeedbackItem>> getAllFeedback() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_storageKey) ?? [];
      return rawList.map((str) => ContentFeedbackItem.fromJson(jsonDecode(str) as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Whether creator has existing performance feedback signals.
  static Future<bool> hasPerformanceHistory() async {
    final list = await getAllFeedback();
    return list.isNotEmpty;
  }
}
