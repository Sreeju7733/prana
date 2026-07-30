import 'package:flutter/material.dart';
import 'colors.dart';

class PranaTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: PranaColors.midnightNavy,
      primaryColor: PranaColors.pranaTeal,
      colorScheme: const ColorScheme.dark(
        primary: PranaColors.pranaTeal,
        secondary: PranaColors.emergencyCyan,
        surface: PranaColors.slateCard,
        error: PranaColors.alertRed,
      ),
      cardTheme: const CardThemeData(
        color: PranaColors.slateCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PranaColors.slateCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: PranaColors.textGray),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PranaColors.pranaTeal,
          foregroundColor: PranaColors.midnightNavy,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
