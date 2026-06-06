import 'package:flutter/material.dart';

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

class GpsCoordinates {
  GpsCoordinates({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final DateTime timestamp;

  String get decimal =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  String get dms => '${_toDms(latitude)} N, ${_toDms(longitude)} E';

  String _toDms(double decimal) {
    final degrees = decimal.abs().floor();
    final minutesFull = (decimal.abs() - degrees) * 60;
    final minutes = minutesFull.floor();
    final seconds = ((minutesFull - minutes) * 60).toStringAsFixed(1);
    return '$degrees° $minutes\' $seconds"';
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
  };

  factory GpsCoordinates.fromJson(Map<String, dynamic> json) => GpsCoordinates(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

enum SafetyCategory {
  preparation('Подготовка'),
  culture('Культура'),
  language('Язык'),
  health('Здоровье'),
  practical('Практика');

  final String title;
  const SafetyCategory(this.title);
}

class AppHint {
  const AppHint({
    required this.name,
    required this.description,
    required this.icon,
  });
  final String name;
  final String description;
  final IconData icon;
}

class OperatorInfo {
  const OperatorInfo({
    required this.name,
    required this.coverage,
    required this.color,
  });
  final String name;
  final String coverage;
  final Color color;
}

class Phrase {
  const Phrase({
    required this.kyrgyz,
    required this.russian,
    required this.transcription,
  });
  final String kyrgyz;
  final String russian;
  final String transcription;
}
