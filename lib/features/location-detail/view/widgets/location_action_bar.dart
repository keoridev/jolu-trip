import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

/// Закреплённая панель действий.
///
/// Из двух равнозначных кнопок сделана явная иерархия: «Маршрут» — основное
/// действие страницы, «С гидом» — второстепенное, пока гидов нет.
class LocationActionBar extends StatelessWidget {
  final VoidCallback? onSelfDrive;
  final VoidCallback? onWithGuide;

  const LocationActionBar({super.key, this.onSelfDrive, this.onWithGuide});

  static const double _contentHeight = 52 + AppDimens.space12 * 2;

  /// Реальная высота панели — чтобы контент под ней не приходилось
  /// подпирать магической константой (раньше в слайверах стояло 150).
  static double heightOf(BuildContext context) =>
      _contentHeight + MediaQuery.viewPaddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          // Нижний инсет учитывается ровно один раз. Раньше он добавлялся
          // и здесь, и во вложенном SafeArea — панель уезжала вниз на
          // двойную высоту домашнего индикатора.
          padding: EdgeInsets.only(
            left: AppDimens.space16,
            right: AppDimens.space16,
            top: AppDimens.space12,
            bottom:
                MediaQuery.viewPaddingOf(context).bottom + AppDimens.space12,
          ),
          decoration: BoxDecoration(
            color: AppColors.bgDark.withValues(alpha: 0.88),
            border: const Border(
              top: BorderSide(color: AppColors.borderDark),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: _ActionButton(
                  icon: Icons.navigation_rounded,
                  label: 'Маршрут',
                  isPrimary: true,
                  onTap: onSelfDrive,
                ),
              ),
              const SizedBox(width: AppDimens.space12),
              Expanded(
                flex: 2,
                child: _ActionButton(
                  icon: Icons.hiking_rounded,
                  label: 'С гидом',
                  isPrimary: false,
                  onTap: onWithGuide,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = isPrimary ? AppColors.primary : AppColors.cardElevated;
    // На primary — белый: черный на темно-зеленом не проходит по контрасту.
    final foreground = isPrimary ? AppColors.onPrimary : AppColors.textPrimary;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppDimens.radiusM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            border: isPrimary
                ? null
                : Border.all(color: AppColors.borderDark),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppDimens.icon20, color: foreground),
              const SizedBox(width: AppDimens.space8),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.button.copyWith(
                    color: foreground,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
