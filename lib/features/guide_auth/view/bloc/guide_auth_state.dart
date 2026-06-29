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

// Базовое состояние для OTP с таймером
abstract class GuideOtpState extends GuideAuthState {
  final String phone;
  final int secondsLeft;
  final bool canResend;
  
  const GuideOtpState({
    required this.phone,
    this.secondsLeft = 59,
    this.canResend = false,
  });
  
  @override
  List<Object?> get props => [phone, secondsLeft, canResend];
}

class GuideLoginOtpSent extends GuideOtpState {
  const GuideLoginOtpSent({
    required super.phone,
    super.secondsLeft = 59,
    super.canResend = false,
  });

  GuideLoginOtpSent copyWith({
    String? phone,
    int? secondsLeft,
    bool? canResend,
  }) {
    return GuideLoginOtpSent(
      phone: phone ?? this.phone,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      canResend: canResend ?? this.canResend,
    );
  }
}

class GuideRegisterOtpSent extends GuideOtpState {
  final String fullName;
  final GuideGender gender;
  
  const GuideRegisterOtpSent({
    required this.fullName,
    required this.gender,
    required super.phone,
    super.secondsLeft = 59,
    super.canResend = false,
  });
  
  @override
  List<Object?> get props => [fullName, gender, phone, secondsLeft, canResend];

  GuideRegisterOtpSent copyWith({
    String? fullName,
    GuideGender? gender,
    String? phone,
    int? secondsLeft,
    bool? canResend,
  }) {
    return GuideRegisterOtpSent(
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      canResend: canResend ?? this.canResend,
    );
  }
}

class GuideSmsResent extends GuideOtpState {
  const GuideSmsResent({
    required super.phone,
    super.secondsLeft = 59,
    super.canResend = false,
  });

  GuideSmsResent copyWith({
    String? phone,
    int? secondsLeft,
    bool? canResend,
  }) {
    return GuideSmsResent(
      phone: phone ?? this.phone,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      canResend: canResend ?? this.canResend,
    );
  }
}

class GuideOtpInvalid extends GuideOtpState {
  final String message;
  final int attempt;
  
  const GuideOtpInvalid({
    required super.phone,
    required this.message,
    this.attempt = 1,
    super.secondsLeft = 59,
    super.canResend = false,
  });
  
  @override
  List<Object?> get props => [phone, message, attempt, secondsLeft, canResend];

  GuideOtpInvalid copyWith({
    String? phone,
    String? message,
    int? attempt,
    int? secondsLeft,
    bool? canResend,
  }) {
    return GuideOtpInvalid(
      phone: phone ?? this.phone,
      message: message ?? this.message,
      attempt: attempt ?? this.attempt,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      canResend: canResend ?? this.canResend,
    );
  }
}

class GuideRegisterStep1 extends GuideAuthState {
  final String phone;
  const GuideRegisterStep1(this.phone);
  @override
  List<Object?> get props => [phone];
}

class GuideAuthAuthenticated extends GuideAuthState {
  final String token;
  final GuideEntity guide;
  const GuideAuthAuthenticated({required this.token, required this.guide});
  @override
  List<Object?> get props => [token, guide];
}

class GuideNeedsOnboarding extends GuideAuthState {
  final String token;
  final GuideEntity guide;
  const GuideNeedsOnboarding({required this.token, required this.guide});
  @override
  List<Object?> get props => [token, guide];
}

class GuideOnboardingPending extends GuideAuthState {
  final GuideEntity guide;
  const GuideOnboardingPending({required this.guide});
  @override
  List<Object?> get props => [guide];
}

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