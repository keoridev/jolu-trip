import 'package:jolutrip_app/features/gamification/domain/entities/entities.dart';

abstract class StampRepository {
  Future<List<Stamp>> getEarnedStamps();
  Future<List<Stamp>> getAvailableStamps();
  Future<List<Collection>> getCollections();
  Future<List<Stamp>> evaluateNewStamps({
    required String locationId,
    required List<String> locationTags,
    required bool hasGuideBooking,
    required List<VisitRecord> visitHistory,
  });
  Future<void> saveStamp(Stamp stamp);
  Future<void> saveCollectionProgress(String collectionId, String stampId);
}
