import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';

class GuideProfileActions extends StatelessWidget {
  final GuideProfileEntity profile;

  const GuideProfileActions({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Действия', style: AppTextStyles.subtitle),
          const SizedBox(height: AppDimens.space12),
          _ActionCard(
            icon: Icons.add_circle_rounded,
            title: 'Создать тур',
            subtitle: 'Новое путешествие',
            color: AppColors.primary,
            onTap: () => context.push('/guide/tours/create'),
          ),
          const SizedBox(height: AppDimens.space12),
          _ActionCard(
            icon: Icons.list_alt_rounded,
            title: 'Мои туры',
            subtitle: 'Управление турами',
            color: AppColors.textPrimary,
            onTap: () => context.push('/guide/tours'),
          ),
          if (profile.isRejected) ...[
            const SizedBox(height: AppDimens.space12),
            _ActionCard(
              icon: Icons.upload_file_rounded,
              title: 'Перезагрузить документы',
              subtitle: 'Исправить и отправить заново',
              color: AppColors.warning,
              onTap: () => context.push(
                '/guide/onboarding',
                extra: {'guideId': profile.id, 'isReupload': true},
              ),
            ),
          ],
          const SizedBox(height: AppDimens.space32),
          SizedBox(
            width: double.infinity,
            child: JoluButton(
              text: 'Выйти из аккаунта',
              variant: JoluButtonVariant.outline,
              leadingIcon: Icons.logout_rounded,
              onPressed: () => _showLogoutBottomSheet(context),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.logout_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Выйти из аккаунта?', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            Text(
              'Вы уверены что хотите выйти?',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: JoluButton(
                    text: 'Отмена',
                    variant: JoluButtonVariant.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: JoluButton(
                    text: 'Выйти',
                    variant: JoluButtonVariant.primary,
                    onPressed: () {
                      Navigator.pop(context);
                      // delegate logout to auth
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.subtitle.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
