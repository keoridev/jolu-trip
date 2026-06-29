import 'package:dartz/dartz.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/features/guide_auth/data/datasources/guide_auth_remote_datasource.dart';
import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';
import 'package:jolutrip_app/features/guide_auth/domain/repositories/guide_auth_repository.dart';

class GuideAuthRepositoryImpl implements GuideAuthRepository {
  final GuideAuthRemoteDataSource _remote;

  GuideAuthRepositoryImpl({required GuideAuthRemoteDataSource remote})
    : _remote = remote;

  String _genderToString(GuideGender gender) {
    switch (gender) {
      case GuideGender.male:
        return 'male';
      case GuideGender.female:
        return 'female';
    }
  }

  @override
  Future<Either<Failure, void>> resendSms(String phone) async {
    try {
      await _remote.resendSms(phone);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
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
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
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
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> sendRegisterOtp({
    required String fullName,
    required GuideGender gender,
    required String phone,
  }) async {
    try {
      await _remote.sendRegisterOtp(
        fullName: fullName,
        gender: _genderToString(gender),
        phone: phone,
      );
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
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
      final response = await _remote.verifyRegisterOtp(
        fullName: fullName,
        gender: _genderToString(gender),
        phone: phone,
        code: code,
      );
      return Right(response.data as Map<String, dynamic>);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}