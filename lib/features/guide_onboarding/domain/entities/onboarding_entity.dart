class OnboardingEntity {
  final int experienceYears;
  final String carCategory;
  final String carModel;
  final String carNumber;
  final List<String> languages;
  final int carSeats;
  final int carYear;
  final String steeringWheel;
  final List<String> carFeatures;
  final String? passportMainPhotoUrl;
  final String? passportRegistrationPhotoUrl;
  final String? licensePhotoFrontUrl;
  final String? licensePhotoBackUrl;
  final List<String>? carPhotosUrls;
  final String? presentationVideoUrl;
  final String? status;
  final String? fullName;
  final String? phone;
  final String? newToken; // ← новый токен

  const OnboardingEntity({
    required this.experienceYears,
    required this.carModel,
    required this.carNumber,
    required this.languages,
    required this.carCategory,
    required this.carSeats,
    required this.carYear,
    required this.steeringWheel,
    required this.carFeatures,
    this.passportMainPhotoUrl,
    this.passportRegistrationPhotoUrl,
    this.licensePhotoFrontUrl,
    this.licensePhotoBackUrl,
    this.carPhotosUrls,
    this.presentationVideoUrl,
    this.status,
    this.fullName,
    this.phone,
    this.newToken,
  });
}
