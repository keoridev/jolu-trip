
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
      final token = response['token'] as String;
      final user = response['user'] as Map<String, dynamic>;

      final userId = user['id'] as String;
      final fullName = user['full_name'] as String? ?? '';
      final avatarUrl = user['avatar_url'] as String? ?? '';

      // Сохраняем ВСЕ данные
      await SecureStorage.saveAuthData(
        token: token,
        userId: userId,
        phone: user['phone'] as String,
        name: fullName.isNotEmpty ? fullName : null,
        avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
      );

      emit(AuthSuccess(token: token));
    });
  }

  void reset() => emit(const AuthInitial());
}
