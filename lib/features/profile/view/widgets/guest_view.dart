import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/profile/view/bloc/profile_cubit.dart';

class GuestView extends StatelessWidget {
  const GuestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardDark,
              border: Border.all(color: AppColors.borderDark, width: 2),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimens.space24),
          Text('Добро пожаловать', style: AppTextStyles.headline),
          const SizedBox(height: AppDimens.space12),
          Text(
            'Войдите, чтобы сохранять маршруты,\nполучать печати и делиться опытом',
            style: AppTextStyles.subtext,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.space32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: JoluButton(
              text: 'Войти в аккаунт',
              variant: JoluButtonVariant.primary,
              size: JoluButtonSize.large,
              isFullWidth: true,
              leadingIcon: Icons.login_rounded,
              onPressed: () async {
                await context.push('/auth');
                if (context.mounted) {
                  context.read<ProfileCubit>().loadProfile();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
