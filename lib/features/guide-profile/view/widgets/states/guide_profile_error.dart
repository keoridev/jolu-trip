import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_cubit.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_state.dart';

class GuideProfileErrorWidget extends StatelessWidget {
  final GuideProfileError state;

  const GuideProfileErrorWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Если сообщение содержит "not found" — предлагаем войти заново
    final isNotFound = state.message.toLowerCase().contains('not found') ||
        state.message.toLowerCase().contains('404');

    return Center(
      child: Padding(
        padding: AppDimens.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isNotFound ? Icons.person_off_outlined : Icons.error_outline,
              color: isNotFound ? AppColors.warning : AppColors.error,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              isNotFound ? 'Аккаунт не найден' : 'Не удалось загрузить профиль',
              style: AppTextStyles.headline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (isNotFound)
              JoluButton(
                text: 'Войти заново',
                leadingIcon: Icons.login_rounded,
                onPressed: () {
                  context.read<GuideProfileCubit>().logout();
                  context.go('/auth');
                },
              )
            else
              JoluButton(
                text: 'Повторить',
                leadingIcon: Icons.refresh_rounded,
                onPressed: () => context.read<GuideProfileCubit>().loadProfile(),
              ),
          ],
        ),
      ),
    );
  }
}