import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors
  static const primary = Color(0xFF2D7A2D);
  static const primaryDark = Color(0xFF1A4A1A);
  static const primaryLight = Color(0xFFE8F5E8);
  static const surface = Color(0xFFF7FAF5);
  static const cardBg = Color(0xFFFFFFFF);

  // Status colors
  static const pending = Color(0xFFE65100);
  static const pendingBg = Color(0xFFFFF3E0);
  static const inProgress = Color(0xFF0D47A1);
  static const inProgressBg = Color(0xFFE3F2FD);
  static const resolved = Color(0xFF1B5E20);
  static const resolvedBg = Color(0xFFE8F5E9);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: surface,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: cardBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Color(0xFF1A3A1A),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green.shade100, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
