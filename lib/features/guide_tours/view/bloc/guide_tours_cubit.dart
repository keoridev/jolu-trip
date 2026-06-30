import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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

  String? _promoVideoKey;

  Future<void> uploadPromoVideo(List<int> videoBytes, String fileName) async {
    emit(const GuideToursVideoUploading());

    final result = await uploadPromoVideoUseCase(
      UploadPromoVideoParams(videoBytes: videoBytes, fileName: fileName),
    );

    result.fold((failure) => emit(GuideToursError(message: failure.message)), (
      key,
    ) {
      _promoVideoKey = key;
      emit(const GuideToursVideoUploaded());
    });
  }

  Future<void> createTour(CreateTourEntity entity) async {
    emit(const GuideToursCreating());

    final finalEntity = entity.copyWith(promoVideoUrl: _promoVideoKey);

    final result = await createTourUseCase(finalEntity);

    result.fold(
      (failure) => emit(GuideToursError(message: failure.message)),
      (tour) => emit(GuideToursCreated(tour: tour)),
    );
  }

  void reset() {
    _promoVideoKey = null;
    emit(const GuideToursInitial());
  }
}
