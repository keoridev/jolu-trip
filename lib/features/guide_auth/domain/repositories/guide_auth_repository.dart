// lib/features/guide_auth/domain/repositories/guide_auth_repository.dart

import 'package:dartz/dartz.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';

abstract class GuideAuthRepository {
  Future<Either<Failure, void>> sendLoginOtp(String phone);

  Future<Either<Failure, Map<String, dynamic>>> verifyLoginOtp(
    String phone,
    String code,
  );

  Future<Either<Failure, void>> sendRegisterOtp({
    required String fullName,
    required GuideGender gender,
    required String phone,
  });

  Future<Either<Failure, Map<String, dynamic>>> verifyRegisterOtp({
    required String fullName,
    required GuideGender gender,
    required String phone,
    required String code,
  });
}
