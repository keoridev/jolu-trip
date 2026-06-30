import 'package:dartz/dartz.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/core/usecases/usecase.dart';
import 'package:jolutrip_app/features/guide_tours/domain/repositories/guide_tours_repository.dart';

class UploadPromoVideoParams {
  final List<int> videoBytes;
  final String fileName;

  const UploadPromoVideoParams({required this.videoBytes, required this.fileName});
}

class UploadPromoVideoUseCase implements UseCase<String, UploadPromoVideoParams> {
  final GuideToursRepository repository;

  UploadPromoVideoUseCase({required this.repository});

  @override
  Future<Either<Failure, String>> call(UploadPromoVideoParams params) {
    return repository.uploadPromoVideo(params.videoBytes, params.fileName);
  }
}