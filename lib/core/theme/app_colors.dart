import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00FF66);
  static const Color accent = Color(0xFF00E5FF);

  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF1744);

  static const Color bgDark = Color(0xFF0A0A0A); // Глубокий черный для экрана
  static const Color cardDark = Color(0xFF141414); // Чуть светлее для карточек
  static const Color borderDark = Color(
    0xFF222222,
  ); // Для тонких стильных линий

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8A8F);

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
