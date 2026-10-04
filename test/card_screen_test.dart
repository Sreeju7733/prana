import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prana/screens/my_card_screen.dart';

void main() {
  testWidgets('MyCardScreen suspended state test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MyCardScreen(),
      ),
    );
    // Find SwitchListTile and toggle it to false
    final switchFinder = find.byType(SwitchListTile);
    expect(switchFinder, findsOneWidget);
    
    // Tap the switch to suspend
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
  });
}
