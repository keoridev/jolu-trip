import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/core/storage/secure_storage.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_state.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';
import 'package:jolutrip_app/features/guide-profile/domain/repositories/guide_profile_repository.dart';

class GuideProfileCubit extends Cubit<GuideProfileState> {
  final GuideProfileRepository _repository;

  GuideProfileCubit(this._repository) : super(const GuideProfileLoading());

  Future<void> loadProfile() async {
    emit(const GuideProfileLoading());
    debugPrint('🔍 GuideProfileCubit.loadProfile()');

    final result = await _repository.getMe();
    result.fold(
      (failure) => _handleFailure(failure),
      (profile) => emit(GuideProfileLoaded(profile: profile)),
    );
  }

  Future<void> checkVerificationStatus() async {
    debugPrint('🔍 GuideProfileCubit.checkVerificationStatus()');

    final result = await _repository.getVerificationStatus();
    result.fold(
      (failure) =>
          debugPrint('❌ Verification status error: ${failure.message}'),
      (status) {
        debugPrint('✅ Verification status: $status');
        final current = state;
        if (current is GuideProfileLoaded) {
          final updatedProfile = current.profile.copyWith(status: status);
          emit(GuideProfileLoaded(profile: updatedProfile));
        }
      },
    );
  }

  void _handleFailure(Failure failure) {
    if (failure is ServerFailure && failure.statusCode == 404) {
      debugPrint(
        '⚠️ GuideProfileCubit: Account not found (404), clearing auth data',
      );
      _clearAuthAndEmitNotFound();
      return;
    }
    emit(GuideProfileError(failure.message));
  }

  Future<void> _clearAuthAndEmitNotFound() async {
    await SecureStorage.clearAll();
    emit(const GuideProfileNotFound());
  }

  Future<void> updateProfile({
    String? fullName,
    String? gender,
    String? carModel,
    String? carNumber,
    int? experienceYears,
    List<String>? languages,
  }) async {
    final current = state;
    if (current is! GuideProfileLoaded) return;

    emit(const GuideProfileLoading());

    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (gender != null) data['gender'] = gender;
    if (carModel != null) data['car_model'] = carModel;
    if (carNumber != null) data['car_number'] = carNumber;
    if (experienceYears != null) data['experience_years'] = experienceYears;
    if (languages != null) data['languages'] = languages;

    if (data.isEmpty) {
      emit(GuideProfileLoaded(profile: current.profile));
      return;
    }

    final result = await _repository.updateProfile(data);
    result.fold(
      (failure) => _handleFailure(failure),
      (profile) => emit(GuideProfileLoaded(profile: profile)),
    );
  }

  Future<void> updateCar(String carModel, String carNumber) async {
    return updateProfile(carModel: carModel, carNumber: carNumber);
  }

  Future<void> updateExperience(
    int experienceYears,
    List<String> languages,
  ) async {
    return updateProfile(
      experienceYears: experienceYears,
      languages: languages,
    );
  }

  Future<void> updateAvatar(Uint8List bytes) async {
    final current = state;
    if (current is! GuideProfileLoaded) return;

    emit(const GuideProfileLoading());

    final result = await _repository.uploadAvatar(bytes.toList());
    result.fold((failure) => _handleFailure(failure), (avatarUrl) {
      final updatedProfile = current.profile.copyWith(avatarUrl: avatarUrl);
      emit(GuideProfileLoaded(profile: updatedProfile));
    });
  }

  Future<void> logout() async {
    await SecureStorage.clearAll();
    emit(const GuideProfileLoggedOut());
  }

  Future<void> updatePresentationVideo(Uint8List bytes) async {
    final current = state;
    if (current is! GuideProfileLoaded) return;

    emit(const GuideProfileLoading());

    final result = await _repository.uploadPresentationVideo(bytes.toList());
    result.fold((failure) => _handleFailure(failure), (videoUrl) {
      final updatedProfile = current.profile.copyWith(
        presentationVideoUrl: videoUrl,
      );
      emit(GuideProfileLoaded(profile: updatedProfile));
    });
  }
}
