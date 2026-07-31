import 'package:hive_ce/hive.dart';
import 'package:jolutrip_app/features/gamification/domain/entities/entities.dart';

class StampLocalDatasource {
  static const String _stampsBoxName = 'stamps_box';
  static const String _collectionsBoxName = 'collections_box';

  // ✅ ИСПРАВЛЕНО: Box<dynamic>
  Box<dynamic>? _stampsBox;
  Box<dynamic>? _collectionsBox;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    
    // ✅ ИСПРАВЛЕНО: Нетипизированное открытие
    _stampsBox = await Hive.openBox(_stampsBoxName);
    _collectionsBox = await Hive.openBox(_collectionsBoxName);
    await _initDefaultCollections();
    _initialized = true;
  }

  Future<void> _initDefaultCollections() async {
    if (_collectionsBox == null || _collectionsBox!.isNotEmpty) return;

    final defaults = <Map<String, dynamic>>[
      // ... (твой список defaults остается без изменений) ...
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