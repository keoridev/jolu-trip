import 'package:dartz/dartz.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/features/guide-profile/data/datasources/guide_profile_remote_datasource.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';
import 'package:jolutrip_app/features/guide-profile/domain/repositories/guide_profile_repository.dart';

class GuideProfileRepositoryImpl implements GuideProfileRepository {
  final GuideProfileRemoteDataSource _remote;

  GuideProfileRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, GuideProfileEntity>> getMe() async {
    try {
      final model = await _remote.getMe();
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, GuideProfileEntity>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final model = await _remote.updateProfile(data);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(List<int> bytes) async {
    try {
      final url = await _remote.uploadAvatar(bytes);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}