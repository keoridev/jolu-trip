import 'package:jolutrip_app/features/location-detail/domain/entities/entities.dart';

abstract class LocationDetailRepository {
  Future<LocationDetailEntity> getLocationDetail(String locationId);
}
