import 'package:jolutrip_app/features/guide-profile/guide_profile.dart';

class GuideProfileModel {
  final String id;
  final String? fullName;
  final String? phone;
  final String? gender;
  final String? avatarUrl;
  final String? presentationVideoUrl;
  final String? carCategory;
  final String? carModel;
  final String? carNumber;
  final int carSeats; // ← новое
  final int carYear; // ← новое
  final String steeringWheel; // ← новое
  final List<String> carFeatures; // ← новое
  final List<String> carPhotos; // ← новое
  final int experienceYears;
  final List<String> languages;
  final String status;
  final int toursConducted; // ← новое
  final double averageRating; // ← новое
  final int reviewsCount; // ← новое
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GuideProfileModel({
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
    this.carPhotos = const [],
    this.experienceYears = 0,
    this.languages = const [],
    required this.status,
    this.toursConducted = 0,
    this.averageRating = 0.0,
    this.reviewsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory GuideProfileModel.fromJson(Map<String, dynamic> json) {
    return GuideProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      presentationVideoUrl: json['presentation_video_url'] as String?,
      carCategory: json['car_category'] as String?,
      carModel: json['car_model'] as String?,
      carNumber: json['car_number'] as String?,
      carSeats: json['car_seats'] as int? ?? 0,
      carYear: json['car_year'] as int? ?? 0,
      steeringWheel: json['steering_wheel'] as String? ?? 'left',
      carFeatures:
          (json['car_features'] as List<dynamic>?)?.cast<String>() ?? [],
      carPhotos: (json['car_photos'] as List<dynamic>?)?.cast<String>() ?? [],
      experienceYears: json['experience_years'] as int? ?? 0,
      languages: (json['languages'] as List<dynamic>?)?.cast<String>() ?? [],
      status: json['status'] as String? ?? 'unverified',
      toursConducted: json['tours_conducted'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  GuideProfileEntity toEntity() => GuideProfileEntity(
    id: id,
    fullName: fullName,
    phone: phone,
    gender: gender,
    avatarUrl: avatarUrl,
    presentationVideoUrl: presentationVideoUrl,
    carCategory: carCategory,
    carModel: carModel,
    carNumber: carNumber,
    carSeats: carSeats,
    carYear: carYear,
    steeringWheel: steeringWheel,
    carFeatures: carFeatures,
    experienceYears: experienceYears,
    languages: languages,
    status: status,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
