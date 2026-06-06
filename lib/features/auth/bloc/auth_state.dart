import 'package:equatable/equatable.dart';
import 'package:jolutrip_app/features/auth/data/models/user_model.dart';

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
  const AuthSuccess({this.user, required String token});

  final UserModel? user;

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
