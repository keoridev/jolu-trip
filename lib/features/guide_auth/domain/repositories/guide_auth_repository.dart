import 'package:dartz/dartz.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';

abstract class GuideAuthRepository {
  Future<Either<Failure, void>> sendLoginOtp(String phone);

  /// Returns {token, user} map
  Future<Either<Failure, Map<String, dynamic>>> verifyLoginOtp(
    String phone,
    String code,
  );

  Future<Either<Failure, void>> sendRegisterOtp({
    required String fullName,
    required GuideGender gender,
    required String phone,
  });

  /// Returns {token, user} map
  Future<Either<Failure, Map<String, dynamic>>> verifyRegisterOtp({
    required String fullName,
    required GuideGender gender,
    required String phone,
    required String code,
  });

  // NEW: Returns updated GuideEntity
  Future<Either<Failure, GuideEntity>> submitOnboarding({
    required String guideId,
    required int experienceYears,
    required String carModel,
    required String carNumber,
    required List<String> languages,
    required List<int> passportScanBytes,
    required List<int> licensePhotoBytes,
    required List<List<int>> carPhotosBytes,
  });
}
