import 'package:flutter/material.dart';

class AppColors {
  static const white = Colors.white;
  static const buttonBlue = Color(0xFF3F6FD8);
  static const header = Color(0xFF1F2F66); //navy

  static const blue = Color(0xFF3F63B8); //blue
  static const background = Color(0xFFDCE6F8); //paleblue
}

// Builds the ThemeData given to MaterialApp
// Widgets pick up their design from here unless overriden in screen
class AppTheme {
  static const AppBarTheme _appBar = AppBarTheme(
    backgroundColor: AppColors.header,
    foregroundColor: AppColors.white,
    toolbarHeight: 72,
  );

  static final ElevatedButtonThemeData _elevatedButton =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      );

  static final ColorScheme _colors = ColorScheme.fromSeed(
    seedColor: AppColors.blue,
    primary: AppColors.blue,
  );

  // New theme design goes here and add into ThemeData parameter

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _colors,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: _appBar,
      elevatedButtonTheme: _elevatedButton,
    );
  }
}
