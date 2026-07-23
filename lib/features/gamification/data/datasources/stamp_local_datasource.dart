// lib/features/gamification/data/datasources/stamp_local_datasource.dart

import 'package:hive/hive.dart';
import 'package:jolutrip_app/features/gamification/domain/entities/entities.dart';

class StampLocalDatasource {
  static const String _stampsBoxName = 'stamps_box';
  static const String _collectionsBoxName = 'collections_box';

  Box<Map<dynamic, dynamic>>? _stampsBox;
  Box<Map<dynamic, dynamic>>? _collectionsBox;
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
    if (_collectionsBox!.isNotEmpty) return;

    final defaults = [
      {
        'id': 'kyrgyz_canyons',
        'title': 'Каньоны Кыргызстана',
        'description': 'Откройте все каньоны страны',
        'stampIds': ['first_canyon', 'skazka', 'konorchek', 'fairytale'],
        'earnedStampIds': <String>[],
        'isSeasonal': false,
        'validUntil': null,
        'isArchived': false,
      },
      {
        'id': 'issyk_kul_region',
        'title': 'Иссык-Кульская область',
        'description': 'Исследуйте жемчужину Кыргызстана',
        'stampIds': ['issyk_kul', 'ala_archa', 'son_kul'],
        'earnedStampIds': <String>[],
        'isSeasonal': false,
        'validUntil': null,
        'isArchived': false,
      },
      {
        'id': 'autumn_2026',
        'title': 'Золотая осень 2026',
        'description': 'Посетите 3 осенних маршрута',
        'stampIds': ['autumn_1', 'autumn_2', 'autumn_3'],
        'earnedStampIds': <String>[],
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
    final values = _stampsBox!.values.whereType<Map<dynamic, dynamic>>().toList();
    return values.map((data) {
      final map = Map<String, dynamic>.from(data);
      return Stamp(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        imageAsset: map['imageAsset'] as String,
        rarity: StampRarity.values.byName(map['rarity'] as String),
        earnedAt: map['earnedAt'] != null
            ? DateTime.parse(map['earnedAt'] as String)
            : null,
      );
    }).toList();
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
    final values = _collectionsBox!.values.whereType<Map<dynamic, dynamic>>().toList();
    return values.map((data) {
      final map = Map<String, dynamic>.from(data);
      return Collection(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        stampIds: (map['stampIds'] as List<dynamic>).cast<String>(),
        earnedStampIds: (map['earnedStampIds'] as List<dynamic>).cast<String>(),
        isSeasonal: map['isSeasonal'] as bool? ?? false,
        validUntil: map['validUntil'] != null
            ? DateTime.parse(map['validUntil'] as String)
            : null,
        isArchived: map['isArchived'] as bool? ?? false,
      );
    }).toList();
  }

  Future<void> updateCollectionProgress(
    String collectionId,
    String stampId,
  ) async {
    await init();
    final data = _collectionsBox!.get(collectionId);
    if (data == null) return;

    final map = Map<String, dynamic>.from(data);
    final earned = (map['earnedStampIds'] as List<dynamic>).cast<String>();

    if (!earned.contains(stampId)) {
      earned.add(stampId);
      map['earnedStampIds'] = earned;
      await _collectionsBox!.put(collectionId, map);
    }
  }
}