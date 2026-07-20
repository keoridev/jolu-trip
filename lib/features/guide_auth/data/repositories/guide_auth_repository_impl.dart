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

  String _genderToString(GuideGender gender) => switch (gender) {
    GuideGender.male => 'male',
    GuideGender.female => 'female',
  };

  Future<Either<Failure, T>> _handleRequest<T>(Future<T> Function() request) async {
    try {
      final result = await request();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> resendSms(String phone) =>
      _handleRequest(() => _remote.resendSms(phone));

  @override
  Future<Either<Failure, void>> sendLoginOtp(String phone) =>
      _handleRequest(() => _remote.sendLoginOtp(phone));

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyLoginOtp(
    String phone,
    String code,
  ) => _handleRequest(() async {
    final response = await _remote.verifyLoginOtp(phone, code);
    return response.data as Map<String, dynamic>;
  });

  @override
  Future<Either<Failure, void>> sendRegisterOtp({
    required String fullName,
    required GuideGender gender,
    required String phone,
  }) => _handleRequest(() => _remote.sendRegisterOtp(
    fullName: fullName,
    gender: _genderToString(gender),
    phone: phone,
  ));

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyRegisterOtp({
    required String fullName,
    required GuideGender gender,
    required String phone,
    required String code,
  }) => _handleRequest(() async {
    final response = await _remote.verifyRegisterOtp(
      fullName: fullName,
      gender: _genderToString(gender),
      phone: phone,
      code: code,
    );
    return response.data as Map<String, dynamic>;
  });
}