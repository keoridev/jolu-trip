import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';
import 'package:jolutrip_app/features/guide_auth/view/bloc/guide_auth_cubit.dart';
import 'package:jolutrip_app/features/guide_auth/view/bloc/guide_auth_state.dart';
import 'package:jolutrip_app/features/guide_auth/view/widgets/guide_auth_tabs.dart';

import 'package:jolutrip_app/features/guide_auth/view/widgets/guide_mode_selection.dart';
import 'package:jolutrip_app/features/guide_auth/view/widgets/guide_register_form.dart';
import 'package:jolutrip_app/features/guide_auth/view/widgets/guide_welcome.dart';

class GuideAuthScreen extends StatelessWidget {
  const GuideAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: BlocConsumer<GuideAuthCubit, GuideAuthState>(
          listener: (context, state) => _handleStateChange(context, state),
          builder: (context, state) {
            final isLoading = state is GuideAuthLoading;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildContent(context, state, isLoading),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    GuideAuthState state,
    bool isLoading,
  ) {
    return switch (state) {
      GuideAuthInitial() => GuideWelcome(
        onLogin: () => context.read<GuideAuthCubit>().selectMode(true),
        onRegister: () => context.read<GuideAuthCubit>().selectMode(false),
      ),

      // Режим с вкладками (вход или регистрация)
      GuideAuthModeSelection(isLogin: final isLogin) => GuideAuthTabs(
        isLogin: isLogin,
        isLoading: isLoading,
        onTabChanged: (isLogin) =>
            context.read<GuideAuthCubit>().selectMode(isLogin),
        onLoginSubmit: (phone) =>
            context.read<GuideAuthCubit>().sendLoginOtp(phone),
        onRegisterSubmit: (phone) =>
            context.read<GuideAuthCubit>().proceedToRegister(phone),
        onBack: () => context.read<GuideAuthCubit>().reset(),
      ),
      GuideLoginOtpSent(phone: final phone) => OtpView(
        key: const ValueKey('guide_otp_login'),
        phone: phone,
        isLoading: isLoading,
        secondsLeft: state.secondsLeft,
        canResend: state.canResend,
        invalidAttempt:
            null, // ошибка не показывается, т.к. мы ушли из GuideOtpInvalid
        onBack: () => context.read<GuideAuthCubit>().reset(),
        onVerify: (code) =>
            context.read<GuideAuthCubit>().verifyLoginOtp(phone, code),
        onResend: () => context.read<GuideAuthCubit>().resendSms(phone),
      ),

      GuideRegisterStep1(phone: final phone) => GuideRegisterForm(
        phone: phone,
        onBack: () => context.read<GuideAuthCubit>().reset(),
        onSubmit: (name, gender) => context
            .read<GuideAuthCubit>()
            .sendRegisterOtp(fullName: name, gender: gender, phone: phone),
      ),

      GuideRegisterOtpSent(
        fullName: final name,
        gender: final gender,
        phone: final phone,
      ) =>
        OtpView(
          key: const ValueKey('guide_otp_register'),
          phone: phone,
          isLoading: isLoading,
          secondsLeft: state.secondsLeft,
          canResend: state.canResend,
          invalidAttempt: null,
          onBack: () => context.read<GuideAuthCubit>().reset(),
          onVerify: (code) => context.read<GuideAuthCubit>().verifyRegisterOtp(
            fullName: name,
            gender: gender,
            phone: phone,
            code: code,
          ),
          onResend: () => context.read<GuideAuthCubit>().resendSms(phone),
        ),

      GuideOtpInvalid(
        phone: final phone,
        message: final message,
        attempt: final attempt,
      ) =>
        OtpView(
          key: ValueKey('guide_otp_invalid_$attempt'),
          phone: phone,
          isLoading: isLoading,
          secondsLeft: state.secondsLeft,
          canResend: state.canResend,
          invalidAttempt: attempt,
          onBack: () => context.read<GuideAuthCubit>().reset(),
          onVerify: (code) => _isLoginMode(state)
              ? context.read<GuideAuthCubit>().verifyLoginOtp(phone, code)
              : context.read<GuideAuthCubit>().verifyRegisterOtp(
                  fullName: _getFullName(state),
                  gender: _getGender(state),
                  phone: phone,
                  code: code,
                ),
          onResend: () => context.read<GuideAuthCubit>().resendSms(phone),
        ),

      GuideSmsResent(phone: final phone) => OtpView(
        key: const ValueKey('guide_otp_resent'),
        phone: phone,
        isLoading: isLoading,
        secondsLeft: state.secondsLeft,
        canResend: state.canResend,
        invalidAttempt: null,
        onBack: () => context.read<GuideAuthCubit>().reset(),
        onVerify: (code) =>
            context.read<GuideAuthCubit>().verifyLoginOtp(phone, code),
        onResend: () => context.read<GuideAuthCubit>().resendSms(phone),
      ),

      GuideAuthLoading() => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppColors.primary),
        ),
      ),

      GuideAuthError(message: final msg) => _buildErrorView(context, msg),

      _ => const SizedBox.shrink(),
    };
  }

  // Helper методы для получения данных из состояния
  bool _isLoginMode(GuideAuthState state) {
    // Определяем по типу состояния
    return state is GuideLoginOtpSent ||
        state is GuideOtpInvalid && state.phone.isNotEmpty; // упрощенно
  }

  String _getFullName(GuideAuthState state) {
    if (state is GuideRegisterOtpSent) return state.fullName;
    if (state is GuideOtpInvalid) {
      // В этом случае мы не знаем fullName, но он нам не нужен для логина
      return '';
    }
    return '';
  }

  GuideGender _getGender(GuideAuthState state) {
    if (state is GuideRegisterOtpSent) return state.gender;
    return GuideGender.male;
  }

  Widget _buildInitial(BuildContext context) {
    return GuideModeSelection(
      onLogin: () => context.read<GuideAuthCubit>().selectMode(true),
      onRegister: () => context.read<GuideAuthCubit>().selectMode(false),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            JoluButton(
              text: 'Назад',
              onPressed: () => context.read<GuideAuthCubit>().reset(),
            ),
          ],
        ),
      ),
    );
  }

  void _handleStateChange(BuildContext context, GuideAuthState state) {
    if (state is GuideNeedsOnboarding) {
      context.go(
        '/guide/onboarding',
        extra: {'token': state.token, 'guideId': state.guide.id},
      );
      return;
    }

    if (state is GuideAuthSuccess) {
      // После успешного входа — на dashboard
      // Профиль загрузится там автоматически
      context.go('/guide/dashboard');
      return;
    }

    if (state is GuideOnboardingPending) {
      // Нужно пройти onboarding
      context.go('/guide/onboarding', extra: {'guideId': state.guide.id});
      return;
    }

    if (state is GuideAuthError) {
      String message = state.message;

      // 404 = аккаунт удалён
      if (message.contains('404') || message.contains('Not Found')) {
        message = 'Аккаунт не найден. Возможно, он был удалён.';
      }

      // Дубликат телефона
      if (message.contains('duplicate key') ||
          message.contains('guides_phone_key')) {
        message = 'Этот номер уже зарегистрирован. Войдите в систему.';
      }

      JoluSnackbar.show(
        context: context,
        message: message,
        type: JoluSnackbarType.error,
      );
      return;
    }
  }
}
