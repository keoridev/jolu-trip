import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';
import 'package:jolutrip_app/features/guide_auth/data/models/model.dart';
import 'package:jolutrip_app/features/guide_onboarding/data/models/model.dart';

class GuideProfileModel extends GuideProfileEntity {
  const GuideProfileModel({
    required super.guide,
    super.onboarding,
    super.rejectionReason,
  });

  factory GuideProfileModel.fromJson(Map<String, dynamic> json) {
    // Парсим GuideEntity из корня ответа
    final guide = GuideModel.fromJson(json);

    // Парсим onboarding-данные из тех же полей (на том же уровне)
    final onboarding = _hasOnboardingData(json)
        ? OnboardingModel.fromJson(json)
        : null;

    return GuideProfileModel(
      guide: guide,
      onboarding: onboarding,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  static bool _hasOnboardingData(Map<String, dynamic> json) {
    return json['car_model'] != null ||
           json['car_number'] != null ||
           json['experience_years'] != null;
  }
}