import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';

class GuideProfileStats extends StatelessWidget {
  final GuideProfileEntity profile;

  const GuideProfileStats({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.screenPadding.copyWith(top: 0),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.tour_outlined,
            value: '0', // TODO: add toursCount to entity when backend ready
            label: 'Туров',
          ),
          const SizedBox(width: 12),
          _StatItem(
            icon: Icons.star_rounded,
            value: '—', // TODO: add rating when backend ready
            label: 'Рейтинг',
          ),
          const SizedBox(width: 12),
          _StatItem(
            icon: Icons.reviews_outlined,
            value: '—', // TODO: add reviewsCount when backend ready
            label: 'Отзывов',
          ),
        ],
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.title.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}