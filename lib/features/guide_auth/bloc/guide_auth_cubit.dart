// lib/features/guide_auth/presentation/bloc/guide_auth_cubit.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/storage/secure_storage.dart';
import 'package:jolutrip_app/features/guide_auth/data/models/guide_model.dart';
import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';
import 'package:jolutrip_app/features/guide_auth/domain/repositories/guide_auth_repository.dart';
import 'guide_auth_state.dart';

class GuideAuthCubit extends Cubit<GuideAuthState> {
  final GuideAuthRepository _repository;

  String? _currentToken;
  GuideEntity? _currentGuide;

  GuideAuthCubit(this._repository) : super(GuideAuthInitial());

  String? get currentToken => _currentToken;
  GuideEntity? get currentGuide => _currentGuide;

  void selectMode(bool isLogin) =>
      emit(GuideAuthModeSelection(isLogin: isLogin));
  void reset() => emit(GuideAuthInitial());

  Future<void> sendLoginOtp(String phone) async {
    emit(GuideAuthLoading());
    final result = await _repository.sendLoginOtp(phone);
    result.fold(
      (failure) => emit(GuideAuthError(failure.message)),
      (_) => emit(GuideLoginOtpSent(phone)),
    );
  }

  Future<void> verifyLoginOtp(String phone, String code) async {
    emit(GuideAuthLoading());
    final result = await _repository.verifyLoginOtp(phone, code);
    result.fold(
      (failure) => emit(GuideAuthError(failure.message)),
      (data) => _handleAuthResponse(data),
    );
  }

  void proceedToRegister(String phone) => emit(GuideRegisterStep1(phone));

  Future<void> sendRegisterOtp({
    required String fullName,
    required GuideGender gender,
    required String phone,
  }) async {
    emit(GuideAuthLoading());
    final result = await _repository.sendRegisterOtp(
      fullName: fullName,
      gender: gender,
      phone: phone,
    );
    result.fold(
      (failure) => emit(GuideAuthError(failure.message)),
      (_) => emit(
        GuideRegisterOtpSent(fullName: fullName, gender: gender, phone: phone),
      ),
    );
  }

  Future<void> verifyRegisterOtp({
    required String fullName,
    required GuideGender gender,
    required String phone,
    required String code,
  }) async {
    emit(GuideAuthLoading());
    final result = await _repository.verifyRegisterOtp(
      fullName: fullName,
      gender: gender,
      phone: phone,
      code: code,
    );
    result.fold(
      (failure) => emit(GuideAuthError(failure.message)),
      (data) => _handleAuthResponse(data),
    );
  }

  void _handleAuthResponse(Map<String, dynamic> data) {
    try {
      final token = data['token'] as String?;
      if (token == null) {
        emit(const GuideAuthError('Ошибка: токен не получен от сервера'));
        return;
      }

      final userId = data['id'] as String? ?? '';
      final guide = GuideModel.fromJson(data);

      _currentToken = token;
      _currentGuide = guide;

      SecureStorage.saveAuthData(
        token: token,
        userId: userId,
        phone: guide.phone,
        name: guide.fullName,
      ).catchError((e) {
        debugPrint('⚠️ Failed to save auth data: $e');
      });

      if (guide.needsOnboarding) {
        emit(GuideNeedsOnboarding(token: token, guide: guide));
      } else if (guide.isPending) {
        emit(GuideOnboardingPending(guide: guide));
      } else if (guide.isVerified) {
        emit(GuideAuthSuccess(token: token, guide: guide));
      } else {
        emit(GuideAuthAuthenticated(token: token, guide: guide));
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing auth response: $e');
      debugPrint(stackTrace.toString());
      emit(GuideAuthError('Ошибка обработки ответа: $e'));
    }
  }
}