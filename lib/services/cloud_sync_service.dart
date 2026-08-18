import 'dart:convert';
import 'dart:io';
import '../config/app_config.dart';
import '../models/creator_profile.dart';
import 'session_token_store.dart';
import 'storage_service.dart';

/// One-way first sync boundary: local schema v3 remains the source of truth
/// offline; after authentication this uploads the current brand memory.
class CloudSyncService {
  CloudSyncService._();

  static Future<bool> syncCreatorProfile(CreatorProfile profile) async {
    return syncLocalData(profile);
  }

  static Future<bool> syncLocalData(CreatorProfile profile) async {
    final token = SessionTokenStore.accessToken;
    final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    if (token == null || token.isEmpty || base.isEmpty) return false;
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.postUrl(Uri.parse('$base/api/v1/profile/sync'));
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.add(utf8.encode(jsonEncode({
        'profile': profile.toJson(),
        'contentProjects': StorageService.getContentHistory(includeDeleted: true).map((e) => e.toJson()).toList(),
        'campaigns': StorageService.getCampaigns().map((e) => e.toJson()).toList(),
      })));
      final response = await request.close().timeout(const Duration(seconds: 15));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }
}
