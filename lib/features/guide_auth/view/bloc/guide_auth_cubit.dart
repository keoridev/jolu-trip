import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/core/storage/secure_storage.dart';
import 'package:jolutrip_app/features/guide_auth/data/models/guide_model.dart';
import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';
import 'package:jolutrip_app/features/guide_auth/domain/repositories/guide_auth_repository.dart';
import 'guide_auth_state.dart';

class GuideAuthCubit extends Cubit<GuideAuthState> {
  final GuideAuthRepository _repository;

  String? _currentToken;
  GuideEntity? _currentGuide;
  int _otpAttempt = 0;

  // Таймер OTP
  Timer? _otpTimer;
  int _secondsLeft = 59;
  bool _canResend = false;

  // Сохраненные данные для повторной отправки
  String? _currentPhone;
  String? _currentFullName;
  GuideGender? _currentGender;
  bool _isLoginMode = true; // ← флаг режима

  GuideAuthCubit(this._repository) : super(GuideAuthInitial());

  String? get currentToken => _currentToken;
  GuideEntity? get currentGuide => _currentGuide;
  bool get isLoginMode => _isLoginMode; // ← геттер для UI

  void selectMode(bool isLogin) {
    _isLoginMode = isLogin;
    emit(GuideAuthModeSelection(isLogin: isLogin));
  }

  void reset() {
    _stopTimer();
    _otpAttempt = 0;
    _secondsLeft = 59;
    _canResend = false;
    _currentPhone = null;
    _currentFullName = null;
    _currentGender = null;
    _isLoginMode = true;
    emit(GuideAuthInitial());
  }

  // ============= ТАЙМЕР =============

  void _startTimer() {
    _stopTimer();
    _secondsLeft = 59;
    _canResend = false;
    _updateOtpState();

    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }

      if (_secondsLeft == 0) {
        timer.cancel();
        _canResend = true;
        _updateOtpState();
      } else {
        _secondsLeft--;
        _updateOtpState();
      }
    });
  }

  void _stopTimer() {
    _otpTimer?.cancel();
    _otpTimer = null;
  }

  void _updateOtpState() {
    if (isClosed) return;

    final currentState = state;

    if (currentState is GuideLoginOtpSent) {
      emit(currentState.copyWith(secondsLeft: _secondsLeft, canResend: _canResend));
    } else if (currentState is GuideRegisterOtpSent) {
      emit(currentState.copyWith(secondsLeft: _secondsLeft, canResend: _canResend));
    } else if (currentState is GuideOtpInvalid) {
      emit(currentState.copyWith(secondsLeft: _secondsLeft, canResend: _canResend));
    } else if (currentState is GuideSmsResent) {
      emit(currentState.copyWith(secondsLeft: _secondsLeft, canResend: _canResend));
    }
  }

  // ============= ЛОГИН =============

  Future<void> sendLoginOtp(String phone) async {
    _currentPhone = phone;
    _isLoginMode = true;
    _otpAttempt = 0;

    emit(GuideAuthLoading());
    final result = await _repository.sendLoginOtp(phone);
    result.fold(
      (failure) => emit(GuideAuthError(failure.message)),
      (_) {
        _startTimer();
        emit(GuideLoginOtpSent(
          phone: phone,
          secondsLeft: _secondsLeft,
          canResend: _canResend,
        ));
      },
    );
  }

  Future<void> verifyLoginOtp(String phone, String code) async {
    emit(GuideAuthLoading());
    final result = await _repository.verifyLoginOtp(phone, code);
    result.fold(
      (failure) => _handleOtpFailure(failure, phone),
      (data) => _handleAuthResponse(data),
    );
  }

  // ============= РЕГИСТРАЦИЯ =============

  void proceedToRegister(String phone) {
    _currentPhone = phone;
    _isLoginMode = false;
    emit(GuideRegisterStep1(phone));
  }

  Future<void> sendRegisterOtp({
    required String fullName,
    required GuideGender gender,
    required String phone,
  }) async {
    _currentPhone = phone;
    _currentFullName = fullName;
    _currentGender = gender;
    _isLoginMode = false;
    _otpAttempt = 0;

    emit(GuideAuthLoading());
    final result = await _repository.sendRegisterOtp(
      fullName: fullName,
      gender: gender,
      phone: phone,
    );
    result.fold(
      (failure) => emit(GuideAuthError(failure.message)),
      (_) {
        _startTimer();
        emit(GuideRegisterOtpSent(
          fullName: fullName,
          gender: gender,
          phone: phone,
          secondsLeft: _secondsLeft,
          canResend: _canResend,
        ));
      },
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
      (failure) => _handleOtpFailure(failure, phone),
      (data) => _handleAuthResponse(data),
    );
  }

  // ============= ПОВТОРНАЯ ОТПРАВКА =============

  Future<void> resendSms(String phone) async {
    final result = await _repository.resendSms(phone);
    result.fold(
      (failure) => emit(GuideAuthError(failure.message)),
      (_) {
        _otpAttempt = 0;
        _startTimer();

        final resentState = GuideSmsResent(
          phone: phone,
          secondsLeft: _secondsLeft,
          canResend: _canResend,
        );
        emit(resentState);

        // Переходим в соответствующее OTP-состояние
        Future.delayed(const Duration(milliseconds: 100), () {
          if (isClosed) return;
          if (_isLoginMode) {
            emit(GuideLoginOtpSent(
              phone: phone,
              secondsLeft: _secondsLeft,
              canResend: _canResend,
            ));
          } else {
            emit(GuideRegisterOtpSent(
              fullName: _currentFullName!,
              gender: _currentGender!,
              phone: phone,
              secondsLeft: _secondsLeft,
              canResend: _canResend,
            ));
          }
        });
      },
    );
  }

  // ============= HELPERS =============

  void _handleOtpFailure(Failure failure, String phone) {
    if (_isOtpFailure(failure)) {
      emit(GuideOtpInvalid(
        phone: phone,
        message: failure.message,
        attempt: ++_otpAttempt,
        secondsLeft: _secondsLeft,
        canResend: _canResend,
        isLoginMode: _isLoginMode, // ← передаём флаг
      ));
      // Возвращаемся в OTP-состояние
      Future.delayed(Duration.zero, () {
        if (isClosed) return;
        if (_isLoginMode) {
          emit(GuideLoginOtpSent(
            phone: phone,
            secondsLeft: _secondsLeft,
            canResend: _canResend,
          ));
        } else {
          emit(GuideRegisterOtpSent(
            fullName: _currentFullName!,
            gender: _currentGender!,
            phone: phone,
            secondsLeft: _secondsLeft,
            canResend: _canResend,
          ));
        }
      });
    } else {
      emit(GuideAuthError(failure.message));
    }
  }

  bool _isOtpFailure(Failure failure) {
    return failure is ServerFailure && failure.statusCode == 400;
  }

  void _handleAuthResponse(Map<String, dynamic> data) {
    try {
      final token = data['token'] as String?;
      if (token == null) {
        emit(const GuideAuthError('Ошибка: токен не получен от сервера'));
        return;
      }

      // Парсим гида из ответа сервера (не из JWT!)
      final guide = GuideModel.fromLoginResponse(data);

      _currentToken = token;
      _currentGuide = guide;
      _stopTimer();

      // Сохраняем токен и данные
      SecureStorage.saveAuthData(
        token: token,
        userId: guide.id,
        phone: guide.phone,
        name: guide.fullName,
        role: 'guide',
      ).catchError((e) {
        debugPrint('⚠️ Failed to save auth data: $e');
      });

      debugPrint(
        '🔑 Login success. Status: ${guide.status}, Token: ${token.substring(0, 20)}...',
      );

      // Редирект на основе статуса
      switch (guide.status) {
        case GuideStatus.pending:
          emit(GuideNeedsOnboarding(token: token, guide: guide));
          break;
        case GuideStatus.unverified:
          emit(GuideOnboardingPending(guide: guide));
          break;
        case GuideStatus.verified:
        case GuideStatus.rejected:
          emit(GuideAuthSuccess(token: token, guide: guide));
          break;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing auth response: $e');
      debugPrint(stackTrace.toString());
      emit(GuideAuthError('Ошибка обработки ответа: $e'));
    }
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}