import 'package:flutter/material.dart';

abstract final class AppColors {
  static const systemVoid = Color(0xFF050505);
  static const terminalSurface = Color(0xFF121212);
  static const containmentCyan = Color(0xFF00F0FF);
  static const mutedTeal = Color(0xFF008B94);
  static const systemErrorRed = Color(0xFFFF003C);
  static const hazardYellow = Color(0xFFFFF500);
  static const primaryText = Color(0xFFFFFFFF);
  static const dimmedText = Color(0xFF888888);
  static const gridline = Color(0xFF1A1A1A);
}

abstract final class AppTextStyles {
  static const _fontFamily = 'SpaceMono';

  static const countdownTimer = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 64,
    fontWeight: FontWeight.w700,
    color: AppColors.containmentCyan,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const screenHeader = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
  );

  static const button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
  );

  static const body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.dimmedText,
    height: 1.5,
  );
}

abstract final class AppSpacing {
  static const double xs = 8;
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 32;
  static const double xl = 48;
  static const double xxl = 64;
}

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.systemVoid,
    fontFamily: 'SpaceMono',
    colorScheme: const ColorScheme.dark(
      surface: AppColors.systemVoid,
      primary: AppColors.containmentCyan,
      error: AppColors.systemErrorRed,
    ),
    textTheme: const TextTheme(
      headlineLarge: AppTextStyles.screenHeader,
      bodyMedium: AppTextStyles.body,
      labelLarge: AppTextStyles.button,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.systemVoid,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.primaryText),
      titleTextStyle: TextStyle(
        fontFamily: 'SpaceMono',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryText,
      ),
    ),
  );
}
