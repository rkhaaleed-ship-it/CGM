import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const bg = Color(0xFF000000);
  static const bg2 = Color(0xFF0D0D0D);
  static const bg3 = Color(0xFF141414);
  static const border = Color(0xFF1E1E1E);
  static const border2 = Color(0xFF2A2A2A);
  static const text = Color(0xFFFFFFFF);
  static const text2 = Color(0xFFB0B0B0);
  static const text3 = Color(0xFF666666);
  static const red = Color(0xFFE53935);
  static const amber = Color(0xFFF5A623);
  static const green = Color(0xFF1D9E75);
  static const green2 = Color(0xFF4CAF50);
  static const yellow = Color(0xFFF5C518);
  static const blue = Color(0xFF3B82F6);
  static const blueLight = Color(0xFF60A5FA);
  static const predColor = Color(0xFFEF5350);
}

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    const textTheme = TextTheme(
      bodyMedium: TextStyle(color: AppColors.text2, fontSize: 13),
      titleMedium: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600),
      headlineLarge: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700),
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      primaryColor: AppColors.red,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.red,
        secondary: AppColors.amber,
        surface: AppColors.bg3,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        centerTitle: false,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.border2,
        inactiveTrackColor: AppColors.border2,
        thumbColor: Colors.white,
        overlayColor: Colors.white.withValues(alpha: 0.1),
        trackHeight: 3,
      ),
    );
  }
}
