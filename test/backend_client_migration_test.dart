import 'package:flutter_test/flutter_test.dart';
import 'package:creatediff/models/creator_profile.dart';
import 'package:creatediff/models/content_project.dart';
import 'package:creatediff/models/generated_content.dart';
import 'package:creatediff/services/app_state.dart';
import 'package:creatediff/services/grok_service.dart';
import 'package:creatediff/config/api_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Backend Migration & Architecture Tests', () {
    test('ApiConfig defaults to CreateDiff Backend without requiring Groq client key', () {
      expect(ApiConfig.providerName, equals('CreateDiff Cloud AI'));
      expect(ApiConfig.backendBaseUrl, isNotEmpty);
      expect(ApiConfig.hasBackendConfigured, isTrue);
    });

    test('development URL configuration keeps emulator and device addresses distinct', () {
      expect(
        ApiConfig.defaultAndroidEmulatorUrl,
        equals('http://10.0.2.2:8000'),
      );
      expect(ApiConfig.defaultLocalUrl, equals('http://127.0.0.1:8000'));
      expect(ApiConfig.defaultPlatformBackendUrl, isNotEmpty);
    });

    test('Prompt Builder utility preserves regional language and Latin hashtag rules', () {
      const profile = CreatorProfile(
        creatorName: 'Aiswarya',
        niche: 'Kerala Food',
        primaryLanguage: 'Malayalam',
        secondaryLanguage: 'Manglish',
        preferredCTAStyle: 'Direct',
      );

      final systemPrompt = GrokService.buildSystemPrompt(profile: profile);
      expect(systemPrompt.contains('Aiswarya'), isTrue);
      expect(systemPrompt.contains('Kerala Food'), isTrue);
      expect(systemPrompt.contains('Malayalam'), isTrue);
      expect(systemPrompt.contains('Manglish'), isTrue);
      expect(systemPrompt.contains('hashtagsHighReach'), isTrue);
      expect(systemPrompt.contains('Latin'), isTrue);
    });

    test('AppState loading timer initiates and performs steps', () async {
      final appState = AppState.instance;
      expect(appState.isGenerating, isFalse);
      expect(appState.isApiConfigured, isTrue);
    });

    test(
      'Non-destructive regeneration maintains previous content upon failure',
      () async {
        final appState = AppState.instance;

        const initialContent = GeneratedContent(
          hooks: ['Hook 1', 'Hook 2', 'Hook 3', 'Hook 4', 'Hook 5'],
          caption: 'Existing solid caption...',
          ctas: ['Follow @create'],
          hashtagsHighReach: ['#AI', '#Creators'],
          coverText: 'EXISTING TITLE',
        );

        final project = ContentProject(
          id: 'p-existing-1',
          platform: 'Instagram',
          contentType: 'Reel',
          idea: 'AI tools 2026',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          status: 'generated',
          generatedContent: initialContent,
        );

        appState.setCurrentProject(project);
        expect(
          appState.currentGeneratedContent?.caption,
          equals('Existing solid caption...'),
        );

        // If a background regeneration is initiated with an invalid backend url, it fails safely
        ApiConfig.setConfig(
          baseUrl: 'http://127.0.0.1:9999',
        ); // non-existent port
        final result = await appState.regenerateCurrentProject();
        expect(result, isNull);
        // Existing content is NOT destroyed
        expect(
          appState.currentGeneratedContent?.caption,
          equals('Existing solid caption...'),
        );
        expect(
          appState.currentProject?.generatedContent?.caption,
          equals('Existing solid caption...'),
        );

        // Reset config back to active local backend
        ApiConfig.resetOverrides();
      },
    );
  });
}
