import 'package:equatable/equatable.dart';

class GuideProfileEntity extends Equatable {
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
    this.experienceYears = 0,
    this.languages = const [],
    required this.status,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  bool get isVerified => status == 'verified';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get canEdit => isVerified || isRejected;

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
      carNumber: carNumber ?? this.carNumber,
      experienceYears: experienceYears ?? this.experienceYears,
      languages: languages ?? this.languages,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
      ];
}