import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/features/auth/domain/repositories/repositories.dart';
import '../../../core/storage/secure_storage.dart';
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
      final user = response['user'] as Map<String, dynamic>;

      await SecureStorage.saveAuthData(
        token: token,
        userId: user['id'] as String,
        phone: user['phone'] as String,
        name: user['full_name'] as String? ?? '',
        avatarUrl: user['avatar_url'] as String? ?? '',
      );

      emit(AuthSuccess(token: token));
    });
  }

  void reset() => emit(const AuthInitial());
}
