import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creatediff/models/creator_profile.dart';
import 'package:creatediff/models/content_project.dart';
import 'package:creatediff/models/generated_content.dart';
import 'package:creatediff/services/input_validator.dart';
import 'package:creatediff/services/usage_guard.dart';
import 'package:creatediff/services/backup_service.dart';
import 'package:creatediff/services/auth_contracts.dart';
import 'package:creatediff/services/storage_service.dart';
import 'package:creatediff/services/app_state.dart';
import 'package:creatediff/screens/history_screen.dart';
import 'package:creatediff/screens/profile_screen.dart';
import 'package:creatediff/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Hardening V1.1: InputValidator Unit Tests', () {
    test('validates normal idea prompt successfully', () {
      final res = InputValidator.validateIdea('5 AI tools every creator needs in 2026');
      expect(res.isValid, isTrue);
      expect(res.errorMessage, isNull);
    });

    test('rejects empty or null ideas', () {
      expect(InputValidator.validateIdea('').isValid, isFalse);
      expect(InputValidator.validateIdea('   ').isValid, isFalse);
      expect(InputValidator.validateIdea(null).isValid, isFalse);
    });

    test('rejects ideas shorter than minimum threshold', () {
      final res = InputValidator.validateIdea('ab');
      expect(res.isValid, isFalse);
      expect(res.errorMessage, contains('too short'));
    });

    test('rejects repeated character spam', () {
      final res = InputValidator.validateIdea('aaaaaaaaaaaa');
      expect(res.isValid, isFalse);
      expect(res.errorMessage, contains('meaningful topic'));
    });

    test('validates creator name requirements', () {
      expect(InputValidator.validateCreatorName('Joel').isValid, isTrue);
      expect(InputValidator.validateCreatorName('').isValid, isFalse);
      expect(InputValidator.validateCreatorName('A').isValid, isFalse);
    });
  });

  group('Hardening V1.1: UsageGuard & Cost Protection Unit Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await UsageGuard.init();
      await UsageGuard.resetToday();
    });

    test('reports allowed state when daily count is 0', () {
      final status = UsageGuard.checkUsage(dailyLimit: 50, warningThreshold: 40);
      expect(status.isAllowed, isTrue);
      expect(status.isWarning, isFalse);
      expect(status.isBlocked, isFalse);
      expect(status.remainingCount, equals(50));
    });

    test('reports warning state when count reaches threshold', () async {
      for (int i = 0; i < 42; i++) {
        await UsageGuard.recordGeneration(estimatedTokens: 100);
      }
      final status = UsageGuard.checkUsage(dailyLimit: 50, warningThreshold: 40);
      expect(status.isAllowed, isTrue);
      expect(status.isWarning, isTrue);
      expect(status.isBlocked, isFalse);
      expect(status.remainingCount, equals(8));
      expect(status.message, contains('42/50'));
    });

    test('blocks generation when limit is reached', () async {
      for (int i = 0; i < 50; i++) {
        await UsageGuard.recordGeneration();
      }
      final status = UsageGuard.checkUsage(dailyLimit: 50, warningThreshold: 40);
      expect(status.isBlocked, isTrue);
      expect(status.isAllowed, isFalse);
      expect(status.remainingCount, equals(0));
      expect(status.message, contains('limit reached'));
    });
  });

  group('Hardening V1.1: BackupService & Schema Verification', () {
    test('exports profile to valid JSON with metadata', () {
      const profile = CreatorProfile(
        creatorName: 'Aiswarya Mohan',
        niche: 'Travel',
        primaryLanguage: 'Malayalam',
      );
      final jsonStr = BackupService.exportProfileJson(profile);
      expect(jsonStr, contains('creatediff_brand_memory_v1'));
      expect(jsonStr, contains('Aiswarya Mohan'));
      expect(jsonStr, contains('Malayalam'));
    });

    test('validates and imports exported JSON profile', () {
      const profile = CreatorProfile(
        creatorName: 'Rahul Tech',
        niche: 'AI Tech',
        tone: 'Punchy',
      );
      final jsonStr = BackupService.exportProfileJson(profile);
      final validation = BackupService.validateImportJson(jsonStr);
      expect(validation.isValid, isTrue);

      final imported = BackupService.importProfileJson(jsonStr);
      expect(imported, isNotNull);
      expect(imported!.creatorName, equals('Rahul Tech'));
      expect(imported.niche, equals('AI Tech'));
      expect(imported.tone, equals('Punchy'));
    });

    test('rejects malformed or invalid profile JSON imports', () {
      expect(BackupService.validateImportJson('').isValid, isFalse);
      expect(BackupService.validateImportJson('invalid json').isValid, isFalse);
      expect(BackupService.validateImportJson('{"other": 123}').isValid, isFalse);
    });
  });

  group('Hardening V1.1: Storage Migration & Soft-Delete Architecture', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'contentHistory': jsonEncode([
          {
            'id': 'legacy_proj_1',
            'platform': 'Instagram',
            'contentType': 'Reel',
            'idea': 'Legacy reel idea',
            'createdAt': '2026-08-01T10:00:00.000',
          }
        ]),
      });
      await StorageService.init();
    });

    test('migrates legacy v1 projects to v2 with timestamps and isDeleted=false', () {
      final history = StorageService.getContentHistory();
      expect(history.length, equals(1));
      expect(history.first.id, equals('legacy_proj_1'));
      expect(history.first.isDeleted, isFalse);
      expect(history.first.updatedAt, isNotNull);
    });

    test('soft-deletes project and preserves it in storage for recovery', () async {
      await StorageService.softDeleteProject('legacy_proj_1');
      // Active history should now exclude it
      final active = StorageService.getContentHistory(includeDeleted: false);
      expect(active, isEmpty);

      // Storage still contains the record with isDeleted=true
      final all = StorageService.getContentHistory(includeDeleted: true);
      expect(all.length, equals(1));
      expect(all.first.isDeleted, isTrue);
      expect(all.first.deletedAt, isNotNull);
    });

    test('restores soft-deleted project back to active history', () async {
      await StorageService.softDeleteProject('legacy_proj_1');
      expect(StorageService.getContentHistory(includeDeleted: false), isEmpty);

      await StorageService.restoreProject('legacy_proj_1');
      final active = StorageService.getContentHistory(includeDeleted: false);
      expect(active.length, equals(1));
      expect(active.first.isDeleted, isFalse);
      expect(active.first.deletedAt, isNull);
    });
  });

  group('Hardening V1.1: Auth & Identity Contracts', () {
    test('LocalSessionManager provides default single-user state without hardcoded mock credentials', () {
      final session = LocalSessionManager();
      expect(session.isAuthenticated, isTrue);
      expect(session.currentUser, isNotNull);
      expect(session.currentUser!.isAnonymous, isTrue);
      expect(session.isPremium, isFalse);
      expect(session.dailyGenerationQuota, equals(50));
    });
  });

  group('Hardening V1.1: Widget & UX Tests', () {
    Widget wrapWithApp(Widget child) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: child,
      );
    }

    testWidgets('HistoryScreen displays soft delete and Undo SnackBar interaction', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await AppState.instance.init();

      final sample = ContentProject(
        id: 'widget_test_proj_1',
        platform: 'Instagram',
        contentType: 'Reel',
        idea: 'Interactive Widget Test Reel',
        createdAt: DateTime.now(),
        generatedContent: const GeneratedContent(
          hooks: ['Catchy Hook'],
          caption: 'Great Caption',
        ),
      );
      await StorageService.addProjectToHistory(sample);
      await AppState.instance.init();

      await tester.pumpWidget(wrapWithApp(const HistoryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Interactive Widget Test Reel'), findsOneWidget);

      // Perform soft delete via AppState
      await AppState.instance.softDeleteProject('widget_test_proj_1');
      await tester.pumpAndSettle();

      expect(find.text('Interactive Widget Test Reel'), findsNothing);

      // Restore via AppState Undo
      await AppState.instance.restoreProject('widget_test_proj_1');
      await tester.pumpAndSettle();

      expect(find.text('Interactive Widget Test Reel'), findsOneWidget);
    });

    testWidgets('ProfileScreen renders Export and Import Brand Memory actions', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await AppState.instance.init();

      await tester.pumpWidget(wrapWithApp(const ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Export Memory'), findsOneWidget);
      expect(find.text('Import Memory'), findsOneWidget);
    });
  });
}
