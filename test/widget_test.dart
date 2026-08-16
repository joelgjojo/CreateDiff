import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creatediff/main.dart';
import 'package:creatediff/components/cd_logo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CreateDiff app brand splash & launch smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CreateDiffApp());

    // Verify official CDLogo is rendered on splash
    expect(find.byType(CDLogo), findsWidgets);
    expect(find.text('AI CONTENT STUDIO'), findsOneWidget);

    // Fast-forward splash screen timer
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();
  });
}
