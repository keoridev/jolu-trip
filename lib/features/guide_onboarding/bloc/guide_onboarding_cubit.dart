import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/features/guide_onboarding/bloc/guide_onboarding_state.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/repositories/guide_onboarding_repository.dart';

class GuideOnboardingCubit extends Cubit<GuideOnboardingState> {
  final GuideOnboardingRepository _repository;

  GuideOnboardingCubit(this._repository) : super(GuideOnboardingInitial());

  Future<void> submitOnboarding({
    required String token, // Добавили token
    required int experienceYears,
    required String carModel,
    required String carNumber,
    required List<String> languages,
    required List<int> passportScanBytes,
    required List<int> licensePhotoBytes,
    required List<List<int>> carPhotosBytes,
  }) async {
    emit(GuideOnboardingLoading());

    final result = await _repository.submitOnboarding(
      token: token,
      experienceYears: experienceYears,
      carModel: carModel,
      carNumber: carNumber,
      languages: languages,
      passportScanBytes: passportScanBytes,
      licensePhotoBytes: licensePhotoBytes,
      carPhotosBytes: carPhotosBytes,
    );

    result.fold(
      (failure) => emit(GuideOnboardingError(failure.message)),
      (onboarding) => emit(GuideOnboardingSubmitted(onboarding: onboarding)),
    );
  }
}