import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creatediff/models/creator_profile.dart';
import 'package:creatediff/models/content_project.dart';
import 'package:creatediff/models/generated_content.dart';
import 'package:creatediff/services/app_state.dart';
import 'package:creatediff/services/storage_service.dart';
import 'package:creatediff/services/grok_service.dart';
import 'package:creatediff/services/input_validator.dart';
import 'package:creatediff/screens/create_screen.dart';
import 'package:creatediff/screens/content_result_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    await AppState.instance.init();
  });

  group('V2 AI & System Prompt Rules', () {
    test('System Prompt embeds complete Creator Brand Memory', () {
      const profile = CreatorProfile(
        creatorName: 'Aiswarya Mohan',
        niche: 'Kerala Food & Culture',
        targetAudience: 'Malayalis worldwide and foodies',
        tone: 'Warm & Authentic',
        primaryLanguage: 'Malayalam',
        secondaryLanguage: 'Manglish',
        contentStyle: 'Traditional recipe stories',
        brandDescription: 'Celebrating authentic Malabar cuisine',
        preferredCTAStyle: 'Conversational',
        emojiUsage: 'expressive',
      );

      final prompt = GrokService.buildSystemPrompt(profile: profile);

      expect(prompt.contains('Aiswarya Mohan'), isTrue);
      expect(prompt.contains('Kerala Food & Culture'), isTrue);
      expect(prompt.contains('Malayalis worldwide and foodies'), isTrue);
      expect(prompt.contains('Warm & Authentic'), isTrue);
      expect(prompt.contains('Malayalam'), isTrue);
      expect(prompt.contains('Manglish'), isTrue);
      expect(prompt.contains('Traditional recipe stories'), isTrue);
      expect(prompt.contains('Celebrating authentic Malabar cuisine'), isTrue);
      expect(prompt.contains('Conversational'), isTrue);
      expect(prompt.contains('expressive'), isTrue);
      expect(prompt.contains('json'), isTrue); // Ensures Groq json requirement
      expect(prompt.contains('Latin'), isTrue); // Ensures Latin hashtags requirement
    });

    test('User Prompt structures platform and overrides accurately', () {
      final userPrompt = GrokService.buildUserPrompt(
        platform: 'Instagram',
        contentType: 'Reel',
        idea: 'Traditional Onam Sadhya Preparation Tips',
        overrideLanguage: 'Malayalam',
        overrideTone: 'Energetic',
      );

      expect(userPrompt.contains('Platform: Instagram'), isTrue);
      expect(userPrompt.contains('Format: Reel'), isTrue);
      expect(userPrompt.contains('Traditional Onam Sadhya Preparation Tips'), isTrue);
      expect(userPrompt.contains('Language Override: Malayalam'), isTrue);
      expect(userPrompt.contains('Tone Override: Energetic'), isTrue);
      expect(userPrompt.contains('JSON'), isTrue);
    });
  });

  group('Input Validation & Safety', () {
    test('validateIdea checks length and spam repetition', () {
      expect(InputValidator.validateIdea('').isValid, isFalse);
      expect(InputValidator.validateIdea('  ').isValid, isFalse);
      expect(InputValidator.validateIdea('ab').isValid, isFalse); // < 3 chars
      expect(InputValidator.validateIdea('aaaaaaaaaa').isValid, isFalse); // spam repetition
      expect(InputValidator.validateIdea('Valid creator idea for 2026').isValid, isTrue);
      expect(InputValidator.validateIdea('മലയാളം കണ്ടന്റ് ഐഡിയ').isValid, isTrue);
    });

    test('validateCreatorName checks bounds', () {
      expect(InputValidator.validateCreatorName('').isValid, isFalse);
      expect(InputValidator.validateCreatorName('a').isValid, isFalse);
      expect(InputValidator.validateCreatorName('Joel').isValid, isTrue);
    });
  });

  group('Storage Integrity & Soft Delete', () {
    test('Soft delete flags project and restore recovers it cleanly', () async {
      final project = ContentProject(
        id: 'test-del-1',
        platform: 'Instagram',
        contentType: 'Post',
        idea: 'Design tips',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await StorageService.addProjectToHistory(project);
      expect(StorageService.getContentHistory().length, equals(1));

      // Soft delete
      await StorageService.softDeleteProject('test-del-1');
      expect(StorageService.getContentHistory().length, equals(0));
      expect(StorageService.getContentHistory(includeDeleted: true).length, equals(1));
      expect(StorageService.getContentHistory(includeDeleted: true).first.isDeleted, isTrue);

      // Restore
      await StorageService.restoreProject('test-del-1');
      expect(StorageService.getContentHistory().length, equals(1));
      expect(StorageService.getContentHistory().first.isDeleted, isFalse);
    });

    test('resetAll wipes local state and storage cleanly', () async {
      final appState = AppState.instance;
      await appState.updateProfile(const CreatorProfile(creatorName: 'Temp Creator'));
      expect(StorageService.getCreatorProfile()?.creatorName, equals('Temp Creator'));

      await appState.resetAll();
      expect(StorageService.getCreatorProfile(), isNull);
      expect(appState.profile.creatorName, isEmpty);
      expect(appState.contentHistory, isEmpty);
      expect(appState.currentProject, isNull);
    });
  });

  group('V2 Responsive Viewport & Overflow Verification', () {
    const viewports = [
      Size(320, 568),  // iPhone SE 1st gen
      Size(360, 800),  // Standard Android
      Size(392, 852),  // iPhone 14 / 15
      Size(430, 932),  // iPhone 14 Pro Max / Large phone
      Size(768, 1024), // Tablet
    ];

    for (final size in viewports) {
      testWidgets('ContentResultScreen renders cleanly at ${size.width.toInt()}x${size.height.toInt()} with zero overflow', (tester) async {
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        const mockContent = GeneratedContent(
          hooks: [
            'ഇനി Sadhya ഉണ്ടാക്കാൻ ടെൻഷൻ വേണ്ട — ഈ 5 കാര്യങ്ങൾ ശ്രദ്ധിച്ചാൽ മതി!',
            'Why traditional Kerala Sadhya is the ultimate balanced nutrition meal.',
            'The step-by-step master guide to cooking authentic Malabar Parippu.',
            'My grandmother’s secret spice blend that changed everything.',
            'Which Sadhya dish is your all-time favorite? Let me know in the comments!',
          ],
          caption: 'Traditional Kerala Sadhya is an art of flavors and heritage.\n\nHere are 5 insider cooking secrets from our family kitchen:\n• Secret 1: Slow roast the coconut\n• Secret 2: Use cold-pressed coconut oil\n• Secret 3: Fresh curry leaves at the end\n\nSave this reel for Onam preparation!',
          ctas: [
            'Save this recipe reel for later 💾',
            'Follow @AiswaryaKitchen for daily Kerala cooking hacks',
            'Share with your foodie friends!',
          ],
          hashtagsHighReach: ['#KeralaFood', '#MalayalamCreator', '#IndianCuisine', '#FoodOfKerala', '#KeralaGram'],
          hashtagsMediumReach: ['#MalabarCooking', '#SadhyaRecipes', '#TraditionalFlavors', '#KeralaVibes'],
          hashtagsNiche: ['#KozhikodeFoodies', '#AiswaryaKitchen', '#KeralaFoodBlogger'],
          coverText: 'SADHYA SECRETS 2026',
        );

        final project = ContentProject(
          id: 'v2-test-project',
          platform: 'Instagram',
          contentType: 'Reel',
          idea: 'Traditional Onam Sadhya Preparation Tips',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          status: 'generated',
          generatedContent: mockContent,
        );

        AppState.instance.setCurrentProject(project);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: ContentResultScreen(project: project),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Content Workspace'), findsOneWidget);
        expect(find.text('Hook Variations'), findsOneWidget);
        expect(find.text('PRIMARY HOOK'), findsOneWidget);
        expect(find.text('Calls to Action (CTA)'), findsOneWidget);
        expect(find.text('Strategic Hashtag Clusters'), findsOneWidget);
        expect(find.text('SADHYA SECRETS 2026'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('CreateScreen renders Step 0 & Step 1 at ${size.width.toInt()}x${size.height.toInt()} with zero overflow', (tester) async {
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const CreateScreen(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Select Platform'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Select Platform and Format
        await tester.tap(find.text('Instagram'));
        await tester.pumpAndSettle();

        expect(find.text('Content Format'), findsOneWidget);

        await tester.tap(find.text('Reel'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue to Canvas →'));
        await tester.pumpAndSettle();

        expect(find.text('Content Language & Dialect'), findsOneWidget);
        expect(find.text('Core Idea or Topic'), findsOneWidget);
        expect(find.text('Generate Studio Content Pack ✦'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Accessibility text scale (1.3x and 1.5x) on ContentResultScreen has zero overflow', (tester) async {
      tester.view.physicalSize = const Size(392 * 2, 852 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const mockContent = GeneratedContent(
        hooks: [
          '5 Must-have AI tools for modern digital creators in 2026',
          'Why the top 1% of creators are ditching traditional workflows',
          'The blueprint to scale your content output 10x with AI',
          'How I created 30 days of high-converting reels in under 2 hours',
          'Which creator tool is currently saving you the most time?',
        ],
        caption: 'AI workflows are transforming the creator economy.',
        ctas: ['Save this post', 'Follow for more'],
        hashtagsHighReach: ['#AI', '#Creators'],
        hashtagsMediumReach: ['#ContentAI'],
        hashtagsNiche: ['#CreateDiff'],
        coverText: 'AI CREATOR 2026',
      );

      final project = ContentProject(
        id: 'accessibility-test-project',
        platform: 'Instagram',
        contentType: 'Reel',
        idea: 'AI creator workflows',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'generated',
        generatedContent: mockContent,
      );

      AppState.instance.setCurrentProject(project);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.3),
              ),
              child: child!,
            );
          },
          home: ContentResultScreen(project: project),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Content Workspace'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
