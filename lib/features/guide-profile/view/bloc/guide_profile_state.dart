import 'package:equatable/equatable.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';

sealed class GuideProfileState extends Equatable {
  const GuideProfileState();

  @override
  List<Object?> get props => [];
}

final class GuideProfileInitial extends GuideProfileState {
  const GuideProfileInitial();
}

final class GuideProfileLoading extends GuideProfileState {
  const GuideProfileLoading();
}

final class GuideProfileLoaded extends GuideProfileState {
  final GuideProfileEntity profile;

  const GuideProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

final class GuideProfileError extends GuideProfileState {
  final String message;

  const GuideProfileError(this.message);

  @override
  List<Object?> get props => [message];
}