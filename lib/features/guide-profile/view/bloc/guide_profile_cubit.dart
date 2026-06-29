import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/storage/secure_storage.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_state.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';
import 'package:jolutrip_app/features/guide-profile/domain/repositories/guide_profile_repository.dart';

class GuideProfileCubit extends Cubit<GuideProfileState> {
  final GuideProfileRepository _repository;

  GuideProfileCubit(this._repository) : super(GuideProfileLoading());

  Future<void> loadProfile() async {
    emit(GuideProfileLoading());
    debugPrint('🔍 GuideProfileCubit.loadProfile()');

    try {
      final token = await SecureStorage.getToken();
      if (token == null) {
        emit(const GuideProfileError('Не авторизован'));
        return;
      }

      final result = await _repository.getProfile(token);
      result.fold(
        (failure) => emit(GuideProfileError(failure.message)),
        (profile) => emit(GuideProfileLoaded(profile: profile)),
      );
    } catch (e) {
      debugPrint('❌ Error: $e');
      emit(GuideProfileError('Ошибка: $e'));
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? carModel,
    String? carNumber,
    int? experienceYears,
    List<String>? languages,
  }) async {
    final current = state;
    if (current is! GuideProfileLoaded) return;

    emit(GuideProfileLoading());

    final token = await SecureStorage.getToken();
    if (token == null) {
      emit(const GuideProfileError('Токен не найден'));
      return;
    }

    final result = await _repository.updateProfile(
      token: token,
      fullName: fullName,
      carModel: carModel,
      carNumber: carNumber,
      experienceYears: experienceYears,
      languages: languages,
    );

    result.fold(
      (failure) => emit(GuideProfileError(failure.message)),
      (profile) => emit(GuideProfileLoaded(profile: profile)),
    );
  }

  Future<void> updateAvatar(Uint8List bytes) async {
    final current = state;
    if (current is! GuideProfileLoaded) return;

    emit(GuideProfileLoading());

    final token = await SecureStorage.getToken();
    if (token == null) {
      emit(const GuideProfileError('Токен не найден'));
      return;
    }

    final result = await _repository.updateAvatar(
      token: token,
      avatarBytes: bytes.toList(),
    );

    result.fold(
      (failure) => emit(GuideProfileError(failure.message)),
      (avatarUrl) {
        final updatedGuide = current.profile.guide.copyWith(avatarUrl: avatarUrl);
        final updatedProfile = current.profile.copyWith(guide: updatedGuide);
        emit(GuideProfileLoaded(profile: updatedProfile));
      },
    );
  }

  void logout() {
    SecureStorage.clearAll();
    emit(GuideProfileInitial());
  }
}