import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

/// Заголовок смысловой группы внутри шага: иконка в мягком квадрате,
/// название и необязательное пояснение + слот для счётчика справа.
class SectionHeaderWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeaderWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppDimens.radius12),
          ),
          child: Icon(icon, size: 19, color: AppColors.accent),
        ),
        const SizedBox(width: AppDimens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTextStyles.title),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppTextStyles.subtext.copyWith(fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppDimens.space12),
          trailing!,
        ],
      ],
    );
  }
}

/// Пилюля-счётчик вида «3/4». Подсвечивается зелёным, когда группа собрана.
class SectionCounterBadge extends StatelessWidget {
  final int done;
  final int total;

  const SectionCounterBadge({
    super.key,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = done >= total;
    final tint = isComplete ? AppColors.success : AppColors.textTertiary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space10,
        vertical: AppDimens.space4,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimens.radiusRound),
        border: Border.all(color: tint.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isComplete) ...[
            const Icon(
              Icons.check_rounded,
              size: 13,
              color: AppColors.success,
            ),
            const SizedBox(width: 3),
          ],
          Text(
            '$done/$total',
            style: AppTextStyles.bodySmall.copyWith(
              color: tint,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
