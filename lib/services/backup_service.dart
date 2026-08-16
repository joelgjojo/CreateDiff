import 'dart:convert';
import '../models/creator_profile.dart';
import 'input_validator.dart';

/// Backup, Export, and Import service for Creator Memory profiles
class BackupService {
  BackupService._();

  /// Exports creator profile to pretty-printed JSON format
  static String exportProfileJson(CreatorProfile profile) {
    const encoder = JsonEncoder.withIndent('  ');
    final map = {
      'schema': 'creatediff_brand_memory_v1',
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': profile.toJson(),
    };
    return encoder.convert(map);
  }

  /// Validates imported JSON string before applying
  static ValidationResult validateImportJson(String? rawJson) {
    if (rawJson == null || rawJson.trim().isEmpty) {
      return const ValidationResult.invalid('Import content is empty.');
    }

    try {
      final decoded = jsonDecode(rawJson.trim());
      if (decoded is! Map<String, dynamic>) {
        return const ValidationResult.invalid('Invalid JSON format: root must be an object.');
      }

      final profileMap = decoded['profile'] ?? decoded;
      if (profileMap is! Map<String, dynamic>) {
        return const ValidationResult.invalid('Missing profile data in JSON.');
      }

      final name = profileMap['creatorName']?.toString().trim() ?? '';
      if (name.isEmpty) {
        return const ValidationResult.invalid('Imported profile has no creator name.');
      }

      return const ValidationResult.valid();
    } catch (e) {
      return ValidationResult.invalid('Invalid JSON syntax: ${e.toString()}');
    }
  }

  /// Parses JSON string into a validated CreatorProfile
  static CreatorProfile? importProfileJson(String rawJson) {
    final validation = validateImportJson(rawJson);
    if (!validation.isValid) return null;

    try {
      final decoded = jsonDecode(rawJson.trim()) as Map<String, dynamic>;
      final profileMap = decoded['profile'] != null
          ? decoded['profile'] as Map<String, dynamic>
          : decoded;

      return CreatorProfile.fromJson(profileMap);
    } catch (_) {
      return null;
    }
  }
}
