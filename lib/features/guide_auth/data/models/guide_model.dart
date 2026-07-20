import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';

class GuideModel extends GuideEntity {
  const GuideModel({
    required super.id,
    required super.fullName,
    required super.phone,
    required super.gender,
    super.avatarUrl,
    required super.status,
    required super.createdAt,
  });

  factory GuideModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['user_id'] as String? ?? '';
    if (id.isEmpty) throw FormatException('Missing id in response: $json');

    final rawStatus = json['status'] as String? ?? 'unverified';
    final status = _parseStatus(rawStatus);

    final fullName = json['full_name'] as String? ?? 'Гид JoLuTrip';
    final phone = json['phone'] as String? ?? '';
    final gender = _parseGender(json['gender'] as String?);
    final avatarUrl = json['avatar_url'] as String?;
    final createdAt = _parseDateTime(json['created_at']);

    return GuideModel(
      id: id,
      fullName: fullName,
      phone: phone,
      gender: gender,
      avatarUrl: avatarUrl,
      status: status,
      createdAt: createdAt,
    );
  }

  /// Парсит ответ login/verify — сервер возвращает те же поля + token
  factory GuideModel.fromLoginResponse(Map<String, dynamic> json) {
    // login/verify возвращает {token, id, full_name, phone, gender, status, ...}
    // или {token, user: {...}} — проверьте реальный ответ сервера
    final userData = json['user'] as Map<String, dynamic>? ?? json;
    return GuideModel.fromJson(userData);
  }

  static GuideGender _parseGender(String? value) => switch (value) {
    'female' => GuideGender.female,
    _ => GuideGender.male,
  };

  static GuideStatus _parseStatus(String? value) => switch (value) {
    'pending' => GuideStatus.pending,
    'verified' => GuideStatus.verified,
    'rejected' => GuideStatus.rejected,
    'created' || 'unverified' => GuideStatus.unverified,
    'successfully login' => GuideStatus.pending,
    _ => GuideStatus.unverified,
  };

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'phone': phone,
    'gender': switch (gender) {
      GuideGender.male => 'male',
      GuideGender.female => 'female',
    },
    'avatar_url': avatarUrl,
    'status': switch (status) {
      GuideStatus.unverified => 'unverified',
      GuideStatus.pending => 'pending',
      GuideStatus.verified => 'verified',
      GuideStatus.rejected => 'rejected',
    },
    'created_at': createdAt.toIso8601String(),
  };
}