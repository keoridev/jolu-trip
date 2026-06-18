import 'package:dartz/dartz.dart';
import 'package:jolutrip_app/core/errors/exceptions.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/features/guide_onboarding/data/datasources/guide_onboarding_remote_datasource.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/repositories/guide_onboarding_repository.dart';

class GuideOnboardingRepositoryImpl implements GuideOnboardingRepository {
  final GuideOnboardingRemoteDataSource _remoteDataSource;

  GuideOnboardingRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, OnboardingEntity>> submitOnboarding({
    required String token,
    required int experienceYears,
    required String carModel,
    required String carNumber,
    required List<String> languages,
    required List<int> passportScanBytes,
    required List<int> licensePhotoBytes,
    required List<List<int>> carPhotosBytes,
  }) async {
    try {
      final result = await _remoteDataSource.submitOnboarding(
        token: token,
        experienceYears: experienceYears,
        carModel: carModel,
        carNumber: carNumber,
        languages: languages,
        passportScanBytes: passportScanBytes,
        licensePhotoBytes: licensePhotoBytes,
        carPhotosBytes: carPhotosBytes,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
