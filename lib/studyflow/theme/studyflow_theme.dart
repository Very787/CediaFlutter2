import 'package:flutter/material.dart';

class StudyFlowTheme {
  static const seed = Color(0xFF315C4C);
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
    return ThemeData(
      colorScheme: scheme, useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7F8F4),
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: const CardThemeData(margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
