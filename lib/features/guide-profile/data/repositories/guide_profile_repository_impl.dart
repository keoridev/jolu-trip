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
  Future<Either<Failure, GuideProfileEntity>> getProfile(String token) async {
    try {
      final profile = await _remote.getProfile(token);
      return Right(profile);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, GuideProfileEntity>> updateProfile({
    required String token,
    String? fullName,
    String? carModel,
    String? carNumber,
    int? experienceYears,
    List<String>? languages,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (carModel != null) data['car_model'] = carModel;
      if (carNumber != null) data['car_number'] = carNumber;
      if (experienceYears != null) data['experience_years'] = experienceYears;
      if (languages != null) data['languages'] = languages;

      final profile = await _remote.updateProfile(token: token, data: data);
      return Right(profile);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, String>> updateAvatar({
    required String token,
    required List<int> avatarBytes,
  }) async {
    try {
      final url = await _remote.updateAvatar(token: token, avatarBytes: avatarBytes);
      return Right(url);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}