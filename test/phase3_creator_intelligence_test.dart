import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creatediff/models/creator_profile.dart';
import 'package:creatediff/models/generated_content.dart';
import 'package:creatediff/models/quality_metadata.dart';
import 'package:creatediff/models/visual_intelligence.dart';
import 'package:creatediff/models/campaign_plan.dart';
import 'package:creatediff/models/content_project.dart';
import 'package:creatediff/services/storage_service.dart';
import 'package:creatediff/services/app_state.dart';
import 'package:creatediff/components/cd_quality_score_card.dart';
import 'package:creatediff/components/cd_visual_intelligence_card.dart';
import 'package:creatediff/components/cd_platform_content_cards.dart';
import 'package:creatediff/screens/campaign_planner_screen.dart';

Widget wrapWidget(Widget child) {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    await AppState.instance.init();
  });

  group('Phase 3 Creator Intelligence Models & Serialization', () {
    test('CreatorProfile retains preferredPlatforms and contentGoals through JSON roundtrip', () {
      const profile = CreatorProfile(
        creatorName: 'Joel G Jojo',
        username: '@joelgjojo',
        niche: 'AI & Tech',
        preferredPlatforms: ['Instagram', 'YouTube', 'TikTok'],
        contentGoals: ['Audience Growth', 'Authority Building'],
      );

      final json = profile.toJson();
      expect(json['preferredPlatforms'], contains('YouTube'));
      expect(json['contentGoals'], contains('Authority Building'));

      final restored = CreatorProfile.fromJson(json);
      expect(restored.preferredPlatforms, equals(['Instagram', 'YouTube', 'TikTok']));
      expect(restored.contentGoals, equals(['Audience Growth', 'Authority Building']));
    });

    test('GeneratedContent parses VisualIntelligence, QualityMetadata, and CarouselSlides', () {
      final json = {
        'hooks': ['Hook 1', 'Hook 2'],
        'caption': 'Sample caption',
        'ctas': ['Save post'],
        'script': '[0-3s]: Hook\\n[3-15s]: Core insight',
        'sceneDirections': ['Close up on face', 'Screen capture demo'],
        'slides': [
          {
            'slideNumber': 1,
            'headline': 'Slide 1 Headline',
            'bodyText': 'Slide 1 Body',
            'visualCue': 'Illustration',
          },
          {
            'slideNumber': 2,
            'headline': 'Slide 2 Headline',
            'bodyText': 'Slide 2 Body',
            'visualCue': 'Chart graphic',
          }
        ],
        'visualIntelligence': {
          'visualStyle': 'Dark Tech Minimalist',
          'layoutSuggestion': 'Bold center card',
          'thumbnailDirection': 'High contrast expression',
          'typographySuggestion': 'Space Grotesk',
          'colorPalette': ['#080A0F', '#4F43F9', '#00B894', '#FFFFFF'],
          'designMood': 'High voltage creator energy'
        },
        'quality': {
          'hookStrength': 95,
          'platformFit': 90,
          'audienceFit': 88,
          'originality': 92,
          'overallScore': 91,
          'issues': ['Optional improvement'],
          'retried': true,
        }
      };

      final content = GeneratedContent.fromJson(json);
      expect(content.script, isNotNull);
      expect(content.sceneDirections.length, equals(2));
      expect(content.slides.length, equals(2));
      expect(content.slides[0].headline, equals('Slide 1 Headline'));
      expect(content.visualIntelligence, isNotNull);
      expect(content.visualIntelligence!.visualStyle, equals('Dark Tech Minimalist'));
      expect(content.visualIntelligence!.colorPalette.length, equals(4));
      expect(content.quality, isNotNull);
      expect(content.quality!.overallScore, equals(91));
      expect(content.quality!.retried, isTrue);
    });

    test('CampaignPlan holds structured CampaignDayItem items with format, title, hookAngle, outline', () {
      final day1 = CampaignDayItem(
        day: 1,
        title: '5 AI Tools for Creators',
        topic: 'AI Productivity',
        platform: 'Instagram',
        contentType: 'Reel',
        hookAngle: 'Stop spending 10 hours creating content manually.',
        outline: '• Hook\\n• Demo 3 tools\\n• CTA to save',
        strategicIntent: 'Viral Discovery',
      );

      final plan = CampaignPlan(
        id: 'camp_123',
        campaignTitle: '7-Day AI Growth Sprint',
        campaignGoal: 'Gain 1,000 subscribers',
        durationDays: 7,
        platform: 'Instagram',
        strategySummary: 'Sprint focused on AI workflows',
        days: [day1],
        createdAt: DateTime.now(),
      );

      final json = plan.toJson();
      final restored = CampaignPlan.fromJson(json);

      expect(restored.days.length, equals(1));
      expect(restored.days[0].contentType, equals('Reel'));
      expect(restored.days[0].title, equals('5 AI Tools for Creators'));
      expect(restored.days[0].hookAngle, isNotEmpty);
      expect(restored.days[0].outline, isNotEmpty);
    });
  });

  group('StorageService Schema v3 & Migration Tests', () {
    test('StorageService persists and toggles project favorites and drafts', () async {
      final project = ContentProject(
        id: 'proj_1',
        platform: 'Instagram',
        contentType: 'Reel',
        idea: 'AI Content Workflow',
        createdAt: DateTime.now(),
      );

      await StorageService.addProjectToHistory(project);
      expect(StorageService.getFavorites().length, equals(0));

      await StorageService.toggleFavorite('proj_1');
      expect(StorageService.getFavorites().length, equals(1));
      expect(StorageService.getFavorites().first.id, equals('proj_1'));

      await StorageService.toggleFavorite('proj_1');
      expect(StorageService.getFavorites().length, equals(0));
    });

    test('StorageService persists and retrieves CampaignPlans', () async {
      final plan = CampaignPlan(
        id: 'camp_999',
        campaignTitle: '14-Day Omnichannel Blueprint',
        campaignGoal: 'Scale audience',
        durationDays: 14,
        days: const [],
        createdAt: DateTime.now(),
      );

      await StorageService.saveCampaign(plan);
      final list = StorageService.getCampaigns();
      expect(list.length, equals(1));
      expect(list.first.campaignTitle, equals('14-Day Omnichannel Blueprint'));

      await StorageService.deleteCampaign('camp_999');
      expect(StorageService.getCampaigns().length, equals(0));
    });
  });

  group('Phase 3 UI Components Widget Rendering', () {
    testWidgets('CDQualityScoreCard renders score, progress bars, and retried chip', (tester) async {
      const quality = QualityMetadata(
        overallScore: 92,
        hookStrength: 95,
        platformFit: 90,
        audienceFit: 88,
        originality: 94,
        retried: true,
      );

      await tester.pumpWidget(wrapWidget(const CDQualityScoreCard(quality: quality)));
      await tester.pumpAndSettle();

      expect(find.text('AI Quality: 92/100'), findsOneWidget);
      expect(find.text('AI Refined'), findsOneWidget);
      expect(find.text('Hook Strength'), findsOneWidget);
      expect(find.text('95%'), findsOneWidget);
    });

    testWidgets('CDVisualIntelligenceCard renders style, layout, and color swatches', (tester) async {
      const vi = VisualIntelligence(
        visualStyle: 'Cyberpunk Minimalist',
        layoutSuggestion: 'Bold headline top with floating cards',
        thumbnailDirection: 'Side reaction with bold yellow typography',
        typographySuggestion: 'Space Grotesk',
        colorPalette: ['#080A0F', '#4F43F9', '#00B894', '#FFFFFF'],
      );

      await tester.pumpWidget(wrapWidget(const CDVisualIntelligenceCard(visualIntelligence: vi)));
      await tester.pumpAndSettle();

      expect(find.text('AI Visual Direction'), findsOneWidget);
      expect(find.text('Cyberpunk Minimalist'), findsOneWidget);
      expect(find.text('#4F43F9'), findsOneWidget);
    });

    testWidgets('CDReelScriptCard renders script and scene directions', (tester) async {
      const script = '[0-3s]: Stop scrolling!\\n[3-15s]: 3 tools to save 10 hours.';
      const cues = ['Scene 1: Close up camera', 'Scene 2: Screen share'];

      await tester.pumpWidget(wrapWidget(const CDReelScriptCard(script: script, sceneDirections: cues)));
      await tester.pumpAndSettle();

      expect(find.text('Video Script & Flow'), findsOneWidget);
      expect(find.text(script), findsOneWidget);
      expect(find.text('Scene 1: Close up camera'), findsOneWidget);
    });

    testWidgets('CDCarouselSlideViewer steps through slides interactively', (tester) async {
      final slides = [
        const CarouselSlide(slideNumber: 1, headline: 'Slide 1 Title', bodyText: 'Slide 1 Body text'),
        const CarouselSlide(slideNumber: 2, headline: 'Slide 2 Title', bodyText: 'Slide 2 Body text'),
      ];

      await tester.pumpWidget(wrapWidget(CDCarouselSlideViewer(slides: slides)));
      await tester.pumpAndSettle();

      expect(find.text('Carousel Slides (1/2)'), findsOneWidget);
      expect(find.text('Slide 1 Title'), findsOneWidget);

      await tester.tap(find.text('Next Slide'));
      await tester.pumpAndSettle();

      expect(find.text('Carousel Slides (2/2)'), findsOneWidget);
      expect(find.text('Slide 2 Title'), findsOneWidget);
    });

    testWidgets('CampaignPlannerScreen renders input card and duration selectors', (tester) async {
      await tester.pumpWidget(wrapWidget(const CampaignPlannerScreen()));
      await tester.pumpAndSettle();

      expect(find.text('AI Campaign Planner'), findsOneWidget);
      expect(find.text('Campaign Strategy & Objectives'), findsOneWidget);
      expect(find.text('7 Days (Sprint)'), findsOneWidget);
      expect(find.text('14 Days (Growth)'), findsOneWidget);
      expect(find.text('30 Days (Masterplan)'), findsOneWidget);
    });
  });
}
