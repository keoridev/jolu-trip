import 'package:fpdart/fpdart.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/features/tourist_health_card/domain/entities/health_card_entity.dart';

abstract class HealthCardRepository {
  Future<Either<Failure, HealthCardEntity?>> getHealthCard();

  Future<Either<Failure, HealthCardEntity>> saveHealthCard(
    HealthCardEntity card,
  );
}
