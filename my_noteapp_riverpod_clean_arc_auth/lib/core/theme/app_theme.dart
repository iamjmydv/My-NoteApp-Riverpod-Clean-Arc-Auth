import 'package:flutter/material.dart';

/// Design tokens for the "Modern Clean" redesign (see Figma: Flutter Noteapp
/// Design). Centralizes colors, the note-card palette, and the app [ThemeData]
/// so every screen stays visually consistent.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color primarySoft = Color(0xFFEEF2FF);

  // Surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  // Text
  static const Color ink = Color(0xFF0F172A);
  static const Color inkSub = Color(0xFF64748B);
  static const Color inkFaint = Color(0xFF94A3B8);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color errorSoft = Color(0xFFFEE2E2);

  /// (background tint, accent dot) pairs cycled across the note list.
  static const List<(Color, Color)> noteCardTints = [
    (Color(0xFFEFF6FF), Color(0xFF3B82F6)), // blue
    (Color(0xFFFDF2F8), Color(0xFFEC4899)), // pink
    (Color(0xFFFFFBEB), Color(0xFFF59E0B)), // amber
    (Color(0xFFF0FDF4), Color(0xFF22C55E)), // green
    (Color(0xFFF5F3FF), Color(0xFF8B5CF6)), // violet
  ];

  /// Deterministic (background, accent) tint for a note based on its index.
  static (Color, Color) noteCardTint(int index) =>
      noteCardTints[index % noteCardTints.length];
}

class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Inter';

  static ThemeData light() {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.primary,
      onSecondary: Colors.white,
      surface: AppColors.background,
      onSurface: AppColors.ink,
      surfaceContainerHighest: AppColors.surfaceAlt,
      onSurfaceVariant: AppColors.inkSub,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      error: AppColors.error,
      onError: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
    );

    TextStyle t(double size, FontWeight w, {Color color = AppColors.ink, double? h, double spacing = 0}) =>
        TextStyle(
          fontFamily: _fontFamily,
          fontSize: size,
          fontWeight: w,
          color: color,
          height: h,
          letterSpacing: spacing,
        );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displaySmall: t(28, FontWeight.w700),
        headlineMedium: t(26, FontWeight.w700),
        headlineSmall: t(22, FontWeight.w700),
        titleLarge: t(18, FontWeight.w600),
        titleMedium: t(16, FontWeight.w600),
        titleSmall: t(15, FontWeight.w600),
        bodyLarge: t(15, FontWeight.w400, h: 1.5),
        bodyMedium: t(14, FontWeight.w400, color: AppColors.inkSub, h: 1.5),
        bodySmall: t(12, FontWeight.w400, color: AppColors.inkFaint),
        labelLarge: t(15, FontWeight.w600, color: Colors.white),
        labelMedium: t(13, FontWeight.w500, color: AppColors.inkSub),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: t(15, FontWeight.w400, color: AppColors.inkFaint),
        labelStyle: t(13, FontWeight.w500, color: AppColors.inkSub),
        floatingLabelStyle: t(13, FontWeight.w500, color: AppColors.primary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: t(16, FontWeight.w600, color: Colors.white),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: t(14, FontWeight.w600, color: AppColors.primary),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
    );
  }
}
