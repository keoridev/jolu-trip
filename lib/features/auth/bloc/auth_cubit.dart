import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/features/auth/domain/repositories/auth_repository.dart';
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

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (token) => emit(AuthSuccess(token: token)),
    );
  }

  void reset() => emit(const AuthInitial());
}
