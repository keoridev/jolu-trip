import 'package:dartz/dartz.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';

abstract class GuideOnboardingRepository {
  Future<Either<Failure, OnboardingEntity>> submitOnboarding({
    required String token,
    required int experienceYears,
    required String carCategory,
    required String carModel,
    required String carNumber,
    required List<String> languages,
    required List<int> passportMainPhotoBytes,
    required List<int> passportRegistrationPhotoBytes,
    required List<int> licensePhotoFrontBytes,
    required List<int> licensePhotoBackBytes,
    required List<List<int>> carPhotosBytes,
    required List<int> presentationVideoBytes,
  });
}