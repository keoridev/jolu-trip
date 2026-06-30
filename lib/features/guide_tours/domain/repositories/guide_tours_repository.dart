import 'package:dartz/dartz.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/features/guide_tours/domain/entities/create_tour_entity.dart';
import 'package:jolutrip_app/features/guide_tours/domain/entities/tour_entity.dart';

abstract class GuideToursRepository {
  Future<Either<Failure, String>> uploadPromoVideo(
    List<int> videoBytes,
    String fileName,
  );
  Future<Either<Failure, TourEntity>> createTour(CreateTourEntity entity);
}
