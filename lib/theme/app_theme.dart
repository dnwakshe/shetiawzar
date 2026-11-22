import 'package:flutter/material.dart';

/// Semantic colors and design tokens mirroring the Wakshe Agrotech HTML design:
/// :root { --green:#173f2a; --green2:#245c3c; --lime:#d7e8b1; --cream:#f7f5ed;
///         --ink:#202820; --muted:#687269; --line:#e6e8df; --gold:#d6a94d; ... }
class AppColors {
  AppColors._();

  static const Color green = Color(0xFF173F2A);
  static const Color green2 = Color(0xFF245C3C);
  static const Color greenLight = Color(0xFF47794B);
  static const Color lime = Color(0xFFD7E8B1);
  static const Color cream = Color(0xFFF7F5ED);
  static const Color ink = Color(0xFF202820);
  static const Color muted = Color(0xFF687269);
  static const Color line = Color(0xFFE6E8DF);
  static const Color gold = Color(0xFFD6A94D);
  static const Color white = Colors.white;

  // Background surfaces & cards
  static const Color featureBg = Color(0xFFEDF1E5);
  static const Color footerBg = Color(0xFF112E1E);
  static const Color artGradientStart = Color(0xFFEEF1E5);
  static const Color artGradientEnd = Color(0xFFE1E8D7);

  // Status badges
  static const Color inStockBg = Color(0xFFE8F3E6);
  static const Color inStockText = Color(0xFF2E693C);
  static const Color outOfStockBg = Color(0xFFFEE2E2);
  static const Color outOfStockText = Color(0xFFB91C1C);
}

/// Material 3 theme configuration matching the Wakshe Agrotech web store aesthetic.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      brightness: Brightness.light,
      primary: AppColors.green,
      onPrimary: Colors.white,
      primaryContainer: AppColors.lime,
      onPrimaryContainer: AppColors.green,
      secondary: AppColors.green2,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.ink,
      error: AppColors.outOfStockText,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
          side: const BorderSide(color: AppColors.line, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.green2, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
