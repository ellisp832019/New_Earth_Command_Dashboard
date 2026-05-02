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
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColours.background,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColours.background,
        foregroundColor: AppColours.charcoal,
      ),
      cardTheme: CardThemeData(
        color: AppColours.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColours.outline),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColours.surface,
        indicatorColor: AppColours.primary.withValues(alpha: 0.16),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColours.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textTheme: const TextTheme(
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
}
