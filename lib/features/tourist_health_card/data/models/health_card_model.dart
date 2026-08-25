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
    final contactJson = json['emergency_contact'] as Map<String, dynamic>?;
    return HealthCardModel(
      bloodType: json['blood_type'] as String? ?? '',
      allergies: json['allergies'] as String? ?? '',
      chronicDiseases: json['chronic_diseases'] as String? ?? '',
      additionalInfo: json['additional_info'] as String? ?? '',
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
