import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00FF66);
  static const Color accent = Color(0xFF00E5FF);

  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF1744);

  static const Color bgDark = Color(0xFF0A0A0A);
  static const Color cardDark = Color(0xFF141414);
  static const Color bgElevated = Color(0xFF1A1A1A);
  static const Color cardElevated = Color(0xFF1E1E1E);

  static const Color borderDark = Color(0xFF222222);
  static const Color borderSoft = Color(0xFF2A2A2A);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8A8F);
  static const Color textTertiary = Color(0xFF6C6C70);
  static const Color textMuted = Color(0xFF48484A);


  static Color get primarySoft => primary.withOpacity(0.3);
  static Color get accentSoft => accent.withOpacity(0.3);
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    cardColor: cardDark,
    primaryColor: primary,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: cardDark,
      background: bgDark,
      error: error,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary, fontFamily: 'Inter'),
      bodyMedium: TextStyle(color: textSecondary, fontFamily: 'Inter'),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.black,

        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
