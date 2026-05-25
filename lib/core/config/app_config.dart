// lib/core/config/app_config.dart

import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  // 🔥 Только для браузера - localhost
  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://api.jolutrip.com/api/v1';
    }

    // Для всех платформ в режиме разработки используем localhost
    return 'http://localhost:8085/api/v1';
  }

  // Эндпоинты
  static String get sendOtp => '$baseUrl/tourist/login/register';
  static String get verifyOtp => '$baseUrl/tourist/login/verify';
  static String get registerOtp => '$baseUrl/tourist/login/register';
  static String get reels => '$baseUrl/reels';
  static String get tours => '$baseUrl/tours';
  static String get guides => '$baseUrl/guides';

  static void logEndpoints() {
    if (kDebugMode) {
      debugPrint('🌐 Base URL: $baseUrl');
      debugPrint('🌐 Send OTP: $sendOtp');
      debugPrint('🌐 Verify OTP: $verifyOtp');
    }
  }
}
