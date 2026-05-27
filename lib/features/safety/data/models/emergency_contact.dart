class EmergencyContact {
  const EmergencyContact({
    required this.name,
    required this.phone,
    required this.description,
    this.isPrimary = false,
  });

  final String name;
  final String phone;
  final String description;
  final bool isPrimary;

  static const List<EmergencyContact> defaults = [
    EmergencyContact(
      name: 'МЧС Кыргызстана',
      phone: '112',
      description: 'Единая служба спасения',
      isPrimary: true,
    ),
    EmergencyContact(
      name: 'Скорая помощь',
      phone: '103',
      description: 'Медицинская помощь',
    ),
    EmergencyContact(
      name: 'Полиция',
      phone: '102',
      description: 'Правоохранительные органы',
    ),
  ];
}
