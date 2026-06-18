import 'package:flutter/material.dart';
import 'world_cup_colors.dart';

class AppTheme {
  static ThemeData buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: WorldCupColors.primary,
        primary: WorldCupColors.primary,
        secondary: WorldCupColors.accent,
        surface: WorldCupColors.bg,
      ),
      scaffoldBackgroundColor: WorldCupColors.bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: WorldCupColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  static ThemeData get lightTheme => buildAppTheme();
  static ThemeData get darkTheme => buildAppTheme().copyWith(
        brightness: Brightness.dark,
      );
}
