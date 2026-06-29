import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';

class GuideProfileEntity {
  final GuideEntity guide;
  final OnboardingEntity? onboarding;
  final String? rejectionReason;

  const GuideProfileEntity({
    required this.guide,
    this.onboarding,
    this.rejectionReason,
  });

  bool get isPending => guide.isPending;
  bool get isVerified => guide.isVerified;
  bool get isRejected => guide.status == GuideStatus.rejected;
  bool get canEdit => isVerified || isRejected;

  GuideProfileEntity copyWith({
    GuideEntity? guide,
    OnboardingEntity? onboarding,
    String? rejectionReason,
  }) {
    return GuideProfileEntity(
      guide: guide ?? this.guide,
      onboarding: onboarding ?? this.onboarding,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
