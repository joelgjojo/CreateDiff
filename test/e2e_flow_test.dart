import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creatediff/models/creator_profile.dart';
import 'package:creatediff/models/content_project.dart';
import 'package:creatediff/models/generated_content.dart';
import 'package:creatediff/services/ai_service.dart';
import 'package:creatediff/services/ai_config.dart';
import 'package:creatediff/services/storage_service.dart';
import 'package:creatediff/services/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreateDiff Master Brand & Grok AI Observability Tests', () {
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

    test('2. Grok AI strict error observability when API key is missing', () async {
      // Ensure key is empty
      AIConfig.setConfig(apiKey: '', model: 'grok-4.5', baseUrl: 'https://api.x.ai/v1');

      const profile = CreatorProfile(
        creatorName: 'Joel G Jojo',
        niche: 'Technology',
      );

      expect(
        () => AIService.generateContent(
          platform: 'Instagram',
          contentType: 'Reel',
          idea: '5 AI Tools',
          profile: profile,
        ),
        throwsA(isA<AIServiceException>().having(
          (e) => e.status,
          'status',
          equals(AIGenerationStatus.missingApiKey),
        )),
      );

      // Verify Debug Log telemetry is populated
      final log = AIService.lastDebugLog;
      expect(log, isNotNull);
      expect(log!.status, equals(AIGenerationStatus.missingApiKey));
      expect(log.provider, equals('xAI Grok'));
    });

    test('3. Grok AI Configuration & Runtime Overrides', () {
      AIConfig.setConfig(
        apiKey: 'test_grok_key_12345',
        model: 'grok-4.5',
        baseUrl: 'https://api.x.ai/v1',
      );

      expect(AIConfig.apiKey, equals('test_grok_key_12345'));
      expect(AIConfig.model, equals('grok-4.5'));
      expect(AIConfig.baseUrl, equals('https://api.x.ai/v1'));
      expect(AIConfig.hasApiKey, isTrue);

      // Clean up test config
      AIConfig.setConfig(apiKey: '', model: 'grok-4.5', baseUrl: 'https://api.x.ai/v1');
    });

    test('4. Complete reset flow restarts state and clears persistence cleanly', () async {
      final appState = AppState.instance;

      // Setup state
      await appState.completeOnboarding();
      await appState.updateProfile(const CreatorProfile(creatorName: 'Test Creator'));

      final sampleProject = ContentProject(
        id: 'project_1',
        platform: 'Instagram',
        contentType: 'Reel',
        idea: 'Sample Idea',
        createdAt: DateTime.now(),
        status: 'generated',
        generatedContent: const GeneratedContent(
          hooks: ['Hook 1'],
          caption: 'Caption 1',
          ctas: ['CTA 1'],
          hashtagsHighReach: ['#tag1'],
          hashtagsMediumReach: [],
          hashtagsNiche: [],
          coverText: 'TITLE',
          variations: [],
        ),
        language: 'English',
        tone: 'Educational',
      );

      await StorageService.addProjectToHistory(sampleProject);
      appState.setCurrentProject(sampleProject);

      expect(appState.hasCompletedOnboarding, isTrue);
      expect(appState.hasCompletedProfileSetup, isTrue);
      expect(appState.currentProject, isNotNull);

      // Perform Complete Reset
      await appState.resetAll();

      expect(appState.hasCompletedOnboarding, isFalse);
      expect(appState.hasCompletedProfileSetup, isFalse);
      expect(appState.currentProject, isNull);
      expect(appState.contentHistory.isEmpty, isTrue);
      expect(appState.profile.creatorName.isEmpty, isTrue);
      expect(StorageService.getContentHistory().isEmpty, isTrue);
    });

    test('5. Project history manipulation (add, design, duplicate, delete, theme)', () async {
      final appState = AppState.instance;

      final sampleProject = ContentProject(
        id: 'proj_100',
        platform: 'LinkedIn',
        contentType: 'Post',
        idea: 'Engineering Leadership',
        createdAt: DateTime.now(),
        status: 'generated',
        generatedContent: const GeneratedContent(
          hooks: ['Leadership Hook'],
          caption: 'Leadership Caption',
          ctas: ['Follow for more'],
          hashtagsHighReach: ['#leadership'],
          hashtagsMediumReach: [],
          hashtagsNiche: [],
          coverText: 'LEADERSHIP',
          variations: [],
        ),
        language: 'English',
        tone: 'Professional',
      );

      await StorageService.addProjectToHistory(sampleProject);
      appState.setCurrentProject(sampleProject);

      // Design selection
      await appState.updateCurrentProjectDesign(
        templateName: 'Modern Studio',
        style: 'dark_editorial',
      );
      expect(appState.currentProject?.selectedDesignTemplate, equals('Modern Studio'));

      // Duplicate
      final dup = await appState.duplicateProject(sampleProject);
      expect(appState.contentHistory.length, equals(2));

      // Delete
      await appState.deleteProject(dup.id);
      expect(appState.contentHistory.length, equals(1));

      // Theme toggle
      await appState.setThemeMode(ThemeMode.dark);
      expect(appState.themeMode, equals(ThemeMode.dark));
    });
  });
}
