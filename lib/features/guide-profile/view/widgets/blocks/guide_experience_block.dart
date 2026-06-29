
import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';

class GuideExperienceBlock extends StatelessWidget {
  final OnboardingEntity onboarding;
  final bool isEditable;
  final VoidCallback? onEdit;

  const GuideExperienceBlock({
    super.key,
    required this.onboarding,
    required this.isEditable,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Опыт и языки', style: AppTextStyles.subtitle),
              if (isEditable)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  color: AppColors.primary,
                ),
            ],
          ),
          const SizedBox(height: AppDimens.space24),

          // Стаж
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
                child: Icon(
                  Icons.timer_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimens.space16),
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
          ),

          const SizedBox(height: AppDimens.space24),

          // Языки
          Text('Языки', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppDimens.space16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: onboarding.languages
                .map((lang) => _LanguageChip(code: lang))
                .toList(),
          ),
        ],
      ),
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
