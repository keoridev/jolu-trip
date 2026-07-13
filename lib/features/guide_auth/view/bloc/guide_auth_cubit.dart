import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/errors/failures.dart';
import 'package:jolutrip_app/core/storage/secure_storage.dart';
import 'package:jolutrip_app/features/guide_auth/data/models/model.dart';
import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';
import 'package:jolutrip_app/features/guide_auth/domain/repositories/guide_auth_repository.dart';
import 'guide_auth_state.dart';
import 'dart:convert';

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

  void selectMode(bool isLogin) =>
      emit(GuideAuthModeSelection(isLogin: isLogin));

  void reset() {
    _stopTimer();
    _otpAttempt = 0;
    _secondsLeft = 59;
    _canResend = false;
    _currentPhone = null;
    _currentFullName = null;
    _currentGender = null;
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
    // Проверяем, не закрыт ли Cubit
    if (isClosed) return;

    final currentState = state;

    // Обновляем текущее OTP состояние с новыми значениями таймера
    if (currentState is GuideLoginOtpSent) {
      emit(
        currentState.copyWith(secondsLeft: _secondsLeft, canResend: _canResend),
      );
    } else if (currentState is GuideRegisterOtpSent) {
      emit(
        currentState.copyWith(secondsLeft: _secondsLeft, canResend: _canResend),
      );
    } else if (currentState is GuideOtpInvalid) {
      emit(
        currentState.copyWith(secondsLeft: _secondsLeft, canResend: _canResend),
      );
    } else if (currentState is GuideSmsResent) {
      emit(
        currentState.copyWith(secondsLeft: _secondsLeft, canResend: _canResend),
      );
    }
  }

  // ============= ЛОГИН =============

  Future<void> sendLoginOtp(String phone) async {
    _currentPhone = phone;
    _isLoginMode = true;
    _otpAttempt = 0;

    emit(GuideAuthLoading());
    final result = await _repository.sendLoginOtp(phone);
    result.fold((failure) => emit(GuideAuthError(failure.message)), (_) {
      _startTimer();
      emit(
        GuideLoginOtpSent(
          phone: phone,
          secondsLeft: _secondsLeft,
          canResend: _canResend,
        ),
      );
    });
  }

  Future<void> verifyLoginOtp(String phone, String code) async {
    emit(GuideAuthLoading());
    final result = await _repository.verifyLoginOtp(phone, code);
    result.fold((failure) {
      if (_isOtpFailure(failure)) {
        // НЕ сбрасываем таймер, просто показываем ошибку
        emit(
          GuideOtpInvalid(
            phone: phone,
            message: failure.message,
            attempt: ++_otpAttempt,
            secondsLeft: _secondsLeft,
            canResend: _canResend,
          ),
        );
        // Возвращаемся в состояние OTP с сохраненным таймером
        Future.delayed(Duration.zero, () {
          if (!isClosed) {
            emit(
              GuideLoginOtpSent(
                phone: phone,
                secondsLeft: _secondsLeft,
                canResend: _canResend,
              ),
            );
          }
        });
      } else {
        emit(GuideAuthError(failure.message));
      }
    }, (data) => _handleAuthResponse(data));
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
    result.fold((failure) => emit(GuideAuthError(failure.message)), (_) {
      _startTimer();
      emit(
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
    emit(GuideAuthLoading());
    final result = await _repository.verifyRegisterOtp(
      fullName: fullName,
      gender: gender,
      phone: phone,
      code: code,
    );
    result.fold((failure) {
      if (_isOtpFailure(failure)) {
        emit(
          GuideOtpInvalid(
            phone: phone,
            message: failure.message,
            attempt: ++_otpAttempt,
            secondsLeft: _secondsLeft,
            canResend: _canResend,
          ),
        );
        Future.delayed(Duration.zero, () {
          if (!isClosed) {
            emit(
              GuideRegisterOtpSent(
                fullName: fullName,
                gender: gender,
                phone: phone,
                secondsLeft: _secondsLeft,
                canResend: _canResend,
              ),
            );
          }
        });
      } else {
        emit(GuideAuthError(failure.message));
      }
    }, (data) => _handleAuthResponse(data));
  }

  // ============= ПОВТОРНАЯ ОТПРАВКА =============

  Future<void> resendSms(String phone) async {
    // Сразу очищаем поля и сбрасываем таймер в UI
    // Это делается через состояние

    final result = await _repository.resendSms(phone);
    result.fold(
      (failure) {
        // Показываем ошибку
        emit(GuideAuthError(failure.message));
      },
      (_) {
        // Сбрасываем счетчик попыток
        _otpAttempt = 0;

        // СТАРТУЕМ НОВЫЙ ТАЙМЕР
        _startTimer();

        // Показываем состояние "повторная отправка" с очищенными полями
        if (_isLoginMode) {
          emit(
            GuideSmsResent(
              phone: phone,
              secondsLeft: _secondsLeft,
              canResend: _canResend,
            ),
          );
          // Сразу переходим в OTP состояние с новым таймером
          // Это заставит OtpView очистить поля
          Future.delayed(const Duration(milliseconds: 100), () {
            if (!isClosed) {
              emit(
                GuideLoginOtpSent(
                  phone: phone,
                  secondsLeft: _secondsLeft,
                  canResend: _canResend,
                ),
              );
            }
          });
        } else {
          emit(
            GuideSmsResent(
              phone: phone,
              secondsLeft: _secondsLeft,
              canResend: _canResend,
            ),
          );
          Future.delayed(const Duration(milliseconds: 100), () {
            if (!isClosed) {
              emit(
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
        }
      },
    );
  }
  // ============= HELPER =============

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

      final userId = data['id']?.toString() ?? '';

      // Парсим минимальные данные из ответа login/verify
      // Полные данные (fullName, phone, avatar) загрузим через /guides/me
      final guide = GuideModel.fromLoginResponse(data);

      _currentToken = token;
      _currentGuide = guide;
      _stopTimer();

      // Сохраняем токен и базовые данные
      SecureStorage.saveAuthData(
        token: token,
        userId: userId,
        phone: guide.phone,
        name: guide.fullName,
        role: 'guide',
      ).catchError((e) {
        debugPrint('⚠️ Failed to save auth data: $e');
      });

      // Статус из ответа или из токена
      // JWT payload: {"user_id", "exp", "iat", "role", "status"}
      final status =
          _extractStatusFromToken(token) ??
          data['status']?.toString() ??
          'pending';

      debugPrint(
        '🔑 Login success. Status: $status, Token: ${token.substring(0, 20)}...',
      );

      // Редирект на основе статуса
      switch (status) {
        case 'pending':
          emit(GuideNeedsOnboarding(token: token, guide: guide));
          break;
        case 'unverified':
          emit(GuideOnboardingPending(guide: guide));
          break;
        case 'verified':
        case 'active':
          emit(GuideAuthSuccess(token: token, guide: guide));
          break;
        default:
          // Для "successfully login" или неизвестного — идём на dashboard
          // Профиль загрузится там через GuideProfileCubit
          emit(GuideAuthSuccess(token: token, guide: guide));
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing auth response: $e');
      debugPrint(stackTrace.toString());
      emit(GuideAuthError('Ошибка обработки ответа: $e'));
    }
  }

  String? _extractStatusFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      // Добавляем padding если нужно
      final normalized = payload.padRight(
        payload.length + (4 - payload.length % 4) % 4,
        '=',
      );
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      return json['status'] as String?;
    } catch (e) {
      debugPrint('⚠️ Failed to decode JWT: $e');
      return null;
    }
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}
