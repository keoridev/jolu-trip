import 'package:dartz/dartz.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/core/usecases/usecase.dart';
import 'package:jolutrip_app/features/guide_tours/domain/entities/create_tour_entity.dart';
import 'package:jolutrip_app/features/guide_tours/domain/entities/tour_entity.dart';
import 'package:jolutrip_app/features/guide_tours/domain/repositories/guide_tours_repository.dart';

class CreateTourUseCase implements UseCase<TourEntity, CreateTourEntity> {
  final GuideToursRepository repository;

  CreateTourUseCase({required this.repository});

  @override
  Future<Either<Failure, TourEntity>> call(CreateTourEntity params) {
    return repository.createTour(params);
  }
}