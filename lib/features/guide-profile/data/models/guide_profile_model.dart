import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';

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
  final int experienceYears;
  final List<String> languages;
  final String status;
  final String? rejectionReason;
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
    this.experienceYears = 0,
    this.languages = const [],
    required this.status,
    this.rejectionReason,
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
      experienceYears: (json['experience_years'] as num?)?.toInt() ?? 0,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      status: json['status'] as String,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'gender': gender,
      'avatar_url': avatarUrl,
      'presentation_video_url': presentationVideoUrl,
      'car_category': carCategory,
      'car_model': carModel,
      'car_number': carNumber,
      'experience_years': experienceYears,
      'languages': languages,
      'status': status,
      'rejection_reason': rejectionReason,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
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
        experienceYears: experienceYears,
        languages: languages,
        status: status,
        rejectionReason: rejectionReason,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}