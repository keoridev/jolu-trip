import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

/// Единый блок секции на странице локации.
///
/// Раньше каждая секция сама оборачивалась в [AppDimens.screenPadding]
/// с `vertical: 24`, из-за чего между двумя соседними секциями получалось
/// 48px, а внутри секции — 16px. Ритм ломался. Здесь вертикальные отступы
/// задаёт только сама секция, одним значением.
class LocationSection extends StatelessWidget {
  final String title;

  /// Короткое пояснение под заголовком.
  final String? subtitle;

  /// Действие справа от заголовка (например «На весь экран»).
  final Widget? trailing;

  /// Если содержимое скроллится по горизонтали, отступ по бокам должен
  /// задавать сам список, иначе карточки обрежутся по краю экрана.
  final bool contentFullBleed;

  final Widget child;

  const LocationSection({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.contentFullBleed = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.space32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space16,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Тонкая акцентная полоска — связывает секции визуально.
                Container(
                  width: 3,
                  height: subtitle == null ? 18 : 36,
                  margin: const EdgeInsets.only(
                    top: 2,
                    right: AppDimens.space10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBright,
                    borderRadius: BorderRadius.circular(AppDimens.radius4),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.headlineSmall),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppDimens.space4),
                        Text(subtitle!, style: AppTextStyles.subtext),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppDimens.space8),
                  trailing!,
                ],
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space16),
          if (contentFullBleed)
            child
          else
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
              ),
              child: child,
            ),
        ],
      ),
    );
  }
}

/// Небольшая «пилюля»-действие рядом с заголовком секции.
class LocationSectionAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const LocationSectionAction({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryBright.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppDimens.radiusRound),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusRound),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space12,
            vertical: AppDimens.space8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primaryBright, size: AppDimens.icon16),
              const SizedBox(width: AppDimens.space6),
              Text(label, style: AppTextStyles.accentBadge),
            ],
          ),
        ),
      ),
    );
  }
}
