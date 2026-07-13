import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';

/// Статистика профиля — 3 метрики в единой карточке с разделителями.
/// 
/// UX: единая поверхность вместо 3 отдельных карточек — меньше визуального шума,
/// легче сканировать. Разделители помогают различать метрики.
class GuideProfileStats extends StatelessWidget {
  final GuideProfileEntity profile;

  const GuideProfileStats({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.screenPadding.copyWith(top: 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space20),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            _StatItem(
              icon: Icons.route_outlined,
              value:  '0',
              label: 'Туров',
            ),
            _VerticalDivider(),
            _StatItem(
              icon: Icons.star_outline,
              value:  '0.0',
              label: 'Рейтинг',
            ),
            _VerticalDivider(),
            _StatItem(
              icon: Icons.chat_bubble_outline,
              value: '0',
              label: 'Отзывов',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(height: AppDimens.space8),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimens.space4),
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.borderDark,
    );
  }
}