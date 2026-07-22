import '../entities/visit_record.dart';

abstract class JournalRepository {
  Future<List<VisitRecord>> getAllVisits();
  Future<VisitRecord?> getVisitById(String id);
  Future<void> saveVisit(VisitRecord visit);
  Future<void> deleteVisit(String id);
  Future<void> clearAll();
  Future<bool> hasVisited(String locationId);
}
