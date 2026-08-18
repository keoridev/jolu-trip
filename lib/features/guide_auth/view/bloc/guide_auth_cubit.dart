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
  bool _isLoginMode = true;

  GuideAuthCubit(this._repository) : super(GuideAuthInitial());

  String? get currentToken => _currentToken;
  GuideEntity? get currentGuide => _currentGuide;
  bool get isLoginMode => _isLoginMode;

  void _safeEmit(GuideAuthState state) {
    if (!isClosed) emit(state);
  }

  void selectMode(bool isLogin) {
    _isLoginMode = isLogin;
    _safeEmit(GuideAuthModeSelection(isLogin: isLogin));
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
    _safeEmit(GuideAuthInitial());
  }

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
      _safeEmit(
        currentState.copyWith(secondsLeft: _secondsLeft, canResend: _canResend),
      );
    } else if (currentState is GuideRegisterOtpSent) {
      _safeEmit(
        currentState.copyWith(secondsLeft: _secondsLeft, canResend: _canResend),
      );
    } else if (currentState is GuideOtpInvalid) {
      _safeEmit(
        currentState.copyWith(secondsLeft: _secondsLeft, canResend: _canResend),
      );
    } else if (currentState is GuideSmsResent) {
      _safeEmit(
        currentState.copyWith(secondsLeft: _secondsLeft, canResend: _canResend),
      );
    }
  }

  Future<void> sendLoginOtp(String phone) async {
    _currentPhone = phone;
    _isLoginMode = true;
    _otpAttempt = 0;

    _safeEmit(GuideAuthLoading());
    final result = await _repository.sendLoginOtp(phone);
    if (isClosed) return;

    result.fold((failure) => _safeEmit(GuideAuthError(failure.message)), (_) {
      _startTimer();
      _safeEmit(
        GuideLoginOtpSent(
          phone: phone,
          secondsLeft: _secondsLeft,
          canResend: _canResend,
        ),
      );
    });
  }

  Future<void> verifyLoginOtp(String phone, String code) async {
    _safeEmit(GuideAuthLoading());
    final result = await _repository.verifyLoginOtp(phone, code);
    if (isClosed) return;

    result.fold(
      (failure) => _handleOtpFailure(failure, phone),
      (data) => _handleAuthResponse(data),
    );
  }

  void proceedToRegister(String phone) {
    _currentPhone = phone;
    _isLoginMode = false;
    _safeEmit(GuideRegisterStep1(phone));
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

    _safeEmit(GuideAuthLoading());
    final result = await _repository.sendRegisterOtp(
      fullName: fullName,
      gender: gender,
      phone: phone,
    );
    if (isClosed) return;

    result.fold((failure) => _safeEmit(GuideAuthError(failure.message)), (_) {
      _startTimer();
      _safeEmit(
        GuideRegisterOtpSent(
          fullName: fullName,
          gender: gender,
          phone: phone,
          secondsLeft: _secondsLeft,
          canResend: _canResend,
        ),
      );
    });
  }

  Future<void> verifyRegisterOtp({
    required String fullName,
    required GuideGender gender,
    required String phone,
    required String code,
  }) async {
    _safeEmit(GuideAuthLoading());
    final result = await _repository.verifyRegisterOtp(
      fullName: fullName,
      gender: gender,
      phone: phone,
      code: code,
    );
    if (isClosed) return;

    result.fold(
      (failure) => _handleOtpFailure(failure, phone),
      (data) => _handleAuthResponse(data),
    );
  }

  Future<void> resendSms(String phone) async {
    final result = await _repository.resendSms(phone);
    if (isClosed) return;

    result.fold((failure) => _safeEmit(GuideAuthError(failure.message)), (_) {
      _otpAttempt = 0;
      _startTimer();

      final resentState = GuideSmsResent(
        phone: phone,
        secondsLeft: _secondsLeft,
        canResend: _canResend,
      );
      _safeEmit(resentState);

      Future.delayed(const Duration(milliseconds: 100), () {
        if (isClosed) return;
        if (_isLoginMode) {
          _safeEmit(
            GuideLoginOtpSent(
              phone: phone,
              secondsLeft: _secondsLeft,
              canResend: _canResend,
            ),
          );
        } else {
          _safeEmit(
            GuideRegisterOtpSent(
              fullName: _currentFullName!,
              gender: _currentGender!,
              phone: phone,
              secondsLeft: _secondsLeft,
              canResend: _canResend,
            ),
          );
        }
      });
    });
  }

  void _handleOtpFailure(Failure failure, String phone) {
    if (_isOtpFailure(failure)) {
      _safeEmit(
        GuideOtpInvalid(
          phone: phone,
          message: failure.message,
          attempt: ++_otpAttempt,
          secondsLeft: _secondsLeft,
          canResend: _canResend,
          isLoginMode: _isLoginMode,
        ),
      );
      Future.delayed(Duration.zero, () {
        if (isClosed) return;
        if (_isLoginMode) {
          _safeEmit(
            GuideLoginOtpSent(
              phone: phone,
              secondsLeft: _secondsLeft,
              canResend: _canResend,
            ),
          );
        } else {
          _safeEmit(
            GuideRegisterOtpSent(
              fullName: _currentFullName!,
              gender: _currentGender!,
              phone: phone,
              secondsLeft: _secondsLeft,
              canResend: _canResend,
            ),
          );
        }
      });
    } else {
      _safeEmit(GuideAuthError(failure.message));
    }
  }

  bool _isOtpFailure(Failure failure) {
    return failure is ServerFailure && failure.statusCode == 400;
  }

  void _handleAuthResponse(Map<String, dynamic> data) {
    if (isClosed) return;

    try {
      final token = data['token'] as String?;
      if (token == null) {
        _safeEmit(const GuideAuthError('Ошибка: токен не получен от сервера'));
        return;
      }

      final guide = GuideModel.fromLoginResponse(data);

      _currentToken = token;
      _currentGuide = guide;
      _stopTimer();

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

      switch (guide.status) {
        case GuideStatus.pending:
          _safeEmit(GuideNeedsOnboarding(token: token, guide: guide));
          break;
        case GuideStatus.unverified:
          _safeEmit(GuideOnboardingPending(guide: guide));
          break;
        case GuideStatus.verified:
        case GuideStatus.rejected:
          _safeEmit(GuideAuthSuccess(token: token, guide: guide));
          break;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing auth response: $e');
      debugPrint(stackTrace.toString());
      _safeEmit(GuideAuthError('Ошибка обработки ответа: $e'));
    }
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}