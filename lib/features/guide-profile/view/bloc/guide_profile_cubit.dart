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

  void _safeEmit(GuideProfileState state) {
    if (!isClosed) emit(state);
  }

  Future<void> loadProfile() async {
    _safeEmit(const GuideProfileLoading());
    debugPrint('🔍 GuideProfileCubit.loadProfile()');

    final result = await _repository.getMe();
    if (isClosed) return;

    result.fold(
      (failure) => _handleFailure(failure),
      (profile) => _safeEmit(GuideProfileLoaded(profile: profile)),
    );
  }

  Future<void> checkVerificationStatus() async {
    debugPrint('🔍 GuideProfileCubit.checkVerificationStatus()');

    final result = await _repository.getVerificationStatus();
    if (isClosed) return;

    result.fold(
      (failure) =>
          debugPrint('❌ Verification status error: ${failure.message}'),
      (status) {
        debugPrint('✅ Verification status: $status');
        final current = state;
        if (current is GuideProfileLoaded) {
          final updatedProfile = current.profile.copyWith(status: status);
          _safeEmit(GuideProfileLoaded(profile: updatedProfile));
        }
      },
    );
  }

  void _handleFailure(Failure failure) {
    if (isClosed) return;

    if (failure is ServerFailure && failure.statusCode == 404) {
      debugPrint(
        '⚠️ GuideProfileCubit: Account not found (404), clearing auth data',
      );
      _clearAuthAndEmitNotFound();
      return;
    }
    _safeEmit(GuideProfileError(failure.message));
  }

  Future<void> _clearAuthAndEmitNotFound() async {
    await SecureStorage.clearAll();
    if (isClosed) return;
    _safeEmit(const GuideProfileNotFound());
  }

  Future<void> updateProfile({
    String? fullName,
    String? gender,
    String? carModel,
    String? carNumber,
    int? carSeats,
    int? carYear,
    String? steeringWheel,
    List<String>? carFeatures,
    int? experienceYears,
    List<String>? languages,
  }) async {
    final current = state;
    if (current is! GuideProfileLoaded) return;

    _safeEmit(const GuideProfileLoading());

    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (gender != null) data['gender'] = gender;
    if (carModel != null) data['car_model'] = carModel;
    if (carNumber != null) data['car_number'] = carNumber;
    if (carSeats != null) data['car_seats'] = carSeats;
    if (carYear != null) data['car_year'] = carYear;
    if (steeringWheel != null) data['steering_wheel'] = steeringWheel;
    if (carFeatures != null) data['car_features'] = carFeatures;
    if (experienceYears != null) data['experience_years'] = experienceYears;
    if (languages != null) data['languages'] = languages;

    if (data.isEmpty) {
      _safeEmit(GuideProfileLoaded(profile: current.profile));
      return;
    }

    final result = await _repository.updateProfile(data);
    if (isClosed) return;

    result.fold(
      (failure) => _handleFailure(failure),
      (profile) => _safeEmit(GuideProfileLoaded(profile: profile)),
    );
  }

  Future<void> updateCar(
    String carModel,
    String carNumber,
    int carSeats,
    int carYear,
    String steeringWheel,
    List<String> carFeatures,
  ) async {
    return updateProfile(
      carModel: carModel,
      carNumber: carNumber,
      carSeats: carSeats,
      carYear: carYear,
      steeringWheel: steeringWheel,
      carFeatures: carFeatures,
    );
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

    _safeEmit(const GuideProfileLoading());

    final result = await _repository.uploadAvatar(bytes.toList());
    if (isClosed) return;

    result.fold((failure) => _handleFailure(failure), (avatarUrl) {
      final updatedProfile = current.profile.copyWith(avatarUrl: avatarUrl);
      _safeEmit(GuideProfileLoaded(profile: updatedProfile));
    });
  }

  Future<void> updatePresentationVideo(Uint8List bytes) async {
    final current = state;
    if (current is! GuideProfileLoaded) return;

    _safeEmit(const GuideProfileLoading());

    final result = await _repository.uploadPresentationVideo(bytes.toList());
    if (isClosed) return;

    result.fold((failure) => _handleFailure(failure), (videoUrl) {
      final updatedProfile = current.profile.copyWith(
        presentationVideoUrl: videoUrl,
      );
      _safeEmit(GuideProfileLoaded(profile: updatedProfile));
    });
  }

  Future<void> updateCarPhotos(List<Uint8List> photos) async {
    final current = state;
    if (current is! GuideProfileLoaded) return;

    _safeEmit(const GuideProfileLoading());

    final result = await _repository.uploadCarPhotos(
      photos.map((e) => e.toList()).toList(),
    );
    if (isClosed) return;

    result.fold((failure) => _handleFailure(failure), (photoUrls) {
      loadProfile();
    });
  }

  Future<void> logout() async {
    _safeEmit(const GuideProfileLoading());

    try {
      await SecureStorage.clearAll();
      debugPrint('🔑 GuideProfileCubit: User logged out');
      if (isClosed) return;
      _safeEmit(const GuideProfileLoggedOut());
    } catch (e) {
      debugPrint('❌ Error during logout: $e');
      await SecureStorage.clearAll();
      if (isClosed) return;
      _safeEmit(const GuideProfileLoggedOut());
    }
  }
}