import 'package:dartz/dartz.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';

abstract class GuideProfileRepository {
  Future<Either<Failure, GuideProfileEntity>> getProfile(String token);

  Future<Either<Failure, GuideProfileEntity>> updateProfile({
    required String token,
    String? fullName,
    String? carModel,
    String? carNumber,
    int? experienceYears,
    List<String>? languages,
  });

  Future<Either<Failure, String>> updateAvatar({
    required String token,
    required List<int> avatarBytes,
  });
}