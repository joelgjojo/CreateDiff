import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:creatediff/screens/admin_screen.dart';

void main() {
  testWidgets('AdminScreen renders loading and console header cleanly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdminScreen(),
      ),
    );

    expect(find.text('Admin Studio Console'), findsOneWidget);
    expect(find.text('BACKEND AUTHORIZED'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
  });
}
