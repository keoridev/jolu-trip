import 'package:flutter/material.dart';
import 'package:jolutrip_app/features/safety/data/models/safety_models.dart';

class SafetyLocalDataSource {
  static const List<EmergencyContact> emergencyContacts = [
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

  static const List<AppInfo> essentialApps = [
    AppInfo(
      name: '2GIS',
      description: 'Офлайн-карты городов Кыргызстана',
      packageName: 'ru.dublgis.dgismobile',
      appStoreId: '481627534',
      color: Color(0xFF2688EB),
      category: 'Навигация',
      fallbackUrl: 'https://2gis.kg',
      assetPath: 'assets/icons/2gis.png',
    ),
    AppInfo(
      name: 'Maps.me',
      description: 'Топографические карты, работают без интернета',
      packageName: 'com.mapswithme.maps.pro',
      appStoreId: '510623322',
      color: Color(0xFF00A651),
      category: 'Навигация',
      fallbackUrl: 'https://maps.me',
      assetPath: 'assets/icons/maps.png',
    ),
    AppInfo(
      name: 'MBANK',
      description: 'Мобильный банкинг, переводы, оплата',
      packageName: 'kg.mbank.app',
      appStoreId: '1500379424',
      color: Color(0xFF00A651),
      category: 'Финансы',
      fallbackUrl: 'https://mbank.kg',
      assetPath: 'assets/icons/mbank.png',
    ),
    AppInfo(
      name: 'Элсом',
      description: 'Электронный кошелёк Кыргызстана',
      packageName: 'kg.elsom',
      appStoreId: '1446723496',
      color: Color(0xFFFF6B00),
      category: 'Финансы',
      fallbackUrl: 'https://elsom.kg',
      assetPath: 'assets/icons/elsom.png',
    ),
    AppInfo(
      name: 'Yandex Go',
      description: 'Такси в Бишкеке и Оше',
      packageName: 'ru.yandex.taxi',
      appStoreId: '472650686',
      color: Color(0xFFFFD700),
      category: 'Транспорт',
      fallbackUrl: 'https://go.yandex',
      assetPath: 'assets/icons/yandex.png',
    ),
    AppInfo(
      name: 'Namba Taxi',
      description: 'Локальное такси, дешевле Yandex',
      packageName: 'kg.nambataxi',
      appStoreId: '1451605081',
      color: Color(0xFFE31E24),
      category: 'Транспорт',
      fallbackUrl: 'https://nambataxi.kg',
      assetPath: 'assets/icons/namba_taxi.png',
    ),
  ];

  static const List<OperatorInfo> operators = [
    OperatorInfo(
      name: 'O!',
      coverage: 'Ала-Арча, Чункурчак, Иссык-Куль',
      color: Color(0xFFE31E24),
      url: 'https://o.kg/ru/',
      assetPath: 'assets/icons/o.png',
    ),
    OperatorInfo(
      name: 'MegaCom',
      coverage: 'Бишкек, Нарын, Талас',
      color: Color(0xFF2688EB),
      url: 'https://www.megacom.kg/ru/',
      assetPath: 'assets/icons/mega.jpg',
    ),
    OperatorInfo(
      name: 'Beeline',
      coverage: 'Дальние ущелья, заповедники',
      color: Color(0xFFFFD700),
      url: 'https://beeline.kg/ru/',
      assetPath: 'assets/icons/beeline.png',
    ),
  ];

  static const List<FaqCategory> faqCategories = [
    FaqCategory(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Деньги и оплата',
      color: Color(0xFF00A651),
      questions: [
        FaqQuestion(
          question: 'Где менять валюту?',
          answer:
              'Обменники в центре Бишкека, банки, иногда в отелях. Курс лучше в частных обменниках.',
        ),
        FaqQuestion(
          question: 'Работают ли карты?',
          answer:
              'Visa/MC в крупных городах. В горах — строго наличные сомы. Снимайте заранее.',
        ),
      ],
    ),
    FaqCategory(
      icon: Icons.sim_card_outlined,
      title: 'Связь и интернет',
      color: Color(0xFF2688EB),
      questions: [
        FaqQuestion(
          question: 'Какую SIM купить?',
          answer:
              'O!, Mega, Beeline — в аэропорту Манас и в городе. Для гор Mega или Beeline.',
        ),
        FaqQuestion(
          question: 'Есть ли 4G в горах?',
          answer:
              'В городах да, в горах перебои. Скачайте офлайн-карты заранее.',
        ),
      ],
    ),
    FaqCategory(
      icon: Icons.diversity_3_outlined,
      title: 'Этикет и традиции',
      color: Color(0xFFFFA500),
      questions: [
        FaqQuestion(
          question: 'Как одеваться?',
          answer:
              'В городах свободно, в селах и мечетях скромнее. Плечи и колени прикрыты.',
        ),
        FaqQuestion(
          question: 'Правила в юртах',
          answer:
              'Не наступайте на порог. Примите угощение — отказ оскорбляет хозяев.',
        ),
      ],
    ),
  ];

  static const List<SafetyTip> safetyTips = [
    SafetyTip(
      id: 'altitude',
      title: 'Горная болезнь',
      content:
          'Выше 2500м может заболеть голова. Пейте больше воды, исключите алкоголь, не делайте резких рывков. В аптечке — цитрамон/аспирин.',
      category: SafetyCategory.health,
      priority: 1,
    ),
    SafetyTip(
      id: 'cash',
      title: 'Наличные vs Карта',
      content:
          'В горах терминалов нет. За вход в заповедники, у чабанов, на заправках — только наличные сомы. Снимайте в городе.',
      category: SafetyCategory.practical,
      priority: 2,
    ),
    SafetyTip(
      id: 'offroad',
      title: 'Этикет джиперов',
      content:
          'Увидел машину с открытым капотом — остановись. В горах Кыргызстана взаимовыручка — неписаный закон.',
      category: SafetyCategory.practical,
      priority: 3,
    ),
  ];

  static const List<ChecklistItem> preTripChecklist = [
    ChecklistItem(
      id: 'cash',
      title: 'Наличные сомы (в горах карты не работают)',
      icon: Icons.payments_outlined,
      color: Color(0xFF00A651),
    ),
    ChecklistItem(
      id: 'powerbank',
      title: 'Пауэрбанк (10 000+ мАч)',
      icon: Icons.battery_charging_full_outlined,
      color: Color(0xFFFFA500),
    ),
    ChecklistItem(
      id: 'water',
      title: 'Вода (минимум 1.5л на человека)',
      icon: Icons.water_drop_outlined,
      color: Color(0xFF2688EB),
    ),
    ChecklistItem(
      id: 'warm_clothes',
      title: 'Теплая куртка/ветровка (погода меняется резко)',
      icon: Icons.checkroom_outlined,
      color: Color(0xFF9C27B0),
    ),
    ChecklistItem(
      id: 'offline_maps',
      title: 'Скачаны офлайн-карты (2GIS / Maps.me)',
      icon: Icons.map_outlined,
      color: Color(0xFFE31E24),
    ),
    ChecklistItem(
      id: 'sun_protection',
      title: 'Очки и крем от солнца (в горах солнце агрессивнее)',
      icon: Icons.wb_sunny_outlined,
      color: Color(0xFFFFD700),
    ),
  ];
}
