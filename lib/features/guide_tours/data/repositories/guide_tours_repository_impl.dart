import 'package:dartz/dartz.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/features/guide_tours/data/datasource/guide_tours_remote_datasource.dart';
import 'package:jolutrip_app/features/guide_tours/data/models/create_tour_request_model.dart';
import 'package:jolutrip_app/features/guide_tours/data/models/tour_model.dart';
import 'package:jolutrip_app/features/guide_tours/domain/entities/create_tour_entity.dart';
import 'package:jolutrip_app/features/guide_tours/domain/entities/tour_entity.dart';
import 'package:jolutrip_app/features/guide_tours/domain/repositories/guide_tours_repository.dart';

class GuideToursRepositoryImpl implements GuideToursRepository {
  final GuideToursRemoteDataSource remoteDataSource;

  GuideToursRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> uploadPromoVideo(
    List<int> videoBytes,
    String fileName,
  ) async {
    try {
      final result = await remoteDataSource.uploadPromoVideo(
        videoBytes,
        fileName,
      );
      return Right(result.key);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TourEntity>> createTour(
    CreateTourEntity entity,
  ) async {
    try {
      final request = CreateTourRequestModel(
        title: entity.title,
        locationId: entity.locationId,
        departureAt: entity.departureAt,
        durationDays: entity.durationDays,
        totalSeats: entity.totalSeats,
        minSeats: entity.minSeats,
        pricePerSeat: entity.pricePerSeat,
        promoVideoUrl: entity.promoVideoUrl,
        includedServices: entity.includedServices,
        gearRequirements: entity.gearRequirements,
        itinerary: entity.itinerary
            .map(
              (e) => ItineraryDayModel(day: e.day, description: e.description),
            )
            .toList(),
      );

      final result = await remoteDataSource.createTour(request);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}

extension _TourModelX on TourModel {
  TourEntity toEntity() => TourEntity(
    id: this.id,
    title: title,
    promoVideoUrl: promoVideoUrl,
    departureAt: departureAt,
    durationDays: durationDays,
    totalSeats: totalSeats,
    minSeats: minSeats,
    pricePerSeat: pricePerSeat,
    status: status,
    bookedSeats: bookedSeats,
  );
}
