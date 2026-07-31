import 'dart:async';
import 'package:hive_ce/hive.dart'; // <-- Только hive_ce, flutter-импорт не нужен здесь
import '../models/visit_record_dto.dart';

class JournalLocalDatasource {
  static const String _boxName = 'journal_box';

  // ✅ ИСПРАВЛЕНО: Box<dynamic> вместо Box<Map<String, dynamic>>
  Box<dynamic>? _box;

  Future<void> init() async {
    // ✅ ИСПРАВЛЕНО: Открываем нетипизированный Box
    _box = await Hive.openBox(_boxName);
  }

  Future<List<VisitRecordDto>> getAllVisits() async {
    if (_box == null) await init();
    
    // ✅ БЕЗОПАСНОЕ ЧТЕНИЕ: Сначала фильтруем Map, затем кастим к String keys
    final values = _box!.values
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
        
    return values.map((data) => VisitRecordDto.fromJson(data)).toList();
  }

  Future<VisitRecordDto?> getVisitById(String id) async {
    if (_box == null) await init();
    final data = _box!.get(id);
    if (data is Map) {
      return VisitRecordDto.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<void> saveVisit(VisitRecordDto dto) async {
    if (_box == null) await init();
    await _box!.put(dto.id, dto.toJson());
  }

  Future<void> deleteVisit(String id) async {
    if (_box == null) await init();
    await _box!.delete(id);
  }

  Future<void> clearAll() async {
    if (_box == null) await init();
    await _box!.clear();
  }

  Future<bool> hasVisited(String locationId) async {
    if (_box == null) await init();
    final visits = await getAllVisits();
    return visits.any((v) => v.locationId == locationId);
  }
}