// features/auth/bloc/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/storage/secure_storage.dart';
import 'package:jolutrip_app/features/auth/data/models/models.dart';
import 'package:jolutrip_app/features/auth/domain/repositories/repositories.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial());

  Future<void> sendOtp(String phone) async {
    emit(const AuthLoading());
    final result = await _authRepository.sendOtp(phone);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthOtpSent(phone: phone)),
    );
  }

  Future<void> verifyOtp(String phone, String code) async {
    emit(const AuthLoading());
    final result = await _authRepository.verifyOtp(phone, code);

    result.fold((failure) => emit(AuthError(message: failure.message)), (
      response,
    ) async {
      // Парсим ответ
      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>?;

      // Сохраняем в SecureStorage
      await SecureStorage.saveAuthData(
        token: token,
        userId: userData?['id'] as String? ?? '',
        phone: userData?['phone'] as String? ?? phone,
        name: userData?['full_name'] as String? ?? '',
        avatarUrl: userData?['avatar_url'] as String? ?? '',
        role: 'tourist',
      );

      // Создаём UserModel если есть данные
      final user = userData != null ? UserModel.fromJson(userData) : null;

      emit(AuthSuccess(token: token, user: user)); // ← token теперь передаётся
    });
  }

  void reset() => emit(const AuthInitial());
}
