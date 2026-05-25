import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.avatarUrl,
    this.healthCard,
    required this.ecoPoints,
    this.achievements,
    required this.createdAt,
  });
  final String id;
  final String fullName;
  final String phone;
  final String avatarUrl;
  final Map<String, dynamic>? healthCard;
  final int ecoPoints;
  final List<dynamic>? achievements;
  final DateTime createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String,
      avatarUrl: json['avatar_url'] as String? ?? '',
      healthCard: json['health_card'] as Map<String, dynamic>?,
      ecoPoints: json['eco_points'] as int? ?? 0,
      achievements: json['achievements'] as List<dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'health_card': healthCard,
      'eco_points': ecoPoints,
      'achievements': achievements,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? avatarUrl,
    Map<String, dynamic>? healthCard,
    int? ecoPoints,
    List<dynamic>? achievements,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      healthCard: healthCard ?? this.healthCard,
      ecoPoints: ecoPoints ?? this.ecoPoints,
      achievements: achievements ?? this.achievements,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    phone,
    avatarUrl,
    healthCard,
    ecoPoints,
    achievements,
    createdAt,
  ];
}

class AuthResponse {
  final String status;
  final String token;
  final UserModel user;

  const AuthResponse({
    required this.status,
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] as String,
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
