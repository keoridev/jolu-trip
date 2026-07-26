import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

/// Сегментированный индикатор шагов с подписями.
///
/// Пройденные шаги помечаются галочкой, текущий — утолщённой полосой, так что
/// прогресс читается и без подписей.
class ProgressBarWidget extends StatelessWidget {
  final int currentPage;
  final List<String> labels;

  const ProgressBarWidget({
    super.key,
    required this.currentPage,
    this.labels = const ['Анкета', 'Документы', 'Проверка'],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(labels.length, (index) {
        final isDone = index < currentPage;
        final isActive = index == currentPage;
        final isReached = isDone || isActive;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOut,
                  height: isActive ? 6 : 4,
                  decoration: BoxDecoration(
                    color: isReached
                        ? AppColors.accent
                        : AppColors.borderDark,
                    borderRadius: BorderRadius.circular(
                      AppDimens.radiusRound,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.space8),
                Row(
                  children: [
                    if (isDone) ...[
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 12,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 260),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isReached
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                        child: Text(
                          labels[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
