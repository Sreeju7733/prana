import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prana/screens/my_card_screen.dart';

void main() {
  testWidgets('MyCardScreen pump test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MyCardScreen(),
      ),
    );
    await tester.pump();
  });
}
