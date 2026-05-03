import 'package:flutter/material.dart';

import 'app_colours.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColours.seed,
          brightness: Brightness.light,
          surface: AppColours.surface,
        ).copyWith(
          primary: AppColours.primary,
          secondary: AppColours.secondary,
          onSurface: AppColours.charcoal,
          outline: AppColours.outline,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColours.background,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColours.surface,
        foregroundColor: AppColours.charcoal,
      ),
      cardTheme: CardThemeData(
        color: AppColours.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColours.outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColours.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColours.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColours.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColours.primary, width: 1.4),
        ),
      ),
      dividerColor: AppColours.outline,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColours.surface,
        indicatorColor: AppColours.primary.withValues(alpha: 0.16),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 72,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColours.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColours.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColours.charcoal,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColours.charcoal,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColours.charcoal,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColours.charcoal,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColours.charcoal,
        ),
        bodyMedium: TextStyle(color: AppColours.charcoal, height: 1.35),
        bodySmall: TextStyle(color: AppColours.mutedText, height: 1.35),
      ),
    );
  }

  static ThemeData get dark {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColours.darkPrimary,
          brightness: Brightness.dark,
          surface: AppColours.darkSurface,
        ).copyWith(
          primary: AppColours.darkPrimary,
          secondary: AppColours.darkSecondary,
          tertiary: AppColours.darkAccent,
          onPrimary: AppColours.darkBackground,
          onSurface: AppColours.darkText,
          outline: AppColours.darkOutline,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColours.darkBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColours.darkSurface,
        foregroundColor: AppColours.darkText,
      ),
      cardTheme: CardThemeData(
        color: AppColours.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColours.darkOutline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColours.darkSurfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColours.darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColours.darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColours.darkPrimary,
            width: 1.4,
          ),
        ),
      ),
      dividerColor: AppColours.darkOutline,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColours.darkSurface,
        indicatorColor: AppColours.darkPrimary.withValues(alpha: 0.18),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 74,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColours.darkPrimary,
          foregroundColor: AppColours.darkBackground,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColours.darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColours.darkSurfaceAlt,
        contentTextStyle: const TextStyle(color: AppColours.darkText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColours.darkText,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColours.darkText,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColours.darkText,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColours.darkText,
        ),
        bodyMedium: TextStyle(color: AppColours.darkText, height: 1.35),
        bodySmall: TextStyle(color: AppColours.darkMutedText, height: 1.35),
      ),
    );
  }
}
