class OnboardingEntity {
  final int experienceYears;
  final String carModel;
  final String carNumber;
  final List<String> languages;
  final String? passportScanUrl;
  final String? licensePhotoUrl;
  final List<String>? carPhotosUrls;
  final String? status;
  final String? fullName; // Добавляем
  final String? phone; // Добавляем

  const OnboardingEntity({
    required this.experienceYears,
    required this.carModel,
    required this.carNumber,
    required this.languages,
    this.passportScanUrl,
    this.licensePhotoUrl,
    this.carPhotosUrls,
    this.status,
    this.fullName,
    this.phone,
  });
}
