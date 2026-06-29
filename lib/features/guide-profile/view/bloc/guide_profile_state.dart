import 'package:equatable/equatable.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';

abstract class GuideProfileState extends Equatable {
  const GuideProfileState();
  @override
  List<Object?> get props => [];
}

class GuideProfileInitial extends GuideProfileState {}

class GuideProfileLoading extends GuideProfileState {}

class GuideProfileLoaded extends GuideProfileState {
  final GuideProfileEntity profile;
  const GuideProfileLoaded({required this.profile});
  @override
  List<Object?> get props => [profile];
}

class GuideProfileError extends GuideProfileState {
  final String message;
  const GuideProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
