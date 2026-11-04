import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF4FCFD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF183344);
  static const Color muted = Color(0xFF6D8792);
  static const Color cyan = Color(0xFF35D5EE);
  static const Color cyanDeep = Color(0xFF09BBD8);
  static const Color mint = Color(0xFF75F0C7);
  static const Color mintDeep = Color(0xFF22C995);
  static const Color line = Color(0xFFD8EEF0);
  static const Color danger = Color(0xFFFF6B72);
  static const Color warning = Color(0xFFFFB84D);
}

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.cyanDeep,
      brightness: Brightness.light,
      primary: AppColors.cyanDeep,
      secondary: AppColors.mintDeep,
      surface: AppColors.surface,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: null,
      appBarTheme: const AppBarThemeData(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.line),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cyanDeep, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(54),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w900),
        titleLarge: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: AppColors.ink),
        bodyMedium: TextStyle(color: AppColors.ink),
        bodySmall: TextStyle(color: AppColors.muted),
      ),
    );
  }
}
