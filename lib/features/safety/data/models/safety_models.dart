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

// 🔥 ВОЗВРАЩАЕМ AppInfo — нужен для DigitalToolboxBlock
class AppInfo {
  const AppInfo({
    required this.name,
    required this.description,
    required this.packageName,
    required this.appStoreId,
    required this.color,
    required this.category,
    required this.fallbackUrl,
    this.assetPath,
  });

  final String name;
  final String description;
  final String packageName;
  final String appStoreId;
  final Color color;
  final String category;
  final String fallbackUrl;
  final String? assetPath;
}

// 🔥 ОБНОВЛЁННЫЙ OperatorInfo с url и assetPath
class OperatorInfo {
  const OperatorInfo({
    required this.name,
    required this.coverage,
    required this.color,
    required this.url,
    this.assetPath,
  });

  final String name;
  final String coverage;
  final Color color;
  final String url;
  final String? assetPath;
}

class Phrase {
  const Phrase({
    required this.kyrgyz,
    required this.russian,
    required this.transcription,
    required this.icon,
  });

  final String kyrgyz;
  final String russian;
  final String transcription;
  final IconData icon;
}

class FaqCategory {
  const FaqCategory({
    required this.icon,
    required this.title,
    required this.color,
    required this.questions,
  });

  final IconData icon;
  final String title;
  final Color color;
  final List<FaqQuestion> questions;
}

class FaqQuestion {
  const FaqQuestion({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}

class SafetyTip {
  const SafetyTip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.priority = 0,
  });

  final String id;
  final String title;
  final String content;
  final SafetyCategory category;
  final int priority;
}
