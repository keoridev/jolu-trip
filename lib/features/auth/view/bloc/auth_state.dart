import 'package:equatable/equatable.dart';
import 'package:jolutrip_app/features/auth/data/models/models.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthOtpSent extends AuthState {
  final String phone;
  const AuthOtpSent({required this.phone});
  @override
  List<Object?> get props => [phone];
}

class AuthSuccess extends AuthState {
  final UserModel? user;
  final String token; // ← ДОБАВИТЬ

  const AuthSuccess({this.user, required this.token}); // ← ДОБАВИТЬ

  @override
  List<Object?> get props => [user, token]; // ← ДОБАВИТЬ
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override
  List<Object?> get props => [message];
}
