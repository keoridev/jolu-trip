import 'package:dartz/dartz.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/features/locations/domain/entities/location_entity.dart';

abstract class LocationsRepository {
  Future<Either<Failure, List<LocationEntity>>> getLocations();
}
