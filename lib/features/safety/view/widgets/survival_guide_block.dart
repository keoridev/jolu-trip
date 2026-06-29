import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/safety/data/datasources/datasources.dart';
import 'package:jolutrip_app/features/safety/data/models/safety_models.dart';
import 'package:jolutrip_app/features/safety/view/widgets/shared/block_title.dart';
import 'package:jolutrip_app/features/safety/view/widgets/shared/expandable_card.dart';

class SurvivalGuideBlock extends StatelessWidget {
  const SurvivalGuideBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BlockTitle(
          icon: Icons.help_outline_rounded,
          title: 'Гид по выживанию',
          color: Colors.teal,
        ),
        const SizedBox(height: AppDimens.space24),

        ...SafetyLocalDataSource.faqCategories.map(
          (faq) => ExpandableCard(
            icon: faq.icon,
            title: faq.title,
            accentColor: faq.color,
            content: Column(
              children: faq.questions.asMap().entries.map((entry) {
                final isLast = entry.key == faq.questions.length - 1;
                return _QuestionTile(question: entry.value, isLast: isLast);
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: AppDimens.space24),

        // Дополнительные советы
        ...SafetyLocalDataSource.safetyTips.map((tip) => _TipCard(tip: tip)),
      ],
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final FaqQuestion question;
  final bool isLast;

  const _QuestionTile({required this.question, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppDimens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppDimens.space12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.space16),
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
            child: Text(
              question.answer,
              style: AppTextStyles.subtext.copyWith(height: 1.5, fontSize: 13),
            ),
          ),
          if (!isLast) const SizedBox(height: AppDimens.space16),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final SafetyTip tip;

  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    final colors = {
      SafetyCategory.health: AppColors.error,
      SafetyCategory.practical: AppColors.primary,
      SafetyCategory.culture: Colors.orange,
      SafetyCategory.language: Colors.purple,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.space16),
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(
          color: (colors[tip.category] ?? AppColors.primary).withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (colors[tip.category] ?? AppColors.primary).withValues(
                alpha: 0.15,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(tip.category),
              color: colors[tip.category] ?? AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: AppDimens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.content,
                  style: AppTextStyles.subtext.copyWith(
                    height: 1.5,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(SafetyCategory category) {
    return switch (category) {
      SafetyCategory.health => Icons.health_and_safety_outlined,
      SafetyCategory.practical => Icons.lightbulb_outline,
      SafetyCategory.culture => Icons.diversity_3_outlined,
      SafetyCategory.language => Icons.translate_outlined,
      _ => Icons.info_outline,
    };
  }
}
