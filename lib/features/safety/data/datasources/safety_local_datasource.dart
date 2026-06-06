import 'package:flutter/material.dart';
import 'package:jolutrip_app/features/safety/data/models/safety_models.dart';

class SafetyLocalDataSource {
  static const List<EmergencyContact> emergencyContacts =
      EmergencyContact.defaults;

  static const List<AppInfo> essentialApps = [
    // Навигация
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
      assetPath: 'assets/icons/mapsme.png',
    ),
    AppInfo(
      name: 'Windy',
      description: 'Прогноз погоды и ветра в горах',
      packageName: 'com.windyty.android',
      appStoreId: '1161388052',
      color: Color(0xFF00B4D8),
      category: 'Погода',
      fallbackUrl: 'https://windy.com',
      assetPath: 'assets/icons/windy.png',
    ),

    // Финансы
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

    // Транспорт
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
      assetPath: 'assets/icons/namba.png',
    ),

    // Еда и жильё
    AppInfo(
      name: 'Namba Food',
      description: 'Доставка еды в Бишкеке',
      packageName: 'kg.nambafood.ios',
      appStoreId: '1451605081',
      color: Color(0xFFE31E24),
      category: 'Еда',
      fallbackUrl: 'https://nambafood.kg',
      assetPath: 'assets/icons/nambafood.png',
    ),
    AppInfo(
      name: 'Booking.com',
      description: 'Отели и гостевые дома',
      packageName: 'com.booking',
      appStoreId: '367003839',
      color: Color(0xFF003580),
      category: 'Жильё',
      fallbackUrl: 'https://booking.com',
      assetPath: 'assets/icons/booking.png',
    ),

    // Инструменты
    AppInfo(
      name: 'Переводчик',
      description: 'Google Translate — офлайн режим',
      packageName: 'com.google.android.apps.translate',
      appStoreId: '414706506',
      color: Color(0xFF4285F4),
      category: 'Инструменты',
      fallbackUrl: 'https://translate.google.com',
      assetPath: 'assets/icons/translate.png',
    ),
    AppInfo(
      name: 'Компас',
      description: 'Встроенный компас для ориентации',
      packageName: 'com.vincentlee.compass',
      appStoreId: '441338009',
      color: Color(0xFF8B4513),
      category: 'Инструменты',
      fallbackUrl: 'https://play.google.com',
      assetPath: 'assets/icons/compass.png',
    ),
  ];

  // 🔥 ДОБАВЛЕНЫ url и assetPath
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

  static const List<Phrase> phrases = [
    Phrase(
      kyrgyz: 'Саламатсызбы!',
      russian: 'Здравствуйте',
      transcription: 'Sa-la-mat-SYZ-by',
      icon: Icons.waving_hand_outlined,
    ),
    Phrase(
      kyrgyz: 'Чон рахмат!',
      russian: 'Большое спасибо',
      transcription: 'Chon rah-MAT',
      icon: Icons.favorite_outline,
    ),
    Phrase(
      kyrgyz: 'Бул канча турат?',
      russian: 'Сколько стоит?',
      transcription: 'Bul KAN-cha tu-RAT',
      icon: Icons.payments_outlined,
    ),
    Phrase(
      kyrgyz: 'Суу барбы?',
      russian: 'Есть вода?',
      transcription: 'SUU bar-BY',
      icon: Icons.water_drop_outlined,
    ),
    Phrase(
      kyrgyz: 'Жол көрсөтүп коюңузчу',
      russian: 'Покажите дорогу',
      transcription: 'Zhöl kör-SÖ-tüp ko-YUN-guz-chu',
      icon: Icons.map_outlined,
    ),
    Phrase(
      kyrgyz: 'Жакшы калыңыз!',
      russian: 'До свидания',
      transcription: 'Zhak-SHY ka-LYNG-yz',
      icon: Icons.waving_hand,
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
}
