import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/guide_auth/view/bloc/guide_auth_cubit.dart';
import 'package:jolutrip_app/features/guide_auth/view/bloc/guide_auth_state.dart';
import 'package:jolutrip_app/features/guide_auth/view/widgets/guide_auth_tabs.dart';

class GuideAuthScreen extends StatelessWidget {
  const GuideAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: BlocConsumer<GuideAuthCubit, GuideAuthState>(
          listener: _handleStateChange,
          builder: (context, state) {
            final isLoading = state is GuideAuthLoading;

            // Показываем OTP, если код отправлен или есть ошибка
            if (state is GuideLoginOtpSent ||
                state is GuideRegisterOtpSent ||
                state is GuideOtpInvalid ||
                state is GuideSmsResent) {
              return _buildOtpView(context, state, isLoading);
            }

            // Иначе показываем форму ввода телефона (и имени/пола для регистрации)
            return GuideAuthTabs(
              key: const ValueKey('guide_auth_tabs'),
              isLoading: isLoading,
              onBack: () => context.pop(),
              onLoginSubmit: (phone) =>
                  context.read<GuideAuthCubit>().sendLoginOtp(phone),
              onRegisterSubmit: (phone, name, gender) =>
                  context.read<GuideAuthCubit>().sendRegisterOtp(
                    fullName: name,
                    gender: gender,
                    phone: phone,
                  ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOtpView(
    BuildContext context,
    GuideAuthState state,
    bool isLoading,
  ) {
    final phone = switch (state) {
      GuideLoginOtpSent p => p.phone,
      GuideRegisterOtpSent p => p.phone,
      GuideOtpInvalid p => p.phone,
      GuideSmsResent p => p.phone,
      _ => '',
    };

    final isLoginMode = switch (state) {
      GuideLoginOtpSent _ => true,
      GuideRegisterOtpSent _ => false,
      GuideOtpInvalid p => p.isLoginMode,
      GuideSmsResent _ => context.read<GuideAuthCubit>().isLoginMode,
      _ => true,
    };

    return OtpView(
      key: ValueKey('otp_$phone'), // Ключ для сброса состояния при смене номера
      phone: phone,
      isLoading: isLoading,
      secondsLeft: (state as dynamic).secondsLeft ?? 59,
      canResend: (state as dynamic).canResend ?? false,
      invalidAttempt: state is GuideOtpInvalid ? state.attempt : null,
      submitButtonText: isLoginMode ? 'Войти' : 'Зарегистрироваться',
      onBack: () => context.read<GuideAuthCubit>().reset(),
      onVerify: (code) {
        if (isLoginMode) {
          context.read<GuideAuthCubit>().verifyLoginOtp(phone, code);
        } else if (state is GuideRegisterOtpSent) {
          context.read<GuideAuthCubit>().verifyRegisterOtp(
            fullName: state.fullName,
            gender: state.gender,
            phone: phone,
            code: code,
          );
        }
      },
      onResend: () => context.read<GuideAuthCubit>().resendSms(phone),
    );
  }

  void _handleStateChange(BuildContext context, GuideAuthState state) {
    // 1. Ошибка ввода OTP
    if (state is GuideOtpInvalid) {
      JoluSnackbar.show(
        context: context,
        message: 'Неверный код.',
        type: JoluSnackbarType.error,
      );
      return;
    }

    // 2. Общие ошибки API
    if (state is GuideAuthError) {
      JoluSnackbar.show(
        context: context,
        message: state.message,
        type: JoluSnackbarType.error,
      );
      return;
    }

    if (state is GuideNeedsOnboarding) {
      context.go(
        '/guide/onboarding',
        extra: {'guideId': state.guide.id, 'token': state.token},
      );
      return;
    }

    if (state is GuideOnboardingPending) {
      context.go('/guide/onboarding', extra: {'guideId': state.guide.id});
      return;
    }

    if (state is GuideAuthSuccess) {
      context.go('/guide/dashboard');
      return;
    }
  }
}
