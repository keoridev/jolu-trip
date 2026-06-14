// lib/features/guide_auth/domain/entities/guide_entity.dart

enum GuideGender { male, female }

enum GuideStatus { unverified, pending, verified, rejected }

class GuideEntity {
  final String id;
  final String fullName;
  final String phone;
  final GuideGender gender;
  final String? avatarUrl;
  final GuideStatus status;
  final DateTime createdAt;

  // Onboarding fields (nullable until filled)
  final int? experienceYears;
  final String? carModel;
  final String? carNumber;
  final List<String>? languages;
  final String? passportScanUrl;
  final String? licensePhotoUrl;
  final List<String>? carPhotosUrls;

  const GuideEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.gender,
    this.avatarUrl,
    required this.status,
    required this.createdAt,
    this.experienceYears,
    this.carModel,
    this.carNumber,
    this.languages,
    this.passportScanUrl,
    this.licensePhotoUrl,
    this.carPhotosUrls,
  });

  bool get needsOnboarding =>
      status == GuideStatus.unverified || status == GuideStatus.rejected;

  bool get isPending => status == GuideStatus.pending;
  bool get isVerified => status == GuideStatus.verified;
}
