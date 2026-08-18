import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores the short-lived Supabase access token locally. Refresh-token
/// management remains owned by the Supabase client/auth UI integration.
class SessionTokenStore {
  SessionTokenStore._();
  static const _key = 'creatediff_supabase_access_token';
  static SharedPreferences? _prefs;
  static FlutterSecureStorage? _secureStorage;
  static String? _accessToken;

  static Future<void> init([SharedPreferences? prefs]) async {
    if (prefs != null) {
      _prefs = prefs;
      _secureStorage = null;
      _accessToken = prefs.getString(_key);
      return;
    }
    _prefs = null;
    _secureStorage = const FlutterSecureStorage();
    _accessToken = await _secureStorage!.read(key: _key);
  }

  static String? get accessToken => _accessToken;

  static Future<void> setAccessToken(String? token) async {
    if (token == null || token.trim().isEmpty) {
      _accessToken = null;
      await _prefs?.remove(_key);
      await _secureStorage?.delete(key: _key);
    } else {
      _accessToken = token.trim();
      if (_prefs != null) {
        await _prefs!.setString(_key, _accessToken!);
      } else {
        await _secureStorage?.write(key: _key, value: _accessToken!);
      }
    }
  }
}
