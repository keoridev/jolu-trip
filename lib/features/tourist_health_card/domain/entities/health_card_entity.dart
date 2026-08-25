import 'package:equatable/equatable.dart';

class EmergencyContact extends Equatable {
  final String name;
  final String phone;

  const EmergencyContact({required this.name, required this.phone});

  bool get isEmpty => name.isEmpty && phone.isEmpty;
  bool get isNotEmpty => !isEmpty;

  EmergencyContact copyWith({String? name, String? phone}) {
    return EmergencyContact(
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [name, phone];
}

class HealthCardEntity extends Equatable {
  final String bloodType;
  final String allergies;
  final String chronicDiseases;
  final String additionalInfo;
  final EmergencyContact emergencyContact;

  const HealthCardEntity({
    this.bloodType = '',
    this.allergies = '',
    this.chronicDiseases = '',
    this.additionalInfo = '',
    this.emergencyContact = const EmergencyContact(name: '', phone: ''),
  });

  /// Пустая карточка — для начального состояния формы
  static const empty = HealthCardEntity();

  bool get isEmpty =>
      bloodType.isEmpty &&
      allergies.isEmpty &&
      chronicDiseases.isEmpty &&
      additionalInfo.isEmpty &&
      emergencyContact.isEmpty;

  bool get isFilled => !isEmpty;

  HealthCardEntity copyWith({
    String? bloodType,
    String? allergies,
    String? chronicDiseases,
    String? additionalInfo,
    EmergencyContact? emergencyContact,
  }) {
    return HealthCardEntity(
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }

  @override
  List<Object?> get props => [
    bloodType,
    allergies,
    chronicDiseases,
    additionalInfo,
    emergencyContact,
  ];
}
