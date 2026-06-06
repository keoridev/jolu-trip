import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/auth/bloc/auth_cubit.dart';
import 'package:jolutrip_app/features/auth/bloc/auth_state.dart';
import 'package:jolutrip_app/features/auth/presentation/widgets/otp_view.dart';
import 'package:jolutrip_app/features/auth/presentation/widgets/phone_view.dart';

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
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: state is AuthOtpSent
                  ? OtpView(phone: state.phone)
                  : const PhoneView(),
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
