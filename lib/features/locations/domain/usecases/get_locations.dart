import 'package:dartz/dartz.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/core/usecases/usecase.dart';
import 'package:jolutrip_app/features/locations/domain/entities/location_entity.dart';
import 'package:jolutrip_app/features/locations/domain/repositories/locations_repository.dart';

class GetLocationsUseCase implements UseCase<List<LocationEntity>, NoParams> {
  final LocationsRepository repository;

  GetLocationsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<LocationEntity>>> call(NoParams params) {
    return repository.getLocations();
  }
}
