import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/features/guide_tours/domain/entities/create_tour_entity.dart';
import 'package:jolutrip_app/features/guide_tours/domain/entities/tour_entity.dart';
import 'package:jolutrip_app/features/guide_tours/domain/usecases/create_tour_usecase.dart';
import 'package:jolutrip_app/features/guide_tours/domain/usecases/upload_promo_video_usecase.dart';

part 'guide_tours_state.dart';

class GuideToursCubit extends Cubit<GuideToursState> {
  final CreateTourUseCase createTourUseCase;
  final UploadPromoVideoUseCase uploadPromoVideoUseCase;

  GuideToursCubit({
    required this.createTourUseCase,
    required this.uploadPromoVideoUseCase,
  }) : super(const GuideToursInitial());

  Future<void> uploadPromoVideo(List<int> videoBytes, String fileName) async {
    emit(GuideToursVideoUploading(promoVideoKey: state.promoVideoKey));

    final result = await uploadPromoVideoUseCase(
      UploadPromoVideoParams(videoBytes: videoBytes, fileName: fileName),
    );

    result.fold(
      (failure) => emit(
        GuideToursError(
          message: failure.message,
          isNetworkError: failure is NetworkFailure,
          promoVideoKey: state.promoVideoKey,
        ),
      ),
      (key) => emit(GuideToursVideoUploaded(promoVideoKey: key)),
    );
  }

  Future<void> createTour(CreateTourEntity entity) async {
    emit(GuideToursCreating(promoVideoKey: state.promoVideoKey));

    final finalEntity = entity.copyWith(promoVideoUrl: state.promoVideoKey);

    final result = await createTourUseCase(finalEntity);

    result.fold(
      (failure) => emit(
        GuideToursError(
          message: failure.message,
          isNetworkError: failure is NetworkFailure,
          isValidationError:
              failure is ServerFailure &&
              (failure.statusCode == 400 || failure.statusCode == 422),
          promoVideoKey: state.promoVideoKey,
        ),
      ),
      (tour) => emit(
        GuideToursCreated(tour: tour, promoVideoKey: state.promoVideoKey),
      ),
    );
  }

  void reset() {
    emit(const GuideToursInitial());
  }
}
