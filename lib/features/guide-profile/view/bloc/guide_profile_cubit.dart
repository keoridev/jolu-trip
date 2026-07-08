import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_state.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';
import 'package:jolutrip_app/features/guide-profile/domain/repositories/guide_profile_repository.dart';

class GuideProfileCubit extends Cubit<GuideProfileState> {
  final GuideProfileRepository _repository;

  GuideProfileCubit(this._repository) : super(GuideProfileLoading());

  Future<void> loadProfile() async {
    emit(GuideProfileLoading());
    debugPrint('🔍 GuideProfileCubit.loadProfile()');

    final result = await _repository.getMe();
    result.fold(
      (failure) => emit(GuideProfileError(failure.message)),
      (profile) => emit(GuideProfileLoaded(profile: profile)),
    );
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

    emit(GuideProfileLoading());

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
      (failure) => emit(GuideProfileError(failure.message)),
      (profile) => emit(GuideProfileLoaded(profile: profile)),
    );
  }

  Future<void> updateAvatar(Uint8List bytes) async {
    final current = state;
    if (current is! GuideProfileLoaded) return;

    emit(GuideProfileLoading());

    final result = await _repository.uploadAvatar(bytes.toList());
    result.fold((failure) => emit(GuideProfileError(failure.message)), (
      avatarUrl,
    ) {
      final updatedProfile = current.profile.copyWith(avatarUrl: avatarUrl);
      emit(GuideProfileLoaded(profile: updatedProfile));
    });
  }

  void logout() {
    emit(GuideProfileInitial());
  }
}
