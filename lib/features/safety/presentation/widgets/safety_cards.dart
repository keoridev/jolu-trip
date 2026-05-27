import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

class AppCard extends StatelessWidget {
  final String name;
  final String description;
  final IconData icon;

  const AppCard({
    super.key,
    required this.name,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppDimens.spaceM),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTextStyles.subtext.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OperatorRow extends StatelessWidget {
  final String name;
  final String coverage;
  final Color color;

  const OperatorRow({
    super.key,
    required this.name,
    required this.coverage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                coverage,
                style: AppTextStyles.subtext.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RuleCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isWarning;

  const RuleCard({
    super.key,
    required this.icon,
    required this.text,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppDimens.spaceM),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: isWarning
            ? Border.all(color: AppColors.error.withOpacity(0.3))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isWarning ? AppColors.error : AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(height: 1.4, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const InfoCard({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(height: 1.5, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
