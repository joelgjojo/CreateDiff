import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/creator_profile.dart';
import '../models/content_project.dart';
import '../theme/design_tokens.dart';

class StorageService {
  static const String _keyCompletedOnboarding = 'hasCompletedOnboarding';
  static const String _keyCompletedProfileSetup = 'hasCompletedProfileSetup';
  static const String _keyCreatorProfile = 'currentCreatorProfile';
  static const String _keyContentHistory = 'contentHistory';
  static const String _keyThemeMode = 'selectedThemeMode';

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
      return list
          .map(
              (item) => ContentProject.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveContentHistory(List<ContentProject> history) async {
    // Cap history to prevent unbounded SharedPreferences growth
    final capped = history.length > CDLimits.maxHistoryItems
        ? history.sublist(0, CDLimits.maxHistoryItems)
        : history;
    final raw = jsonEncode(capped.map((e) => e.toJson()).toList());
    await _prefs?.setString(_keyContentHistory, raw);
  }

  static Future<void> addProjectToHistory(ContentProject project) async {
    final current = getContentHistory();
    current.removeWhere((item) => item.id == project.id);
    current.insert(0, project);
    await saveContentHistory(current);
  }

  static Future<void> removeProjectFromHistory(String id) async {
    final current = getContentHistory();
    current.removeWhere((item) => item.id == id);
    await saveContentHistory(current);
  }

  // --- Preferences ---
  static String getThemeMode() =>
      _prefs?.getString(_keyThemeMode) ?? 'system';
  static Future<void> setThemeMode(String mode) async =>
      await _prefs?.setString(_keyThemeMode, mode);

  // Clear all data (for reset)
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
