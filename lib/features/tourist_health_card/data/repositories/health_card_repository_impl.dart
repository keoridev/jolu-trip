import 'package:fpdart/fpdart.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/features/tourist_health_card/data/datasources/health_card_remote_datasource.dart';
import 'package:jolutrip_app/features/tourist_health_card/data/models/health_card_model.dart';
import 'package:jolutrip_app/features/tourist_health_card/domain/entities/health_card_entity.dart';
import 'package:jolutrip_app/features/tourist_health_card/domain/repositories/health_card_repository.dart';

class HealthCardRepositoryImpl implements HealthCardRepository {
  final HealthCardRemoteDataSource _remote;

  HealthCardRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, HealthCardEntity?>> getHealthCard() async {
    try {
      final model = await _remote.getHealthCard();
      return Right(model?.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, HealthCardEntity>> saveHealthCard(
    HealthCardEntity card,
  ) async {
    try {
      final model = HealthCardModel(
        bloodType: card.bloodType,
        allergies: card.allergies,
        chronicDiseases: card.chronicDiseases,
        additionalInfo: card.additionalInfo,
        emergencyContact: card.emergencyContact,
      );
      final saved = await _remote.saveHealthCard(model);
      return Right(saved.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
