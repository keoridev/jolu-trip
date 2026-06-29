import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/bloc/guide_onboarding_state.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/repositories/guide_onboarding_repository.dart';

class GuideOnboardingCubit extends Cubit<GuideOnboardingState> {
  final GuideOnboardingRepository _repository;

  GuideOnboardingCubit(this._repository) : super(GuideOnboardingInitial());

  Future<void> submitOnboarding({
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
  }) async {
    emit(GuideOnboardingLoading());

    final result = await _repository.submitOnboarding(
      token: token,
      experienceYears: experienceYears,
      carCategory: carCategory,
      carModel: carModel,
      carNumber: carNumber,
      languages: languages,
      passportMainPhotoBytes: passportMainPhotoBytes,
      passportRegistrationPhotoBytes: passportRegistrationPhotoBytes,
      licensePhotoFrontBytes: licensePhotoFrontBytes,
      licensePhotoBackBytes: licensePhotoBackBytes,
      carPhotosBytes: carPhotosBytes,
      presentationVideoBytes: presentationVideoBytes,
    );

    result.fold(
      (failure) => emit(GuideOnboardingError(failure.message)),
      (onboarding) => emit(GuideOnboardingSubmitted(onboarding: onboarding)),
    );
  }
}