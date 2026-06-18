import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';

class OnboardingModel extends OnboardingEntity {
  const OnboardingModel({
    required super.experienceYears,
    required super.carModel,
    required super.carNumber,
    required super.languages,
    super.passportScanUrl,
    super.licensePhotoUrl,
    super.carPhotosUrls,
    super.status,
    super.fullName,
    super.phone,
  });

  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    return OnboardingModel(
      experienceYears: json['experience_years'] as int? ?? 0,
      carModel: json['car_model'] as String? ?? '',
      carNumber: json['car_number'] as String? ?? '',
      languages: (json['languages'] as List<dynamic>?)?.cast<String>() ?? [],
      passportScanUrl: json['passport_scan_url'] as String?,
      licensePhotoUrl: json['license_photo_url'] as String?,
      carPhotosUrls: (json['car_photos_urls'] as List<dynamic>?)
          ?.cast<String>(),
      status: json['status'] as String? ?? 'pending',
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
    );
  }
}
