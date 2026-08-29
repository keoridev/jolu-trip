import 'package:jolutrip_app/features/tourist_health_card/domain/entities/health_card_entity.dart';

class HealthCardModel extends HealthCardEntity {
  const HealthCardModel({
    super.bloodType,
    super.allergies,
    super.chronicDiseases,
    super.additionalInfo,
    super.emergencyContact,
  });

  factory HealthCardModel.fromJson(Map<String, dynamic> json) {
    // Бек может вернуть в двух форматах:
    // 1. Прямой объект: {"blood_type": "...", ...}
    // 2. Обёрнутый: {"health_card": {...}, "status": "ok"}
    final Map<String, dynamic> data;
    if (json.containsKey('health_card') && json['health_card'] is Map) {
      data = json['health_card'] as Map<String, dynamic>;
    } else {
      data = json;
    }

    final contactJson = data['emergency_contact'] as Map<String, dynamic>?;
    return HealthCardModel(
      bloodType: data['blood_type'] as String? ?? '',
      allergies: data['allergies'] as String? ?? '',
      chronicDiseases: data['chronic_diseases'] as String? ?? '',
      additionalInfo: data['additional_info'] as String? ?? '',
      emergencyContact: contactJson != null
          ? EmergencyContact(
              name: contactJson['name'] as String? ?? '',
              phone: contactJson['phone'] as String? ?? '',
            )
          : const EmergencyContact(name: '', phone: ''),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'blood_type': bloodType,
      'allergies': allergies,
      'chronic_diseases': chronicDiseases,
      'additional_info': additionalInfo,
      'emergency_contact': {
        'name': emergencyContact.name,
        'phone': emergencyContact.phone,
      },
    };
  }

  HealthCardEntity toEntity() => HealthCardEntity(
    bloodType: bloodType,
    allergies: allergies,
    chronicDiseases: chronicDiseases,
    additionalInfo: additionalInfo,
    emergencyContact: emergencyContact,
  );
}
