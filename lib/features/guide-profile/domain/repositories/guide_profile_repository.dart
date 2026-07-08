import 'package:dartz/dartz.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';

abstract class GuideProfileRepository {
  Future<Either<Failure, GuideProfileEntity>> getMe();
  
  Future<Either<Failure, GuideProfileEntity>> updateProfile(
    Map<String, dynamic> data,
  );

  Future<Either<Failure, String>> uploadAvatar(List<int> bytes);
}