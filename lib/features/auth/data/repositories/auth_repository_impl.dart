import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;

  AuthRepositoryImpl({required AuthRemoteDataSource remote}) : _remote = remote;

  @override
  Future<Either<Failure, void>> sendOtp(String phone) async {
    try {
      await _remote.sendOtp(phone);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyOtp(
    String phone,
    String code,
  ) async {
    try {
      final response = await _remote.verifyOtp(phone, code);
      return Right(response.data as Map<String, dynamic>);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
