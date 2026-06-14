import 'package:equatable/equatable.dart';
import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';

abstract class GuideAuthState extends Equatable {
  const GuideAuthState();
  @override
  List<Object?> get props => [];
}

class GuideAuthInitial extends GuideAuthState {}

class GuideAuthLoading extends GuideAuthState {}

class GuideAuthModeSelection extends GuideAuthState {
  final bool isLogin;
  const GuideAuthModeSelection({this.isLogin = true});
}

class GuideLoginOtpSent extends GuideAuthState {
  final String phone;
  const GuideLoginOtpSent(this.phone);
  @override
  List<Object?> get props => [phone];
}

class GuideRegisterStep1 extends GuideAuthState {
  final String phone;
  const GuideRegisterStep1(this.phone);
  @override
  List<Object?> get props => [phone];
}

class GuideRegisterOtpSent extends GuideAuthState {
  final String fullName;
  final GuideGender gender;
  final String phone;
  const GuideRegisterOtpSent({
    required this.fullName,
    required this.gender,
    required this.phone,
  });
  @override
  List<Object?> get props => [fullName, gender, phone];
}

// ═══════════════════════════════════════════════════
// NEW: Auth completed, but need to check status
// ═══════════════════════════════════════════════════

/// Гид успешно авторизовался, но нужно проверить статус
class GuideAuthAuthenticated extends GuideAuthState {
  final String token;
  final GuideEntity guide;
  const GuideAuthAuthenticated({required this.token, required this.guide});
  @override
  List<Object?> get props => [token, guide];
}

/// Гиду нужно пройти onboarding (статус unverified)
class GuideNeedsOnboarding extends GuideAuthState {
  final String token;
  final GuideEntity guide;
  const GuideNeedsOnboarding({required this.token, required this.guide});
  @override
  List<Object?> get props => [token, guide];
}

/// Гид отправил документы, ждёт модерации (статус pending)
class GuideOnboardingPending extends GuideAuthState {
  final GuideEntity guide;
  const GuideOnboardingPending({required this.guide});
  @override
  List<Object?> get props => [guide];
}

/// Гид полностью верифицирован (статус verified)
class GuideAuthSuccess extends GuideAuthState {
  final String token;
  final GuideEntity guide;
  const GuideAuthSuccess({required this.token, required this.guide});
  @override
  List<Object?> get props => [token, guide];
}

class GuideAuthError extends GuideAuthState {
  final String message;
  const GuideAuthError(this.message);
  @override
  List<Object?> get props => [message];
}