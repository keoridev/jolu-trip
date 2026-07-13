import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/buttons/jolu_button.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';

class GuideActionButtons extends StatelessWidget {
  final GuideProfileEntity profile;
  final bool isLoading;

  const GuideActionButtons({
    super.key,
    required this.profile,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.screenPadding,
      child: Column(
        children: [
          _CreateTourButton(
            profile: profile,
            isLoading: isLoading,
          ),
          const SizedBox(height: AppDimens.space10),
          
          JoluButton(
            text: 'Мои туры',
            variant: JoluButtonVariant.outline,
            trailingIcon: Icons.list_alt,
            onPressed: () => context.push('/guide/tours'),
          ),
          
          if (profile.isRejected) ...[
            const SizedBox(height: AppDimens.space10),
            JoluButton(
              text: 'Перезагрузить документы',
              variant: JoluButtonVariant.outline,
              trailingIcon: Icons.upload_file,
              onPressed: () => context.push(
                '/guide/onboarding',
                extra: {'guideId': profile.id, 'isReupload': true},
              ),
            ),
          ],
          
          const SizedBox(height: AppDimens.space16),
          
          GestureDetector(
            onTap: () => _showLogoutSheet(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.space8),
              child: Text(
                'Выйти из аккаунта',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutSheet(BuildContext context) {
    // ... как раньше
  }
}

class _CreateTourButton extends StatelessWidget {
  final GuideProfileEntity profile;
  final bool isLoading;

  const _CreateTourButton({
    required this.profile,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final isVerified = profile.isVerified;
    final isPending = profile.isPending;
    final isRejected = profile.isRejected;

    return Column(
      children: [
        JoluButton(
          text: 'Создать новый тур',
          trailingIcon: Icons.add_circle_outline,
          isLoading: isLoading,
          onPressed: isVerified ? () => context.push('/guide/tours/create') : null,
        ),
        if (!isVerified) ...[
          const SizedBox(height: AppDimens.space8),
          Text(
            _getDisabledReason(isPending, isRejected),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  String _getDisabledReason(bool isPending, bool isRejected) {
    if (isPending) return 'Профиль на проверке. Обычно 1–3 часа.';
    if (isRejected) return 'Профиль отклонён. Перезагрузите документы.';
    return 'Доступно после верификации профиля';
  }
}