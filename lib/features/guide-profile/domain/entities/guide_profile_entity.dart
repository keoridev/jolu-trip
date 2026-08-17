import 'package:equatable/equatable.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';

class GuideProfileEntity extends Equatable {
  final String id;
  final String? fullName;
  final String? phone;
  final String? gender;
  final String? avatarUrl;
  final String? presentationVideoUrl;
  final String? carCategory;

  final int carSeats; // ← новое
  final int carYear; // ← новое
  final String steeringWheel; // ← новое
  final List<String> carFeatures;
  final String? carModel;
  final String? carNumber;
  final int experienceYears;
  final List<String> languages;
  final String status;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GuideProfileEntity({
    required this.id,
    this.fullName,
    this.phone,
    this.gender,
    this.avatarUrl,
    this.presentationVideoUrl,
    this.carCategory,
    this.carModel,
    this.carNumber,
    this.carSeats = 0,
    this.carYear = 0,
    this.steeringWheel = 'left',
    this.carFeatures = const [],
    this.experienceYears = 0,
    this.languages = const [],
    required this.status,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  // Backend возвращает "approved", не "verified"
  bool get isVerified => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get canEdit => isVerified || isRejected;

  bool get isOnboardingComplete {
    return fullName != null &&
        fullName!.isNotEmpty &&
        phone != null &&
        phone!.isNotEmpty &&
        gender != null &&
        gender!.isNotEmpty &&
        carModel != null &&
        carModel!.isNotEmpty &&
        carNumber != null &&
        carNumber!.isNotEmpty &&
        experienceYears > 0 &&
        languages.isNotEmpty;
  }

  GuideProfileEntity copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? gender,
    String? avatarUrl,
    String? presentationVideoUrl,
    String? carCategory,
    String? carModel,
    String? carNumber,
    int? carSeats, // ← новое
    int? carYear, // ← новое
    String? steeringWheel, // ← новое
    List<String>? carFeatures,
    int? experienceYears,
    List<String>? languages,
    String? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GuideProfileEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      presentationVideoUrl: presentationVideoUrl ?? this.presentationVideoUrl,
      carCategory: carCategory ?? this.carCategory,
      carModel: carModel ?? this.carModel,
      carSeats: carSeats ?? this.carSeats, // ← новое
      carYear: carYear ?? this.carYear, // ← новое
      steeringWheel: steeringWheel ?? this.steeringWheel, // ← новое
      carFeatures: carFeatures ?? this.carFeatures,
      carNumber: carNumber ?? this.carNumber,
      experienceYears: experienceYears ?? this.experienceYears,
      languages: languages ?? this.languages,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  OnboardingEntity toOnboarding() => OnboardingEntity(
    experienceYears: experienceYears,
    carModel: carModel ?? '',
    carCategory: carCategory ?? '', // ← новое

    carNumber: carNumber ?? '',
    languages: languages,
    passportMainPhotoUrl: null,
    passportRegistrationPhotoUrl: null,
    licensePhotoFrontUrl: null,
    carSeats: carSeats, // ← новое
    carYear: carYear, // ← новое
    steeringWheel: steeringWheel, // ← новое
    carFeatures: carFeatures,
    licensePhotoBackUrl: null,
    carPhotosUrls: null,
    presentationVideoUrl: presentationVideoUrl,
    status: status,
    fullName: fullName,
    phone: phone,
  );

  @override
  List<Object?> get props => [
    id,
    fullName,
    phone,
    gender,
    avatarUrl,
    presentationVideoUrl,
    carCategory,
    carModel,
    carNumber,
    experienceYears,
    languages,
    status,
    rejectionReason,
    createdAt,
    updatedAt,
    carSeats, // ← новое
    carYear, // ← новое
    steeringWheel, // ← новое
    carFeatures,
  ];
}
