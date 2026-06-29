import 'package:flutter/material.dart';

class AppColors {
  // === Primary (зеленый — основной CTA) ===
  static const Color primary = Color(0xFF1B5E3A); // Темно-зеленый
  static const Color accent = Color(0xFF2DD4BF); // Бирюзовый вспомогательный

  // === Сигнальные ===
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);

  static const Color bgDark = Color(0xFF121212); // Основной фон
  static const Color cardDark = Color(0xFF1E1E1E); // Карточки
  static const Color bgElevated = Color(0xFF282828); // Bottom sheet / диалоги
  static const Color cardElevated = Color(0xFF2C2C2E); // Elevated card

  // === Разделители (вместо теней) ===
  static const Color borderDark = Color(0x1AFFFFFF); // ~10% белого
  static const Color borderSoft = Color(0x1AFFFFFF); // ~10% белого

  // === Текст ===
  static const Color textPrimary = Color(0xFFF5F5F5); // Основной текст
  static const Color textSecondary = Color(0x99F5F5F5); // 60% прозрачности
  static const Color textTertiary = Color(0x66F5F5F5); // 40% прозрачности
  static const Color textMuted = Color(0x4DF5F5F5); // 30% прозрачности

  static Color get primarySoft => primary.withValues(alpha: 0.2);
  static Color get accentSoft => accent.withValues(alpha: 0.2);

  // === Тема ===
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
      error: error,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: textPrimary,
        fontFamily: 'Inter',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        color: textPrimary,
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      displaySmall: TextStyle(
        color: textPrimary,
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        color: textPrimary,
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: textSecondary,
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        color: textTertiary,
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
        letterSpacing: 0.4,
      ),
      labelSmall: TextStyle(
        color: textMuted,
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14), // 14px
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(double.infinity, 52), // Height 52px
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: primary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        side: const BorderSide(
          color: borderDark,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(double.infinity, 52),
      ),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // 16px
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      hintStyle: const TextStyle(
        color: textMuted,
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // 12px
        borderSide: const BorderSide(
          color: borderDark,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: borderDark,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: error,
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.all(16), // 16px
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: primarySoft,
      side: const BorderSide(
        color: borderDark,
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // 20px
      ),
      labelStyle: const TextStyle(
        color: textSecondary,
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      secondaryLabelStyle: const TextStyle(
        color: textPrimary,
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardDark,
      selectedItemColor: primary,
      unselectedItemColor: textSecondary,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(
      color: borderSoft,
      thickness: 1,
      space: 0,
    ),
  );
}