// lib/core/config/app_config.dart

import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://api.jolutrip.com/api/v1';
    }
    return 'http://13.62.223.118/api/v1';
  }

  // Auth
  static String get sendOtp => '$baseUrl/tourist/login/register';
  static String get verifyOtp => '$baseUrl/tourist/login/verify';
  static String get registerOtp => '$baseUrl/tourist/login/register';

  // Locations
  static String get reels => '$baseUrl/locations/reels';
  static String locationDetail(String id) =>
      '$baseUrl/locations/$id'; 

  // Tours & Guides
  static String get tours => '$baseUrl/tours';
  static String get guides => '$baseUrl/guides';

  static void logEndpoints() {
    if (kDebugMode) {
      debugPrint('🌐 Base URL: $baseUrl');
      debugPrint('🌐 Send OTP: $sendOtp');
      debugPrint('🌐 Verify OTP: $verifyOtp');
      debugPrint('🌐 Reels: $reels');
    }
  }
}
