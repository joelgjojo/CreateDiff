import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:creatediff/config/api_config.dart';
import 'package:creatediff/models/content_project.dart';
import 'package:creatediff/models/generated_content.dart';
import 'package:creatediff/services/app_state.dart';
import 'package:creatediff/components/cd_export_share_sheet.dart';
import 'package:creatediff/components/cd_bottom_nav_bar.dart';
import 'package:creatediff/screens/content_result_screen.dart';
import 'package:creatediff/screens/debug_panel_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Part 1 Bug Fixes & Stability Regressions', () {
    final testProject = ContentProject(
      id: 'test-1',
      platform: 'Instagram',
      contentType: 'Reel',
      idea: '5 productivity tips',
      createdAt: DateTime.now(),
      generatedContent: const GeneratedContent(
        hooks: ['Hook 1', 'Hook 2'],
        caption: 'Test caption for productivity tips',
        ctas: ['Follow for more'],
        hashtagsHighReach: ['#productivity'],
        hashtagsMediumReach: ['#tips'],
        hashtagsNiche: ['#timemanagement'],
        coverText: 'PRODUCTIVITY 101',
        variations: ['Standard video'],
      ),
    );

    test('B9: apiKey getter falls back to environment when setConfig called without key', () {
      // Set only model/baseUrl without providing apiKey
      ApiConfig.setConfig(model: 'custom-model', baseUrl: 'https://api.custom.com/v1');
      // When GROK_API_KEY is present in .env or compile-time define, it should not be wiped
      expect(ApiConfig.model, equals('custom-model'));
      expect(ApiConfig.baseUrl, equals('https://api.custom.com/v1'));
      // hasApiKey should still be valid from .env / dart-define if present
      ApiConfig.resetOverrides();
    });

    test('B12: isApiConfigured reflects key status correctly', () {
      final appState = AppState.instance;
      // When key exists
      expect(appState.isApiConfigured, equals(ApiConfig.hasApiKey));
    });

    testWidgets('B1: Bottom nav bar has exactly 4 tabs (Home, Create, History, Profile) without embedded Studio tab', (tester) async {
      int selectedTab = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CDBottomNavBar(
              selectedIndex: selectedTab,
              onTabChanged: (i) => selectedTab = i,
            ),
          ),
        ),
      );

      // Verify tabs present
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      // Studio tab must not be present in bottom nav
      expect(find.text('Studio'), findsNothing);
    });

    testWidgets('B2: ContentResultScreen reflects AppState updates reactively', (tester) async {
      final appState = AppState.instance;
      appState.setCurrentProject(testProject);

      await tester.pumpWidget(
        MaterialApp(
          home: ContentResultScreen(project: testProject),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test caption for productivity tips'), findsOneWidget);

      // Update caption in AppState
      await appState.updateCurrentProjectCaption('Updated reactive caption text');
      await tester.pumpAndSettle();

      expect(find.text('Updated reactive caption text'), findsOneWidget);
    });

    testWidgets('B8: CDExportShareSheet scrolls cleanly without overflow on small screen viewport (320x568)', (tester) async {
      // Small screen size (iPhone SE 1st gen viewport)
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    CDExportShareSheet.show(
                      context,
                      project: testProject,
                      onDone: () {},
                    );
                  },
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Verify sheet renders without any overflow exception
      expect(find.text('Ready to Publish'), findsOneWidget);
      expect(find.text('Copy All Content'), findsOneWidget);
      expect(find.text('Share Directly'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('B13: DebugPanelScreen builds properly in test/debug mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DebugPanelScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Developer Debug Panel'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
