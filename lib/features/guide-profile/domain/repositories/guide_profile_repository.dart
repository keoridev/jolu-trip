import 'package:fpdart/fpdart.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';

abstract class GuideProfileRepository {
  Future<Either<Failure, GuideProfileEntity>> getMe();
  Future<Either<Failure, GuideProfileEntity>> updateProfile(Map<String, dynamic> data);
  Future<Either<Failure, String>> uploadAvatar(List<int> bytes);
  Future<Either<Failure, String>> getVerificationStatus();
  Future<Either<Failure, String>> uploadPresentationVideo(List<int> bytes);
  Future<Either<Failure, List<String>>> uploadCarPhotos(List<List<int>> photosBytes);  // ← новое
}