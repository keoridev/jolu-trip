import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';

class OnboardingModel extends OnboardingEntity {
  final String? newToken; // ← новый токен от backend

  const OnboardingModel({
    required super.experienceYears,
    required super.carModel,
    required super.carNumber,
    required super.languages,
    super.passportMainPhotoUrl,
    super.passportRegistrationPhotoUrl,
    super.licensePhotoFrontUrl,
    super.licensePhotoBackUrl,
    super.carPhotosUrls,
    super.presentationVideoUrl,
    super.status,
    super.fullName,
    super.phone,
    this.newToken,
  });

  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    return OnboardingModel(
      experienceYears: json['experience_years'] as int? ?? 0,
      carModel: json['car_model'] as String? ?? '',
      carNumber: json['car_number'] as String? ?? '',
      languages: (json['languages'] as List<dynamic>?)?.cast<String>() ?? [],
      passportMainPhotoUrl: json['passport_main_photo_url'] as String?,
      passportRegistrationPhotoUrl: json['passport_registration_photo_url'] as String?,
      licensePhotoFrontUrl: json['license_photo_front_url'] as String?,
      licensePhotoBackUrl: json['license_photo_back_url'] as String?,
      carPhotosUrls: (json['car_photos_urls'] as List<dynamic>?)?.cast<String>(),
      presentationVideoUrl: json['presentation_video_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      newToken: json['new_token'] as String?, // ← парсим новый токен
    );
  }
}