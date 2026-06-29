
import 'package:equatable/equatable.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';

abstract class GuideOnboardingState extends Equatable {
  const GuideOnboardingState();
  @override
  List<Object?> get props => [];
}

class GuideOnboardingInitial extends GuideOnboardingState {}

class GuideOnboardingLoading extends GuideOnboardingState {}

class GuideOnboardingSubmitted extends GuideOnboardingState {
  final OnboardingEntity onboarding;
  const GuideOnboardingSubmitted({required this.onboarding});
  @override
  List<Object?> get props => [onboarding];
}

class GuideOnboardingError extends GuideOnboardingState {
  final String message;
  const GuideOnboardingError(this.message);
  @override
  List<Object?> get props => [message];
}
