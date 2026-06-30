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

  // Auth Tourist
  static String get sendOtp => '$baseUrl/tourist/login/register';
  static String get verifyOtp => '$baseUrl/tourist/login/verify';
  static String get registerOtp => '$baseUrl/tourist/login/register';

  // Locations
  static String get reels => '$baseUrl/locations/reels';
  static String locationDetail(String id) => '$baseUrl/locations/$id';

  // Tours
  static String get tours => '$baseUrl/tours';

  static String get guides => '$baseUrl/guides';
  static String get guideLogin => '$guides/login';
  static String get guideLoginVerify => '$guides/login/verify';
  static String get guideRegister => '$guides/register';
  static String get guideVerify => '$guides/verify';
  static String get guideResendSms => '$guides/resend-sms';

  static String get guideProfileVerify => '$guides/profile/verify';

  static String get guideTours => '$baseUrl/guides/tours';
  static String get guideToursPromoVideo => '$baseUrl/guides/tours/promo-video';
  static String locationTours(String locationId) =>
      '$baseUrl/locations/$locationId/tours';
  static String tourDetail(String tourId) => '$baseUrl/tours/$tourId';

  // PATCH профиля и аватар
  static String get guideProfile => '$guides/profile';
  static String get guideAvatar => '$guides/profile/avatar';
  static String get guideMe => '$guides/me';

  static void logEndpoints() {
    if (kDebugMode) {
      debugPrint('🌐 Base URL: $baseUrl');
      debugPrint('🌐 Guide Login: $guideLogin');
      debugPrint('🌐 Guide Register: $guideRegister');
      debugPrint('🌐 Guide Verify: $guideVerify');
      debugPrint('🌐 Guide Profile Verify: $guideProfileVerify');
    }
  }
}
