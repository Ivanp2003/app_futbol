import 'package:flutter/material.dart';
import 'world_cup_colors.dart';

class AppTheme {
  static ThemeData buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: WorldCupColors.magenta,
        primary: WorldCupColors.magenta,
        secondary: WorldCupColors.blue,
        surface: WorldCupColors.bg,
      ),
      scaffoldBackgroundColor: WorldCupColors.bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: WorldCupColors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  // Mantener compatibilidad con los métodos lightTheme y darkTheme usados previamente
  static ThemeData get lightTheme => buildAppTheme();
  static ThemeData get darkTheme => buildAppTheme().copyWith(
        brightness: Brightness.dark,
      );
}
