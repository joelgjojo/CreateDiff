import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/creator_profile.dart';
import '../models/content_project.dart';

class StorageService {
  static const String _keyCompletedOnboarding = 'hasCompletedOnboarding';
  static const String _keyCompletedProfileSetup = 'hasCompletedProfileSetup';
  static const String _keyCreatorProfile = 'currentCreatorProfile';
  static const String _keyContentHistory = 'contentHistory';
  static const String _keyThemeMode = 'selectedThemeMode';
  static const String _keyDefaultPlatform = 'defaultPlatform';
  static const String _keyDefaultTone = 'defaultTone';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // --- Onboarding & Setup Flags ---
  static bool get hasCompletedOnboarding =>
      _prefs?.getBool(_keyCompletedOnboarding) ?? false;

  static Future<void> setCompletedOnboarding(bool value) async {
    await _prefs?.setBool(_keyCompletedOnboarding, value);
  }

  static bool get hasCompletedProfileSetup =>
      _prefs?.getBool(_keyCompletedProfileSetup) ?? false;

  static Future<void> setCompletedProfileSetup(bool value) async {
    await _prefs?.setBool(_keyCompletedProfileSetup, value);
  }

  // --- Creator Profile ---
  static CreatorProfile? getCreatorProfile() {
    final raw = _prefs?.getString(_keyCreatorProfile);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CreatorProfile.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveCreatorProfile(CreatorProfile profile) async {
    final raw = jsonEncode(profile.toJson());
    await _prefs?.setString(_keyCreatorProfile, raw);
  }

  // --- Content History ---
  static List<ContentProject> getContentHistory() {
    final raw = _prefs?.getString(_keyContentHistory);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) => ContentProject.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveContentHistory(List<ContentProject> history) async {
    final raw = jsonEncode(history.map((e) => e.toJson()).toList());
    await _prefs?.setString(_keyContentHistory, raw);
  }

  static Future<void> addProjectToHistory(ContentProject project) async {
    final current = getContentHistory();
    // Remove if exists with same ID to update, then insert at top
    current.removeWhere((item) => item.id == project.id);
    current.insert(0, project);
    await saveContentHistory(current);
  }

  // --- Preferences ---
  static String getThemeMode() => _prefs?.getString(_keyThemeMode) ?? 'system';
  static Future<void> setThemeMode(String mode) async =>
      await _prefs?.setString(_keyThemeMode, mode);

  static String getDefaultPlatform() => _prefs?.getString(_keyDefaultPlatform) ?? 'Instagram';
  static Future<void> setDefaultPlatform(String platform) async =>
      await _prefs?.setString(_keyDefaultPlatform, platform);

  static String getDefaultTone() => _prefs?.getString(_keyDefaultTone) ?? 'Educational';
  static Future<void> setDefaultTone(String tone) async =>
      await _prefs?.setString(_keyDefaultTone, tone);

  // Clear all data (for testing/logout)
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
