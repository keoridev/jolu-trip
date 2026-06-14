import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';

import 'package:jolutrip_app/features/auth/bloc/auth_cubit.dart';
import 'package:jolutrip_app/features/auth/bloc/auth_state.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: _handleStateChange,
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: switch (state) {
                AuthInitial() => PhoneView(
                  title: 'Вход для туристов',
                  subtitle:
                      'Войдите, чтобы бронировать туры\nи сохранять локации',
                  isLoading: isLoading,
                  onBack: () => context.pop(), // ← КНОПКА НАЗАД
                  onSubmit: (phone) => context.read<AuthCubit>().sendOtp(phone),
                ),

                AuthOtpSent(phone: final phone) => OtpView(
                  phone: phone,
                  isLoading: isLoading,
                  onBack: () =>
                      context.read<AuthCubit>().reset(), // ← НАЗАД К ТЕЛЕФОНУ
                  onVerify: (code) =>
                      context.read<AuthCubit>().verifyOtp(phone, code),
                  onResend: () => context.read<AuthCubit>().sendOtp(phone),
                ),

                AuthLoading() => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),

                _ => const SizedBox.shrink(),
              },
            );
          },
        ),
      ),
    );
  }

  void _handleStateChange(BuildContext context, AuthState state) {
    if (state is AuthSuccess) {
      context.go('/reels');
    }
    if (state is AuthError) {
      JoluSnackbar.show(
        context: context,
        message: state.message,
        type: JoluSnackbarType.error,
      );
    }
  }
}
