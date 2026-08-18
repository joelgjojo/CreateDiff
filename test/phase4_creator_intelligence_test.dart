import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creatediff/models/creator_intelligence.dart';
import 'package:creatediff/models/content_intelligence.dart';
import 'package:creatediff/models/creator_profile.dart';
import 'package:creatediff/components/cd_creator_intelligence_cards.dart';
import 'package:creatediff/services/voice_input_service.dart';
import 'package:creatediff/services/app_state.dart';
import 'package:creatediff/services/storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    await AppState.instance.init();
  });

  group('Phase 4: Vernacular Intelligence & LanguageProfile', () {
    test('LanguageProfile defaults and JSON round-trip', () {
      const defaultProfile = LanguageProfile();
      expect(defaultProfile.language, 'English');
      expect(defaultProfile.preferredStyle, 'Conversational');

      const custom = LanguageProfile(
        language: 'Malayalam',
        preferredStyle: 'Storytelling',
        audienceType: 'Tech students in Kerala',
        regionalContext: 'Kochi startup ecosystem',
        communicationTone: 'Warm & Relatable',
      );

      final json = custom.toJson();
      final roundTrip = LanguageProfile.fromJson(json);

      expect(roundTrip.language, 'Malayalam');
      expect(roundTrip.preferredStyle, 'Storytelling');
      expect(roundTrip.regionalContext, 'Kochi startup ecosystem');
      expect(roundTrip.communicationTone, 'Warm & Relatable');
    });

    test('CreatorProfile includes LanguageProfile and CreatorMemory', () {
      final profile = CreatorProfile(
        creatorName: 'Joel G Jojo',
        languageProfile: const LanguageProfile(
          language: 'Manglish',
          preferredStyle: 'Conversational',
          regionalContext: 'Kerala developer community',
        ),
        creatorMemory: const CreatorMemory(
          brandRules: ['Never use generic intros'],
          preferredHooks: ['Stop doing this manually'],
        ),
      );

      final json = profile.toJson();
      final restored = CreatorProfile.fromJson(json);

      expect(restored.languageProfile.language, 'Manglish');
      expect(restored.languageProfile.regionalContext, 'Kerala developer community');
      expect(restored.creatorMemory.brandRules, contains('Never use generic intros'));
      expect(restored.creatorMemory.preferredHooks, contains('Stop doing this manually'));
    });
  });

  group('Phase 4: CreatorMemory Storage and Learning', () {
    test('CreatorMemory isBuilding status', () {
      const emptyMemory = CreatorMemory();
      expect(emptyMemory.isBuilding, isTrue);

      final activeMemory = emptyMemory.copyWith(
        preferredHooks: ['Top 5 tools in 2026'],
      );
      expect(activeMemory.isBuilding, isFalse);
    });

    test('AppState updates and clears creator memory', () async {
      const memory = CreatorMemory(
        brandRules: ['Actionable bullet points only'],
        avoidPatterns: ['Corporate buzzwords'],
      );

      await AppState.instance.updateCreatorMemory(memory);
      expect(AppState.instance.profile.creatorMemory.brandRules, contains('Actionable bullet points only'));
      expect(AppState.instance.profile.creatorMemory.isBuilding, isFalse);

      await AppState.instance.clearCreatorMemory();
      expect(AppState.instance.profile.creatorMemory.isBuilding, isTrue);
      expect(AppState.instance.profile.creatorMemory.brandRules, isEmpty);
    });
  });

  group('Phase 4: Content Intelligence Cards Widget Tests', () {
    testWidgets('CDCreativeDirectorCard renders narrative insights', (tester) async {
      const insight = CreativeDirectorInsight(
        audienceInsight: 'Creators value actionable time-saving workflows.',
        contentAngle: 'Contrarian breakdown of studio workflows.',
        storyStructure: 'Hook -> Proof -> Solution -> CTA',
        improvementSuggestion: 'Emphasize exact time metrics.',
        reasoning: 'Data-driven proof points boost engagement by 40%.',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CDCreativeDirectorCard(insight: insight),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Creative Director'), findsOneWidget);
      expect(find.textContaining('Audience Insight'), findsOneWidget);
      expect(find.textContaining('Contrarian breakdown'), findsOneWidget);
    });

    testWidgets('CDContentReviewCard renders AI review with disclaimer', (tester) async {
      const review = ContentReview(
        hookAnalysis: 'Very strong curiosity trigger.',
        clarityAnalysis: 'Clean and punchy.',
        audienceFit: 'Direct match for tech creators.',
        improvementSuggestions: ['Add bolder first word'],
        disclaimer: 'AI analysis only — not real performance prediction.',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CDContentReviewCard(review: review),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AI Content Review'), findsOneWidget);
      expect(find.text('ANALYSIS'), findsOneWidget);
      expect(find.text('AI analysis only — not real performance prediction.'), findsWidgets);
      expect(find.textContaining('Very strong curiosity trigger'), findsOneWidget);
      expect(find.textContaining('Add bolder first word'), findsOneWidget);
    });

    testWidgets('CDRepurposeCard renders all 5 multi-channel formats', (tester) async {
      const repurposed = RepurposedContent(
        instagramCaption: 'Short punchy IG caption',
        linkedinPost: 'Insightful LinkedIn breakdown',
        youtubeDescription: 'SEO-optimized description',
        xThread: ['1/3 First tweet', '2/3 Second tweet', '3/3 Third tweet'],
        blogOutline: ['Intro', 'Core Blueprint', 'Summary'],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CDRepurposeCard(content: repurposed),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Repurpose this Idea'), findsOneWidget);

      // Expand the tile to reveal contents
      await tester.tap(find.text('Repurpose this Idea'));
      await tester.pumpAndSettle();

      expect(find.text('Instagram Caption'), findsOneWidget);
      expect(find.text('LinkedIn Post'), findsOneWidget);
      expect(find.text('YouTube Description'), findsOneWidget);
      expect(find.textContaining('X / Twitter Thread'), findsOneWidget);
      expect(find.text('Blog / Newsletter Outline'), findsOneWidget);
      expect(find.text('Copy'), findsWidgets);
    });
  });

  group('Phase 4: VoiceInputService Instantiation', () {
    test('VoiceInputService initialized with default values', () {
      final voice = VoiceInputService();
      expect(voice.isListening, isFalse);
      expect(voice.isAvailable, isFalse);
    });
  });
}
