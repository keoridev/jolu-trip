import 'package:jolutrip_app/features/location-detail/data/datasources/location_detail_remote_datasource.dart';
import 'package:jolutrip_app/features/location-detail/domain/entities/entities.dart';
import 'package:jolutrip_app/features/location-detail/domain/repositories/location_detail_repository.dart';

class LocationDetailRepositoryImpl implements LocationDetailRepository {
  final LocationDetailRemoteDataSource _remote;

  LocationDetailRepositoryImpl({required LocationDetailRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<LocationDetailEntity> getLocationDetail(String locationId) async {
    return await _remote.getLocationDetail(locationId);
  }
}
