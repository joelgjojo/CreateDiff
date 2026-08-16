import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creatediff/models/creator_profile.dart';
import 'package:creatediff/models/content_project.dart';
import 'package:creatediff/models/generated_content.dart';
import 'package:creatediff/services/app_state.dart';
import 'package:creatediff/services/storage_service.dart';
import 'package:creatediff/screens/splash_screen.dart';
import 'package:creatediff/screens/onboarding_screen.dart';
import 'package:creatediff/screens/creator_profile_screen.dart';
import 'package:creatediff/screens/main_shell.dart';
import 'package:creatediff/screens/home_screen.dart';
import 'package:creatediff/screens/create_screen.dart';
import 'package:creatediff/screens/content_result_screen.dart';
import 'package:creatediff/screens/design_selection_screen.dart';
import 'package:creatediff/screens/history_screen.dart';
import 'package:creatediff/screens/profile_screen.dart';
import 'package:creatediff/screens/debug_panel_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleProject = ContentProject(
    id: 'test_p1',
    platform: 'Instagram',
    contentType: 'Reel',
    idea: '5 AI tips for students',
    createdAt: DateTime.now(),
    status: 'generated',
    generatedContent: const GeneratedContent(
      hooks: ['Hook 1: Secret AI tool', 'Hook 2: Stop scrolling', 'Hook 3: Blueprint'],
      caption: 'Full formatted caption text\n\nLine 2 with bullet points\n• Point 1\n• Point 2',
      ctas: ['Save this reel 💾', 'Share with a friend'],
      hashtagsHighReach: ['#ai', '#tools'],
      hashtagsMediumReach: ['#students', '#tech'],
      hashtagsNiche: ['#creatediff'],
      coverText: 'SECRET AI TOOLS',
      variations: ['Standard', 'High Engagement'],
    ),
    language: 'English',
    tone: 'Educational',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.init();
    await AppState.instance.updateProfile(const CreatorProfile(
      creatorName: 'Joel G Jojo',
      username: '@joelgjojo',
      niche: 'Technology',
    ));
    await StorageService.addProjectToHistory(sampleProject);
    AppState.instance.setCurrentProject(sampleProject);
  });

  Widget wrapWithMaterial(Widget child) {
    return MaterialApp(
      home: child,
      theme: ThemeData.dark(),
    );
  }

  testWidgets('Screen Test: SplashScreen pumps with no exceptions', (tester) async {
    await tester.pumpWidget(wrapWithMaterial(const SplashScreen()));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen Test: OnboardingScreen pumps with no exceptions', (tester) async {
    await tester.pumpWidget(wrapWithMaterial(const OnboardingScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen Test: CreatorProfileScreen (initial setup) pumps with no exceptions', (tester) async {
    await tester.pumpWidget(wrapWithMaterial(const CreatorProfileScreen(isInitialSetup: true)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen Test: CreatorProfileScreen (edit mode) pumps with no exceptions', (tester) async {
    await tester.pumpWidget(wrapWithMaterial(const CreatorProfileScreen(isInitialSetup: false)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen Test: HomeScreen pumps with no exceptions', (tester) async {
    await tester.pumpWidget(wrapWithMaterial(const HomeScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen Test: CreateScreen (step 0 format) pumps with no exceptions', (tester) async {
    await tester.pumpWidget(wrapWithMaterial(const CreateScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen Test: CreateScreen (step 1 canvas) pumps with no exceptions', (tester) async {
    await tester.pumpWidget(wrapWithMaterial(const CreateScreen(
      initialPlatform: 'Instagram',
      initialContentType: 'Reel',
      initialIdea: 'My startup story',
    )));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen Test: ContentResultScreen pumps with no exceptions', (tester) async {
    await tester.pumpWidget(wrapWithMaterial(ContentResultScreen(project: sampleProject)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen Test: DesignSelectionScreen pumps with no exceptions', (tester) async {
    await tester.pumpWidget(wrapWithMaterial(DesignSelectionScreen(project: sampleProject)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen Test: HistoryScreen pumps with no exceptions', (tester) async {
    await tester.pumpWidget(wrapWithMaterial(const HistoryScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen Test: ProfileScreen pumps with no exceptions', (tester) async {
    await tester.pumpWidget(wrapWithMaterial(const ProfileScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen Test: DebugPanelScreen pumps with no exceptions', (tester) async {
    await tester.pumpWidget(wrapWithMaterial(const DebugPanelScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen Test: MainShell pumps and switches tabs with no exceptions', (tester) async {
    await tester.pumpWidget(wrapWithMaterial(const MainShell()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
