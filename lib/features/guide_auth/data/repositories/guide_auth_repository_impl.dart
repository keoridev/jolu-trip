import 'package:dartz/dartz.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/features/guide_auth/data/datasources/datasource.dart';
import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';
import 'package:jolutrip_app/features/guide_auth/domain/repositories/repositories.dart';

class GuideAuthRepositoryImpl implements GuideAuthRepository {
  final GuideAuthRemoteDataSource _remote;

  GuideAuthRepositoryImpl({required GuideAuthRemoteDataSource remote})
    : _remote = remote;

  // Вспомогательный метод для конвертации enum в строку
  String _genderToString(GuideGender gender) {
    switch (gender) {
      case GuideGender.male:
        return 'male';
      case GuideGender.female:
        return 'female';
    }
  }

  @override
  Future<Either<Failure, void>> sendLoginOtp(String phone) async {
    try {
      await _remote.sendLoginOtp(phone);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyLoginOtp(
    String phone,
    String code,
  ) async {
    try {
      final response = await _remote.verifyLoginOtp(phone, code);
      return Right(response.data as Map<String, dynamic>);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> sendRegisterOtp({
    required String fullName,
    required GuideGender gender,
    required String phone,
  }) async {
    try {
      // Конвертируем enum в строку перед отправкой
      final genderString = _genderToString(gender);

      await _remote.sendRegisterOtp(
        fullName: fullName,
        gender: genderString, // Теперь передаем String
        phone: phone,
      );
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyRegisterOtp({
    required String fullName,
    required GuideGender gender,
    required String phone,
    required String code,
  }) async {
    try {
      // Конвертируем enum в строку перед отправкой
      final genderString = _genderToString(gender);

      final response = await _remote.verifyRegisterOtp(
        fullName: fullName,
        gender: genderString, // Теперь передаем String
        phone: phone,
        code: code,
      );
      return Right(response.data as Map<String, dynamic>);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, GuideEntity>> submitOnboarding({
    required String guideId,
    required int experienceYears,
    required String carModel,
    required String carNumber,
    required List<String> languages,
    required List<int> passportScanBytes,
    required List<int> licensePhotoBytes,
    required List<List<int>> carPhotosBytes,
  }) async {
    try {
      final guide = await _remote.submitOnboarding(
        guideId: guideId,
        experienceYears: experienceYears,
        carModel: carModel,
        carNumber: carNumber,
        languages: languages,
        passportScanBytes: passportScanBytes,
        licensePhotoBytes: licensePhotoBytes,
        carPhotosBytes: carPhotosBytes,
      );
      return Right(guide);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
