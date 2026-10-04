import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prana/screens/my_card_screen.dart';

void main() {
  testWidgets('Test MyCardScreen layout with suspended card', (WidgetTester tester) async {
    // Set screen size to realistic mobile size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: MyCardScreen(),
      ),
    );
    await tester.pump();

    // Toggle card status to false
    final switchFinder = find.byType(SwitchListTile);
    expect(switchFinder, findsOneWidget);
    
    // Tap to suspend
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    // In the dialog, tap Suspend
    final suspendBtn = find.text('Suspend');
    if (suspendBtn.evaluate().isNotEmpty) {
      await tester.tap(suspendBtn);
      await tester.pumpAndSettle();
    }

    // Now it should be suspended!
    expect(find.text('🛑 CARD SUSPENDED'), findsOneWidget);
  });
}
