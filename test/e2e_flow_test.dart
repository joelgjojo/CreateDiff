import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creatediff/models/creator_profile.dart';
import 'package:creatediff/services/ai_service.dart';
import 'package:creatediff/services/storage_service.dart';
import 'package:creatediff/services/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreateDiff V2 End-to-End Core Workflow Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AppState.instance.init();
    });

    test('1. Brand Memory & Zero-Prompt Engine generates personalized content', () async {
      const profile = CreatorProfile(
        creatorName: 'Joel G Jojo',
        username: '@joelgjojo',
        niche: 'Technology',
        targetAudience: 'College students and creators',
        tone: 'Educational',
        primaryLanguage: 'Manglish',
        emojiUsage: 'moderate',
        preferredCTAStyle: 'Question',
      );

      final prompt = AIService.buildPrompt(
        platform: 'Instagram',
        contentType: 'Reel',
        idea: '5 AI Tools every student should know',
        niche: profile.niche,
        audience: profile.targetAudience,
        tone: profile.tone,
        language: profile.primaryLanguage,
        ctaStyle: profile.preferredCTAStyle,
        emojiUsage: profile.emojiUsage,
      );

      expect(prompt, contains('=== CREATOR CONTEXT ==='));
      expect(prompt, contains('Niche: Technology'));
      expect(prompt, contains('Language: Manglish'));

      final content = await AIService.generateContent(
        platform: 'Instagram',
        contentType: 'Reel',
        idea: '5 AI Tools every student should know',
        profile: profile,
      );

      expect(content.hooks.length, equals(5));
      expect(content.hooks.first, contains('Ithu arinjaal'));
      expect(content.caption, contains('Njan'));
      expect(content.caption, contains('✅'));
      expect(content.ctas.isNotEmpty, isTrue);
      expect(content.hashtagsHighReach.isNotEmpty, isTrue);
      expect(content.coverText.isNotEmpty, isTrue);
    });

    test('2. Complete end-to-end flow state transitions with design, duplicate, delete, and theme', () async {
      final appState = AppState.instance;

      // User onboards & sets up profile
      await appState.completeOnboarding();
      expect(appState.hasCompletedOnboarding, isTrue);

      const profile = CreatorProfile(
        creatorName: 'Tech Explorer',
        username: '@techexplorer',
        niche: 'Technology',
        tone: 'Bold',
        primaryLanguage: 'English',
      );
      await appState.updateProfile(profile);
      expect(appState.hasCompletedProfileSetup, isTrue);
      expect(appState.profile.creatorName, equals('Tech Explorer'));

      // User creates a content pack
      final project = await appState.generateContentPack(
        platform: 'Instagram',
        contentType: 'Reel',
        idea: 'Top 3 productivity systems',
      );

      expect(project, isNotNull);
      expect(appState.currentProject, isNotNull);
      expect(appState.contentHistory.length, equals(1));
      expect(appState.contentHistory.first.idea, equals('Top 3 productivity systems'));

      // User selects a visual design direction
      await appState.updateCurrentProjectDesign(
        templateName: 'Clean Editorial',
        style: 'editorial',
      );

      expect(appState.currentProject?.selectedDesignTemplate, equals('Clean Editorial'));
      expect(appState.contentHistory.first.selectedDesignTemplate, equals('Clean Editorial'));

      // User duplicates content pack in history
      final duplicated = await appState.duplicateProject(project!);
      expect(appState.contentHistory.length, equals(2));
      expect(duplicated.id, isNot(equals(project.id)));

      // User deletes the duplicated content pack
      await appState.deleteProject(duplicated.id);
      expect(appState.contentHistory.length, equals(1));

      // Theme toggle test
      await appState.setThemeMode(ThemeMode.dark);
      expect(appState.themeMode, equals(ThemeMode.dark));
      expect(StorageService.getThemeMode(), equals('dark'));

      // User checks history persistence
      final savedHistory = StorageService.getContentHistory();
      expect(savedHistory.length, equals(1));
      expect(savedHistory.first.id, equals(project.id));
    });
  });
}
