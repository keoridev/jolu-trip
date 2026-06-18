import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/guide_auth/bloc/guide_auth_cubit.dart';
import 'package:jolutrip_app/features/guide_auth/bloc/guide_auth_state.dart';

import 'package:jolutrip_app/features/guide_auth/presentation/widgets/guide_mode_selection.dart';
import 'package:jolutrip_app/features/guide_auth/presentation/widgets/guide_register_form.dart';

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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _buildStateWidget(context, state, isLoading),
    );
  }

  Widget _buildStateWidget(
    BuildContext context,
    GuideAuthState state,
    bool isLoading,
  ) {
    return switch (state) {
      GuideAuthInitial() => _buildInitial(context),

      GuideAuthModeSelection(isLogin: final isLogin) =>
        isLogin
            ? PhoneView(
                key: const ValueKey('guide_phone_login'),
                title: 'Вход гида',
                subtitle: 'Войдите в свой аккаунт гида',
                isLoading: isLoading,
                onBack: () => context.read<GuideAuthCubit>().reset(),
                onSubmit: (phone) =>
                    context.read<GuideAuthCubit>().sendLoginOtp(phone),
              )
            : PhoneView(
                key: const ValueKey('guide_phone_register'),
                title: 'Регистрация гида',
                subtitle: 'Создайте аккаунт гида',
                isLoading: isLoading,
                onBack: () => context.read<GuideAuthCubit>().reset(),
                onSubmit: (phone) =>
                    context.read<GuideAuthCubit>().proceedToRegister(phone),
              ),

      GuideLoginOtpSent(phone: final phone) => OtpView(
        key: const ValueKey('guide_otp_login'),
        phone: phone,
        isLoading: isLoading,
        onBack: () => context.read<GuideAuthCubit>().reset(),
        onVerify: (code) =>
            context.read<GuideAuthCubit>().verifyLoginOtp(phone, code),
        onResend: () => context.read<GuideAuthCubit>().sendLoginOtp(phone),
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
          onBack: () => context.read<GuideAuthCubit>().reset(),
          onVerify: (code) => context.read<GuideAuthCubit>().verifyRegisterOtp(
            fullName: name,
            gender: gender,
            phone: phone,
            code: code,
          ),
          onResend: () => context.read<GuideAuthCubit>().sendRegisterOtp(
            fullName: name,
            gender: gender,
            phone: phone,
          ),
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
    }

    // ❌ УБИРАЕМ этот переход, так как теперь идем на профиль
    // if (state is GuideOnboardingPending) {
    //   context.go('/guide/pending');
    // }

    if (state is GuideAuthSuccess) {
      context.go('/guide/dashboard');
    }

    if (state is GuideAuthError) {
      JoluSnackbar.show(
        context: context,
        message: state.message,
        type: JoluSnackbarType.error,
      );
    }
  }
}
