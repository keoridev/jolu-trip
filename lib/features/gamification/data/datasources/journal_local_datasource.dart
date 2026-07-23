
import 'package:hive/hive.dart';
import '../models/visit_record_dto.dart';

class JournalLocalDatasource {
  static const String _boxName = 'journal_box';
  Box<Map<dynamic, dynamic>>? _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<List<VisitRecordDto>> getAllVisits() async {
    if (_box == null) await init();
    final values = _box!.values.whereType<Map<dynamic, dynamic>>().toList();
    return values.map((data) {
      final map = Map<String, dynamic>.from(data);
      return VisitRecordDto.fromJson(map);
    }).toList();
  }

  Future<VisitRecordDto?> getVisitById(String id) async {
    if (_box == null) await init();
    final data = _box!.get(id);
    if (data == null) return null;
    return VisitRecordDto.fromJson(Map<String, dynamic>.from(data));
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