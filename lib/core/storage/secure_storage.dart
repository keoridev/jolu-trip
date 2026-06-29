import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _phoneKey = 'user_phone';
  static const String _nameKey = 'user_name';
  static const String _avatarKey = 'user_avatar';
  static const String _roleKey = 'user_role';
  static const String _guideDataKey = 'guide_data';
  static const String _onboardingDataKey = 'onboarding_data';

  static final _authController = StreamController<void>.broadcast();
  static Stream<void> get authChanges => _authController.stream;

  static Future<void> saveAuthData({
    required String token,
    required String userId,
    required String phone,
    String? name,
    String? avatarUrl,
    String? role,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _phoneKey, value: phone);
    
    if (name != null) {
      await _storage.write(key: _nameKey, value: name);
    }
    if (avatarUrl != null) {
      await _storage.write(key: _avatarKey, value: avatarUrl);
    }
    if (role != null) {
      await _storage.write(key: _roleKey, value: role);
      debugPrint('🔑 Saved role: $role');
    }
    
    _authController.add(null);
  }

  // 🔥 МЕТОДЫ ДЛЯ ГИДА
  static Future<void> saveGuideData(GuideEntity guide) async {
    final json = {
      'id': guide.id,
      'fullName': guide.fullName,
      'phone': guide.phone,
      'gender': guide.gender.name,
      'avatarUrl': guide.avatarUrl,
      'status': guide.status.name,
      'createdAt': guide.createdAt.toIso8601String(),
    };
    await _storage.write(key: _guideDataKey, value: jsonEncode(json));
    debugPrint('🔑 Saved guide data: ${guide.fullName}');
  }

  static Future<GuideEntity?> getGuideData() async {
    try {
      final data = await _storage.read(key: _guideDataKey);
      if (data == null) return null;
      final json = jsonDecode(data) as Map<String, dynamic>;
      
      return GuideEntity(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        phone: json['phone'] as String,
        gender: json['gender'] == 'male' ? GuideGender.male : GuideGender.female,
        avatarUrl: json['avatarUrl'] as String?,
        status: _parseStatus(json['status'] as String?),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
    } catch (e) {
      debugPrint('❌ Error getting guide data: $e');
      return null;
    }
  }

  static GuideStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return GuideStatus.pending;
      case 'verified':
        return GuideStatus.verified;
      case 'rejected':
        return GuideStatus.rejected;
      default:
        return GuideStatus.unverified;
    }
  }

  static Future<void> saveOnboardingData(OnboardingEntity onboarding) async {
    final json = {
      'experienceYears': onboarding.experienceYears,
      'carModel': onboarding.carModel,
      'carNumber': onboarding.carNumber,
      'languages': onboarding.languages,
      'passportMainPhotoUrl': onboarding.passportMainPhotoUrl,
      'passportRegistrationPhotoUrl': onboarding.passportRegistrationPhotoUrl,
      'licensePhotoFrontUrl': onboarding.licensePhotoFrontUrl,
      'licensePhotoBackUrl': onboarding.licensePhotoBackUrl,
      'carPhotosUrls': onboarding.carPhotosUrls,
      'presentationVideoUrl': onboarding.presentationVideoUrl,
      'status': onboarding.status,
      'fullName': onboarding.fullName,
      'phone': onboarding.phone,
    };
    await _storage.write(key: _onboardingDataKey, value: jsonEncode(json));
    debugPrint('🔑 Saved onboarding data');
  }

  static Future<OnboardingEntity?> getOnboardingData() async {
    try {
      final data = await _storage.read(key: _onboardingDataKey);
      if (data == null) return null;
      final json = jsonDecode(data) as Map<String, dynamic>;
      
      return OnboardingEntity(
        experienceYears: json['experienceYears'] as int,
        carModel: json['carModel'] as String,
        carNumber: json['carNumber'] as String,
        languages: (json['languages'] as List<dynamic>).cast<String>(),
        passportMainPhotoUrl: json['passportMainPhotoUrl'] as String?,
        passportRegistrationPhotoUrl: json['passportRegistrationPhotoUrl'] as String?,
        licensePhotoFrontUrl: json['licensePhotoFrontUrl'] as String?,
        licensePhotoBackUrl: json['licensePhotoBackUrl'] as String?,
        carPhotosUrls: (json['carPhotosUrls'] as List<dynamic>?)?.cast<String>(),
        presentationVideoUrl: json['presentationVideoUrl'] as String?,
        status: json['status'] as String?,
        fullName: json['fullName'] as String?,
        phone: json['phone'] as String?,
      );
    } catch (e) {
      debugPrint('❌ Error getting onboarding data: $e');
      return null;
    }
  }

  // Базовые геттеры
  static Future<String?> getToken() => _storage.read(key: _tokenKey);
  static Future<String?> getUserId() => _storage.read(key: _userIdKey);
  static Future<String?> getPhone() => _storage.read(key: _phoneKey);
  static Future<String?> getName() => _storage.read(key: _nameKey);
  static Future<String?> getAvatar() => _storage.read(key: _avatarKey);
  static Future<String?> getRole() {
    debugPrint('🔍 Getting role from storage');
    return _storage.read(key: _roleKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
    _authController.add(null);
    debugPrint('🔑 Cleared all storage');
  }

  static void dispose() {
    _authController.close();
  }
}