import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creatediff/models/creator_profile.dart';
import 'package:creatediff/services/ai_service.dart';
import 'package:creatediff/services/ai_config.dart';
import 'package:creatediff/services/storage_service.dart';
import 'package:creatediff/services/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreateDiff V2 End-to-End Core Workflow & Grok AI Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AppState.instance.init();
    });

    test('1. Grok AI System Prompt Generation & Schema Formatting', () {
      const profile = CreatorProfile(
        creatorName: 'Joel G Jojo',
        username: '@joelgjojo',
        niche: 'Technology',
        targetAudience: 'College students and creators',
        tone: 'Educational',
        primaryLanguage: 'Manglish',
        secondaryLanguage: 'Malayalam',
        contentStyle: 'Short-form tips',
        brandDescription: 'AI creator studio tools',
        emojiUsage: 'moderate',
        preferredCTAStyle: 'Question',
      );

      final systemPrompt = AIService.buildSystemPrompt(profile: profile);

      expect(systemPrompt, contains('CreateDiff — a premium mobile creator and design studio'));
      expect(systemPrompt, contains('• Creator / Brand Name: Joel G Jojo'));
      expect(systemPrompt, contains('• Niche / Domain: Technology'));
      expect(systemPrompt, contains('• Target Audience: College students and creators'));
      expect(systemPrompt, contains('• Primary Language: Manglish'));
      expect(systemPrompt, contains('• Regional / Secondary Dialect: Malayalam'));
      expect(systemPrompt, contains('• Content Style: Short-form tips'));
      expect(systemPrompt, contains('• Preferred CTA Style: Question'));
      expect(systemPrompt, contains('REQUIRED JSON SCHEMA'));
      expect(systemPrompt, contains('"hooks"'));
      expect(systemPrompt, contains('"caption"'));
      expect(systemPrompt, contains('"ctas"'));
      expect(systemPrompt, contains('"hashtagsHighReach"'));
      expect(systemPrompt, contains('"coverText"'));

      final userPrompt = AIService.buildUserPrompt(
        platform: 'Instagram',
        contentType: 'Reel',
        idea: '5 AI tools for creators',
      );
      expect(userPrompt, contains('Platform: Instagram'));
      expect(userPrompt, contains('Format: Reel'));
      expect(userPrompt, contains('Idea / Topic: 5 AI tools for creators'));
    });

    test('2. Brand Memory & Content Engine generates personalized content', () async {
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

    test('3. Grok AI Configuration & Runtime Overrides', () {
      AIConfig.setConfig(
        apiKey: 'test_grok_key',
        model: 'grok-4.5',
        baseUrl: 'https://api.x.ai/v1',
      );

      expect(AIConfig.apiKey, equals('test_grok_key'));
      expect(AIConfig.model, equals('grok-4.5'));
      expect(AIConfig.baseUrl, equals('https://api.x.ai/v1'));
      expect(AIConfig.hasApiKey, isTrue);

      // Clean up test config
      AIConfig.setConfig(apiKey: '', model: 'grok-4.5', baseUrl: 'https://api.x.ai/v1');
    });

    test('4. Complete end-to-end flow state transitions with design, duplicate, delete, and theme', () async {
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
