import 'package:flutter/material.dart';
import 'package:jolutrip_app/features/safety/data/models/models.dart';

class SafetyLocalDataSource {
  static const List<EmergencyContact> emergencyContacts =
      EmergencyContact.defaults;

  static const Map<String, dynamic> safetyContent = {
    'apps': [
      {
        'name': 'МЧС КР / 112',
        'description':
            'Официальное приложение МЧС. Селевая и лавинная опасность.',
        'icon': Icons.warning_amber_rounded,
      },
      {
        'name': '2GIS',
        'description': 'Офлайн-карты городов. Работает без интернета.',
        'icon': Icons.map_outlined,
      },
      {
        'name': 'Maps.me',
        'description':
            'Топографические карты для трекинга. Лучше Google в ущельях.',
        'icon': Icons.terrain_outlined,
      },
      {
        'name': 'Windy',
        'description': 'Прогноз погоды и ветра в горах.',
        'icon': Icons.air,
      },
    ],
    'operators': [
      {
        'name': 'MegaCom',
        'coverage': 'Ала-Арча, Чункурчак, Иссык-Куль',
        'color': Colors.blue,
      },
      {
        'name': 'O!',
        'coverage': 'Сон-Кул, Нарын, высокогорье',
        'color': Colors.orange,
      },
      {
        'name': 'Beeline',
        'coverage': 'Дальние ущелья, заповедники',
        'color': Colors.yellow,
      },
    ],
    'dressCode':
        'При посещении Иссык-Кульской, Нарынской или Ошской областей, а также священных мест (Дунганская мечеть в Караколе, Узгенский минарет) — прикрывайте плечи и колени. Женщинам в мечеть нужен платок.',
    'yurtRules': [
      'Никогда не наступай на порог юрты — это оскорбление хозяев',
      'Если угощают боорсоками или кымызом — прими хотя бы пригуби. Обидеть гостеприимство чабана — дурной тон',
    ],
    'ecoManifest': [
      'Унеси свой мусор с собой. Пластик в горах разлагается веками',
      'Не ломай краснокнижные цветы (Айгуль) и не пугай скот ради фоток',
    ],
    'phrases': [
      {
        'kyrgyz': 'Саламатсызбы!',
        'russian': 'Здравствуйте',
        'transcription': 'sa-la-mat-SYZ-by',
      },
      {
        'kyrgyz': 'Чон рахмат!',
        'russian': 'Большое спасибо',
        'transcription': 'chon rah-MAT',
      },
      {
        'kyrgyz': 'Бул канча турат?',
        'russian': 'Сколько стоит?',
        'transcription': 'bul KAN-cha tu-RAT',
      },
      {
        'kyrgyz': 'Суу барбы?',
        'russian': 'Есть вода?',
        'transcription': 'SUU bar-BY',
      },
      {
        'kyrgyz': 'Жол көрсөтүп коюңузчу',
        'russian': 'Покажите дорогу',
        'transcription': 'zhol kör-SÖ-tüp ko-YUN-guz-chu',
      },
      {
        'kyrgyz': 'Жакшы калыңыз!',
        'russian': 'До свидания',
        'transcription': 'zhak-SHY ka-LYNG-yz',
      },
    ],
  };
}
