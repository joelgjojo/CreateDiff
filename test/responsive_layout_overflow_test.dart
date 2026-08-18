import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creatediff/models/creator_profile.dart';
import 'package:creatediff/models/content_project.dart';
import 'package:creatediff/models/generated_content.dart';
import 'package:creatediff/services/app_state.dart';
import 'package:creatediff/services/storage_service.dart';
import 'package:creatediff/theme/app_theme.dart';

import 'package:creatediff/screens/home_screen.dart';
import 'package:creatediff/screens/create_screen.dart';
import 'package:creatediff/screens/content_result_screen.dart';
import 'package:creatediff/screens/creator_profile_screen.dart';
import 'package:creatediff/screens/profile_screen.dart';
import 'package:creatediff/screens/history_screen.dart';
import 'package:creatediff/screens/design_selection_screen.dart';
import 'package:creatediff/screens/onboarding_screen.dart';
import 'package:creatediff/screens/splash_screen.dart';
import 'package:creatediff/screens/campaign_planner_screen.dart';
import 'package:creatediff/models/campaign_plan.dart';
import 'package:creatediff/components/cd_export_share_sheet.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 5 Target physical device dimensions
  const viewports = <String, Size>{
    'Ultra-Small Phone (320x568)': Size(320, 568),
    'Small Android (360x800)': Size(360, 800),
    'Normal Phone (392x852)': Size(392, 852),
    'Large Phone (430x932)': Size(430, 932),
    'Tablet (768x1024)': Size(768, 1024),
  };

  final sampleProject = ContentProject(
    id: 'responsive_proj_1',
    platform: 'Instagram',
    contentType: 'Reel',
    idea: '5 AI tools for creators in 2026 with ultra long detailed multilingual prompt മലയാളം മാംഗ്ലീഷ് & Hindi hints',
    createdAt: DateTime.now(),
    generatedContent: const GeneratedContent(
      hooks: [
        'Stop scrolling! 5 AI tools that will 10x your content creation in 2026',
        'If you are not using this AI workflow, you are working 5x harder than you need to',
        'Here is the secret AI stack top creators are using right now in Kerala and worldwide',
        'What if you could generate reels, hooks, captions, and carousel designs in 10 seconds?',
        'Don\'t build content the 2024 way. Here is the upgraded 2026 creator blueprint',
      ],
      caption: 'Transform your creator workflow today with these 5 AI tools!\n\n1. Automated video editing\n2. Smart scripting engines\n3. Dynamic design studios\n4. SEO & discovery optimizers\n5. Multi-platform syndication\n\nWhich tool will you try first? Drop a comment below! 🔥',
      ctas: [
        'Save this Reel for your next creation session',
        'Share with a fellow creator who needs this',
        'Follow for daily AI creator tactics',
      ],
      hashtagsHighReach: ['#ArtificialIntelligence', '#ContentCreator', '#DigitalMarketing', '#TechTrends', '#CreatorEconomy'],
      hashtagsMediumReach: ['#AIForCreators', '#KeralaFood', '#MalayaliCreator', '#ProductivityHacks'],
      hashtagsNiche: ['#DesignStudioAI', '#TechInMalayalam', '#ShortFormContent'],
      coverText: 'TOP 5 AI TOOLS FOR CREATORS 2026',
      variations: ['Standard 9:16 Video', 'Carousel Breakdown', 'Story Poll'],
    ),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.init();
    await AppState.instance.updateProfile(
      const CreatorProfile(
        creatorName: 'Aiswarya Mohan & Joel G Jojo',
        username: '@aiswaryamohan_studio',
        niche: 'Technology & Design',
        targetAudience: 'Content creators, freelancers, and small business owners in Kerala',
        tone: 'Actionable & Educational',
        primaryLanguage: 'Manglish',
        secondaryLanguage: 'Malayalam',
        brandDescription: 'Next-generation AI design studio for South Asian creators',
      ),
    );
  });

  Widget wrapScreen(Widget child, {bool isDark = true, double textScale = 1.0}) {
    return MaterialApp(
      theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child,
      ),
    );
  }

  for (final entry in viewports.entries) {
    final name = entry.key;
    final size = entry.value;

    group('Responsive Viewport Audit — $name', () {
      testWidgets('HomeScreen renders with zero overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(wrapScreen(const HomeScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('CreateScreen renders Step 0 & Step 1 with zero overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(wrapScreen(const CreateScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        // Transition to Step 1
        await tester.tap(find.text('Instagram'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Reel'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue to Canvas →'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('ContentResultScreen renders full content pack with zero overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(wrapScreen(ContentResultScreen(project: sampleProject)));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('CreatorProfileScreen (all 5 steps) renders with zero overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(wrapScreen(const CreatorProfileScreen(isInitialSetup: false)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Step 1
        await tester.tap(find.text('Continue →'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Step 2
        await tester.tap(find.text('Continue →'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Step 3
        await tester.tap(find.text('Continue →'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Step 4
        await tester.tap(find.text('Continue →'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('ProfileScreen renders with memory expansion and zero overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        FlutterErrorDetails? errorCaught;
        final origOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          errorCaught = details;
          debugPrint('FLUTTER_ERROR_CAUGHT: ${details.exceptionAsString()}');
          debugPrint('FLUTTER_ERROR_WIDGET: ${details.context?.toDescription()}');
        };

        await tester.pumpWidget(wrapScreen(const ProfileScreen()));
        await tester.pumpAndSettle();

        FlutterError.onError = origOnError;

        if (errorCaught != null) {
          debugPrint('ERROR ON PROFILE SCREEN: ${errorCaught?.exceptionAsString()}');
        }
        expect(errorCaught, isNull);

        // Expand Brand Memory Accordion
        await tester.tap(find.text('BRAND MEMORY ATTRIBUTES'));
        await tester.pumpAndSettle();
        final exp = tester.takeException();
        if (exp != null) {
          debugPrint('PROFILE OVERFLOW EXCEPTION: $exp');
        }
        expect(exp, isNull);
      });

      testWidgets('HistoryScreen renders with list and zero overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(wrapScreen(const HistoryScreen()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('DesignSelectionScreen renders template gallery with zero overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(wrapScreen(DesignSelectionScreen(project: sampleProject)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('CDExportShareSheet renders with zero overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          wrapScreen(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  CDExportShareSheet.show(
                    context,
                    project: sampleProject,
                    onDone: () {},
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('CampaignPlannerScreen renders input & full roadmap with zero overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // 1. Initial screen
        await tester.pumpWidget(wrapScreen(const CampaignPlannerScreen()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // 2. Screen with populated campaign plan and long badges
        final plan = CampaignPlan(
          id: 'camp_audit',
          campaignTitle: '30-Day Omnichannel Creator Growth & Brand Monetization Sequence',
          campaignGoal: 'Scale audience & build sustainable authority',
          durationDays: 30,
          platform: 'Instagram',
          strategySummary: 'Holistic content sequence alternating between discovery hooks, educational carousels, and high-conversion community posts.',
          days: [
            CampaignDayItem(
              day: 1,
              title: '5 AI Tools Every Modern Creator Needs to Know in 2026',
              topic: 'Productivity',
              platform: 'Instagram',
              contentType: 'Reel',
              hookAngle: 'Stop spending 10 hours editing when this one tool can do it in 60 seconds.',
              outline: '• Dynamic hook with visual stop\n• 3 core AI workflow tools\n• Actionable breakdown\n• CTA to save and share',
              strategicIntent: 'Productivity & Efficiency & Viral Discovery',
            ),
            CampaignDayItem(
              day: 2,
              title: 'The Modern Brand Memory Architecture Explained for Designers',
              topic: 'Design & Branding',
              platform: 'Instagram',
              contentType: 'Carousel',
              hookAngle: 'Why standard prompt templates are failing your brand.',
              outline: '• Slide 1: Problem statement\n• Slide 2: Context retention\n• Slide 3: Visual identity guidelines\n• Slide 4: Summary',
              strategicIntent: 'Authority Building & Community Engagement',
            ),
          ],
          createdAt: DateTime.now(),
        );

        await StorageService.saveCampaign(plan);
        await AppState.instance.init();
        await tester.pumpWidget(wrapScreen(const CampaignPlannerScreen()));

        await tester.pumpAndSettle();

        // Switch to saved campaign
        await tester.tap(find.byIcon(Icons.folder_special_outlined));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Select the campaign
        await tester.tap(find.text('30-Day Omnichannel Creator Growth & Brand Monetization Sequence'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('OnboardingScreen & SplashScreen render with zero overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(wrapScreen(const OnboardingScreen()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(wrapScreen(const SplashScreen()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull);
        await tester.pump(const Duration(milliseconds: 1200));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    });
  }

  group('Accessibility Font Scale Audit (1.3x Larger Font Scaling)', () {
    testWidgets('ContentResultScreen and ProfileScreen with 1.3x text scaling have zero overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      FlutterErrorDetails? errorCaught;
      final origOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errorCaught = details;
        debugPrint('A11Y_ERROR_CAUGHT: ${details.exceptionAsString()}');
        debugPrint('A11Y_ERROR_WIDGET: ${details.context?.toDescription()}');
      };

      await tester.pumpWidget(wrapScreen(ContentResultScreen(project: sampleProject), textScale: 1.3));
      await tester.pumpAndSettle();

      FlutterError.onError = origOnError;
      if (errorCaught != null) {
        debugPrint('A11Y OVERFLOW DETAILS: ${errorCaught?.exceptionAsString()}');
      }
      expect(errorCaught, isNull);

      await tester.pumpWidget(wrapScreen(const ProfileScreen(), textScale: 1.3));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
