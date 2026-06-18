

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';

class ExperienceLanguagesBlockWidget extends StatelessWidget {
  final OnboardingEntity onboarding;

  const ExperienceLanguagesBlockWidget({super.key, required this.onboarding});

  @override
  Widget build(BuildContext context) {
    return _buildBlock(
      title: 'Опыт и языки',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Стаж
          _buildExperienceRow(),
          const SizedBox(height: AppDimens.spaceL),

          // Языки
          Text('Языки', style: AppTextStyles.subtitle),
          const SizedBox(height: AppDimens.spaceM),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: onboarding.languages.map((lang) {
              return _LanguageChip(code: lang);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
          ),
          child: Icon(Icons.timer_outlined, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: AppDimens.spaceM),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${onboarding.experienceYears} ${_pluralYears(onboarding.experienceYears)}',
              style: AppTextStyles.title.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text('Стаж вождения', style: AppTextStyles.bodySmall),
          ],
        ),
      ],
    );
  }

  String _pluralYears(int years) {
    final last = years % 10;
    final lastTwo = years % 100;
    if (lastTwo >= 11 && lastTwo <= 14) return 'лет';
    if (last == 1) return 'год';
    if (last >= 2 && last <= 4) return 'года';
    return 'лет';
  }

  Widget _buildBlock({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.spaceL),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.subtitle),
          const SizedBox(height: AppDimens.spaceL),
          child,
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String code;

  const _LanguageChip({required this.code});

  String get _label => switch (code) {
    'ru' => '🇷🇺 Русский',
    'en' => '🇬🇧 English',
    'ky' => '🇰🇬 Кыргызча',
    _ => code.toUpperCase(),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        _label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
