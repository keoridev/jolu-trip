import 'package:hive_ce/hive.dart';
import 'package:jolutrip_app/features/gamification/domain/entities/entities.dart';

class StampLocalDatasource {
  static const String _stampsBoxName = 'stamps_box';
  static const String _collectionsBoxName = 'collections_box';

  Box<dynamic>? _stampsBox;
  Box<dynamic>? _collectionsBox;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    
    _stampsBox = await Hive.openBox(_stampsBoxName);
    _collectionsBox = await Hive.openBox(_collectionsBoxName);
    await _initDefaultCollections();
    _initialized = true;
  }

  Future<void> _initDefaultCollections() async {
    if (_collectionsBox == null) return;
    
    // Если коллекции уже есть, мы НЕ перезаписываем их, чтобы не сбросить реальный прогресс пользователя
    if (_collectionsBox!.isNotEmpty) return; 

    // ═══════════════════════════════════════════════════
    // SEEDING DEMO DATA (Только при первом запуске)
    // ═══════════════════════════════════════════════════
    final now = DateTime.now();

    // 1. Добавляем несколько "уже полученных" печатей
    await _stampsBox!.put('first_step', {
      'id': 'first_step',
      'title': 'Первый шаг',
      'description': 'Начало путешествия по Кыргызстану',
      'imageAsset': 'assets/stamps/first_step.png',
      'rarity': 'common',
      'earnedAt': now.subtract(const Duration(days: 10)).toIso8601String(),
    });

    await _stampsBox!.put('issyk_kul', {
      'id': 'issyk_kul',
      'title': 'Иссык-Куль',
      'description': 'Жемчужина Кыргызстана',
      'imageAsset': 'assets/stamps/issyk_kul.png',
      'rarity': 'common',
      'earnedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
    });

    await _stampsBox!.put('first_canyon', {
      'id': 'first_canyon',
      'title': 'Исследователь каньонов',
      'description': 'Первый каньон открыт',
      'imageAsset': 'assets/stamps/canyon.png',
      'rarity': 'silver',
      'earnedAt': now.subtract(const Duration(days: 1)).toIso8601String(),
    });

    // 2. Создаем коллекции, где некоторые штампы УЖЕ получены (обрати внимание на earnedStampIds)
    final defaults = <Map<String, dynamic>>[
      {
        'id': 'kyrgyz_canyons',
        'title': 'Каньоны Кыргызстана',
        'description': 'Откройте все каньоны страны',
        'stampIds': ['first_canyon', 'skazka', 'konorchek', 'fairytale'],
        'earnedStampIds': ['first_canyon'], // ✅ 1 из 4 получено
        'isSeasonal': false,
        'validUntil': null,
        'isArchived': false,
      },
      {
        'id': 'issyk_kul_region',
        'title': 'Иссык-Кульская область',
        'description': 'Исследуйте жемчужину Кыргызстана',
        'stampIds': ['issyk_kul', 'ala_archa', 'son_kul'],
        'earnedStampIds': ['issyk_kul'], // ✅ 1 из 3 получено
        'isSeasonal': false,
        'validUntil': null,
        'isArchived': false,
      },
      {
        'id': 'autumn_2026',
        'title': 'Золотая осень 2026',
        'description': 'Посетите 3 осенних маршрута',
        'stampIds': ['autumn_1', 'autumn_2', 'autumn_3'],
        'earnedStampIds': <String>[], // Пока 0 из 3
        'isSeasonal': true,
        'validUntil': '2026-11-30T23:59:59Z',
        'isArchived': false,
      },
    ];

    for (final c in defaults) {
      await _collectionsBox!.put(c['id'], c);
    }
  }

  Future<List<Stamp>> getEarnedStamps() async {
    await init();
    final values = _stampsBox!.values
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
        
    return values.map((map) => Stamp(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      imageAsset: map['imageAsset'] as String,
      rarity: StampRarity.values.byName(map['rarity'] as String),
      earnedAt: map['earnedAt'] != null ? DateTime.parse(map['earnedAt'] as String) : null,
    )).toList();
  }

  Future<void> saveStamp(Stamp stamp) async {
    await init();
    await _stampsBox!.put(stamp.id, {
      'id': stamp.id,
      'title': stamp.title,
      'description': stamp.description,
      'imageAsset': stamp.imageAsset,
      'rarity': stamp.rarity.name,
      'earnedAt': stamp.earnedAt?.toIso8601String(),
    });
  }

  Future<List<Collection>> getCollections() async {
    await init();
    final values = _collectionsBox!.values
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
        
    return values.map((map) => Collection(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      stampIds: (map['stampIds'] as List<dynamic>).cast<String>(),
      earnedStampIds: (map['earnedStampIds'] as List<dynamic>).cast<String>(),
      isSeasonal: map['isSeasonal'] as bool? ?? false,
      validUntil: map['validUntil'] != null ? DateTime.parse(map['validUntil'] as String) : null,
      isArchived: map['isArchived'] as bool? ?? false,
    )).toList();
  }

  Future<void> updateCollectionProgress(String collectionId, String stampId) async {
    await init();
    final data = _collectionsBox!.get(collectionId);
    if (data is! Map) return;

    final map = Map<String, dynamic>.from(data);
    final earned = (map['earnedStampIds'] as List<dynamic>).cast<String>();

    if (!earned.contains(stampId)) {
      earned.add(stampId);
      map['earnedStampIds'] = earned;
      await _collectionsBox!.put(collectionId, map);
    }
  }
}