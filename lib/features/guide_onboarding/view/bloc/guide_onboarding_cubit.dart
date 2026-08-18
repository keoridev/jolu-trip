import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/bloc/guide_onboarding_state.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/repositories/guide_onboarding_repository.dart';

class GuideOnboardingCubit extends Cubit<GuideOnboardingState> {
  final GuideOnboardingRepository _repository;

  GuideOnboardingCubit(this._repository) : super(GuideOnboardingInitial());

  void _safeEmit(GuideOnboardingState state) {
    if (!isClosed) emit(state);
  }

  Future<void> submitOnboarding({
    required String token,
    required int experienceYears,
    required String carCategory,
    required String carModel,
    required int carSeats,
    required int carYear,
    required String steeringWheel,
    required List<String> carFeatures,
    required String carNumber,
    required List<String> languages,
    required List<int> passportMainPhotoBytes,
    required List<int> passportRegistrationPhotoBytes,
    required List<int> licensePhotoFrontBytes,
    required List<int> licensePhotoBackBytes,
    required List<List<int>> carPhotosBytes,
    required List<int> presentationVideoBytes,
  }) async {
    _safeEmit(GuideOnboardingLoading());

    final result = await _repository.submitOnboarding(
      token: token,
      experienceYears: experienceYears,
      carCategory: carCategory,
      carModel: carModel,
      carNumber: carNumber,
      languages: languages,
      carSeats: carSeats,
      carYear: carYear,
      steeringWheel: steeringWheel,
      carFeatures: carFeatures,
      passportMainPhotoBytes: passportMainPhotoBytes,
      passportRegistrationPhotoBytes: passportRegistrationPhotoBytes,
      licensePhotoFrontBytes: licensePhotoFrontBytes,
      licensePhotoBackBytes: licensePhotoBackBytes,
      carPhotosBytes: carPhotosBytes,
      presentationVideoBytes: presentationVideoBytes,
    );

    if (isClosed) return;

    result.fold(
      (failure) => _safeEmit(GuideOnboardingError(failure.message)),
      (onboarding) => _safeEmit(GuideOnboardingSubmitted(onboarding: onboarding)),
    );
  }
}