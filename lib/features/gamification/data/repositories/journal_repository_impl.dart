import 'package:jolutrip_app/features/gamification/data/datasources/datasources.dart';
import 'package:jolutrip_app/features/gamification/domain/entities/entities.dart';
import 'package:jolutrip_app/features/gamification/domain/repositories/repositories.dart';

import '../models/visit_record_dto.dart';

class JournalRepositoryImpl implements JournalRepository {
  final JournalLocalDatasource _datasource;

  const JournalRepositoryImpl(this._datasource);

  @override
  Future<List<VisitRecord>> getAllVisits() async {
    final dtos = await _datasource.getAllVisits();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<VisitRecord?> getVisitById(String id) async {
    final dto = await _datasource.getVisitById(id);
    return dto?.toEntity();
  }

  @override
  Future<void> saveVisit(VisitRecord visit) async {
    final dto = VisitRecordDto.fromEntity(visit);
    await _datasource.saveVisit(dto);
  }

  @override
  Future<void> deleteVisit(String id) async {
    await _datasource.deleteVisit(id);
  }

  @override
  Future<void> clearAll() async {
    await _datasource.clearAll();
  }

  @override
  Future<bool> hasVisited(String locationId) async {
    return _datasource.hasVisited(locationId);
  }
}
