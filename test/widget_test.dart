import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creatediff/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CreateDiff app smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CreateDiffApp());
    expect(find.text('CreateDiff'), findsWidgets);

    // Fast-forward splash screen timer
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();
  });
}
