import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileGuest extends ProfileState {
  const ProfileGuest();
}

class ProfileAuthenticated extends ProfileState {
  final String name;
  final String phone;
  final String? avatarUrl;
  final int ecoPoints;

  const ProfileAuthenticated({
    required this.name,
    required this.phone,
    this.avatarUrl,
    this.ecoPoints = 0,
  });

  @override
  List<Object?> get props => [name, phone, avatarUrl, ecoPoints];
}
