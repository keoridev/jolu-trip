import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';

/// Редизайн блока опыта и языков.
///
/// Структура:
/// - Заголовок + action "Изменить"
/// - Бейдж опыта (иконка + число + подпись)
/// - Чипы языков с цветовой кодировкой
///
/// Убрано:
/// - Иконка-карандаш (заменена на текстовую ссылку)
/// - Разделение на подзаголовки "Опыт" / "Языки" (лишний уровень)
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
    return Padding(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Опыт и языки',
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isEditable)
                GestureDetector(
                  onTap: onEdit,
                  child: Text(
                    'Изменить',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.space12),

          // Карточка
          _AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Бейдж опыта
                _ExperienceBadge(years: onboarding.experienceYears),
                const SizedBox(height: AppDimens.space16),
                // Языки
                _LanguagesChips(languages: onboarding.languages),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceBadge extends StatelessWidget {
  final int years;

  const _ExperienceBadge({required this.years});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space12,
        vertical: AppDimens.space8,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_up,
            color: AppColors.textPrimary,
            size: 16,
          ),
          const SizedBox(width: AppDimens.space8),
          Text(
            '$years ${_pluralYears(years)}',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: AppDimens.space8),
          Container(
            height: 14,
            width: 1,
            color: AppColors.borderDark,
          ),
          const SizedBox(width: AppDimens.space8),
          Text(
            'за рулём',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
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

class _LanguagesChips extends StatelessWidget {
  final List<String> languages;

  const _LanguagesChips({required this.languages});

  @override
  Widget build(BuildContext context) {
    if (languages.isEmpty) {
      return Text(
        'Языки не указаны',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textTertiary,
        ),
      );
    }

    return Wrap(
      spacing: AppDimens.space8,
      runSpacing: AppDimens.space8,
      children: languages.map((code) => _LanguageChip(code: code)).toList(),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String code;

  const _LanguageChip({required this.code});

  String get _displayName {
    final lower = code.toLowerCase().trim();
    if (lower == 'ru' || lower == 'rus' || lower == 'russian') return 'Русский';
    if (lower == 'en' || lower == 'eng' || lower == 'english') return 'English';
    if (lower == 'ky' || lower == 'kir' || lower == 'kyrgyz') return 'Кыргызча';
    return code[0].toUpperCase() + code.substring(1).toLowerCase();
  }

  String get _flag {
    final lower = code.toLowerCase().trim();
    if (lower == 'ru' || lower == 'rus' || lower == 'russian') return '🇷🇺';
    if (lower == 'en' || lower == 'eng' || lower == 'english') return '🇬🇧';
    if (lower == 'ky' || lower == 'kir' || lower == 'kyrgyz') return '🇰🇬';
    return '🌐';
  }

  Color get _borderColor {
    final lower = code.toLowerCase().trim();
    if (lower == 'ru' || lower == 'rus' || lower == 'russian') {
      return Colors.blue.shade400;
    }
    if (lower == 'en' || lower == 'eng' || lower == 'english') {
      return Colors.red.shade400;
    }
    if (lower == 'ky' || lower == 'kir' || lower == 'kyrgyz') {
      return Colors.green.shade400;
    }
    return AppColors.borderDark;
  }

  Color get _textColor {
    final lower = code.toLowerCase().trim();
    if (lower == 'ru' || lower == 'rus' || lower == 'russian') {
      return Colors.blue.shade300;
    }
    if (lower == 'en' || lower == 'eng' || lower == 'english') {
      return Colors.red.shade300;
    }
    if (lower == 'ky' || lower == 'kir' || lower == 'kyrgyz') {
      return Colors.green.shade300;
    }
    return AppColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space12,
        vertical: AppDimens.space8,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppDimens.radiusRound),
        border: Border.all(
          color: _borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _flag,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: AppDimens.space8),
          Text(
            _displayName,
            style: AppTextStyles.body.copyWith(
              color: _textColor,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final Widget child;

  const _AppCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: child,
    );
  }
}