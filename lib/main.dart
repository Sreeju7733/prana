import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const PranaApp());
}

class PranaApp extends StatelessWidget {
  const PranaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prana',
      debugShowCheckedModeBanner: false,
      theme: PranaTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
