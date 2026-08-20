import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'session_token_store.dart';

/// Aggregate system telemetry and usage metrics for administrators.
class AdminStats {
  final int totalUsers;
  final int totalGenerations;
  final int totalCampaigns;
  final int failedGenerations;
  final String appVersion;
  final String backendStatus;

  const AdminStats({
    required this.totalUsers,
    required this.totalGenerations,
    required this.totalCampaigns,
    required this.failedGenerations,
    required this.appVersion,
    required this.backendStatus,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['total_users'] as int? ?? 0,
      totalGenerations: json['total_generations'] as int? ?? 0,
      totalCampaigns: json['total_campaigns'] as int? ?? 0,
      failedGenerations: json['failed_generations'] as int? ?? 0,
      appVersion: json['app_version'] as String? ?? '3.5.0',
      backendStatus: json['backend_status'] as String? ?? 'operational',
    );
  }
}

/// User overview item returned by admin management endpoint.
class AdminUserItem {
  final String id;
  final String? authSubject;
  final String? email;
  final String? displayName;
  final String role;
  final String plan;
  final DateTime? createdAt;

  const AdminUserItem({
    required this.id,
    this.authSubject,
    this.email,
    this.displayName,
    required this.role,
    required this.plan,
    this.createdAt,
  });

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    return AdminUserItem(
      id: json['id'] as String? ?? '',
      authSubject: json['auth_subject'] as String?,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      role: json['role'] as String? ?? 'user',
      plan: json['plan'] as String? ?? 'free',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}

/// Production service providing administrative insights via FastAPI `/api/v1/admin/*`.
class AdminService {
  AdminService._();

  static HttpClient _createClient() {
    return HttpClient()..connectionTimeout = const Duration(seconds: 15);
  }

  static String get _backendBaseUrl => AppConfig.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');

  /// Fetches system metrics and AI generation totals.
  static Future<AdminStats> fetchStats() async {
    final endpoint = '$_backendBaseUrl/api/v1/admin/stats';
    final client = _createClient();

    try {
      final uri = Uri.parse(endpoint);
      final request = await client.getUrl(uri);
      final token = SessionTokenStore.accessToken;
      if (token != null && token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');

      final response = await request.close().timeout(const Duration(seconds: 15));
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        return AdminStats.fromJson(data);
      } else if (response.statusCode == 401) {
        throw const HttpException('Unauthorized: Please sign in with an admin account.');
      } else if (response.statusCode == 403) {
        throw const HttpException('Forbidden: Administrator privileges required.');
      } else {
        throw HttpException('HTTP ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AdminService] fetchStats failed: $e');
      }
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Fetches the recent user accounts.
  static Future<List<AdminUserItem>> fetchUsers() async {
    final endpoint = '$_backendBaseUrl/api/v1/admin/users';
    final client = _createClient();

    try {
      final uri = Uri.parse(endpoint);
      final request = await client.getUrl(uri);
      final token = SessionTokenStore.accessToken;
      if (token != null && token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');

      final response = await request.close().timeout(const Duration(seconds: 15));
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        final list = (data['users'] as List<dynamic>?) ?? [];
        return list.map((item) => AdminUserItem.fromJson(item as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 401) {
        throw const HttpException('Unauthorized: Please sign in with an admin account.');
      } else if (response.statusCode == 403) {
        throw const HttpException('Forbidden: Administrator privileges required.');
      } else {
        throw HttpException('HTTP ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AdminService] fetchUsers failed: $e');
      }
      rethrow;
    } finally {
      client.close();
    }
  }
}
