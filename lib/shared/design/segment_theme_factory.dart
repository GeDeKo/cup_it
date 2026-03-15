import 'package:flutter/material.dart';

import '../../core/segment/segment_models.dart';
import 'design_tokens.dart';

class SegmentThemeFactory {
  static ThemeData build(UserSegment segment) {
    switch (segment) {
      case UserSegment.child:
        return _childTheme();
      case UserSegment.teen:
        return _teenTheme();
      case UserSegment.adult:
        return _adultTheme();
      case UserSegment.business:
        return _businessTheme();
    }
  }

  static ThemeData _childTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2A8BFF),
      brightness: Brightness.light,
      primary: const Color(0xFF2A8BFF),
      secondary: const Color(0xFF26C6DA),
      error: const Color(0xFFD83B6A),
    );
    return _baseTheme(
      scheme: scheme,
      scaffoldBg: const Color(0xFFF3FAFF),
      textPrimary: const Color(0xFF12304A),
      textMuted: const Color(0xFF496580),
      glass: const Color(0xE6FFFFFF),
      glassStrong: const Color(0xFFE4EDF7),
    );
  }

  static ThemeData _teenTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4E6CFF),
      brightness: Brightness.dark,
      primary: const Color(0xFF79A8FF),
      secondary: const Color(0xFF5AE4C6),
      error: const Color(0xFFFF8FB2),
    );
    return _baseTheme(
      scheme: scheme,
      scaffoldBg: const Color(0xFF0B1335),
      textPrimary: const Color(0xFFEAF2FF),
      textMuted: const Color(0xFFB5C8F6),
      glass: const Color(0x2AFFFFFF),
      glassStrong: const Color(0x48FFFFFF),
    );
  }

  static ThemeData _adultTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      brightness: Brightness.dark,
      primary: const Color(0xFF89C9FF),
      secondary: const Color(0xFF66D8C0),
      error: AppColors.danger,
    );
    return _baseTheme(
      scheme: scheme,
      scaffoldBg: AppColors.bgDeep,
      textPrimary: AppColors.textPrimary,
      textMuted: AppColors.textMuted,
      glass: AppColors.glass,
      glassStrong: AppColors.glassStrong,
    );
  }

  static ThemeData _businessTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F7AA8),
      brightness: Brightness.dark,
      primary: const Color(0xFF9EC0E9),
      secondary: const Color(0xFF7FB5D8),
      error: const Color(0xFFE0809D),
    );
    return _baseTheme(
      scheme: scheme,
      scaffoldBg: const Color(0xFF0E1A2E),
      textPrimary: const Color(0xFFE6EFFA),
      textMuted: const Color(0xFFAAC0D8),
      glass: const Color(0x22FFFFFF),
      glassStrong: const Color(0x3EFFFFFF),
    );
  }

  static ThemeData _baseTheme({
    required ColorScheme scheme,
    required Color scaffoldBg,
    required Color textPrimary,
    required Color textMuted,
    required Color glass,
    required Color glassStrong,
  }) {
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      useMaterial3: true,
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 30,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(color: textPrimary, fontSize: 14),
        bodySmall: TextStyle(color: textMuted, fontSize: 12),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glass,
        border: OutlineInputBorder(
          borderRadius: AppRadii.card,
          borderSide: BorderSide(color: glassStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.card,
          borderSide: BorderSide(color: glassStrong),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        backgroundColor: glass,
        selectedColor: glassStrong,
        side: BorderSide(color: glassStrong),
        labelStyle: TextStyle(color: textPrimary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: textPrimary,
          backgroundColor: scheme.primary.withValues(alpha: 0.25),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.pill),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: glassStrong),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.pill),
        ),
      ),
      dividerColor: glassStrong,
    );
  }
}
