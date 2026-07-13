import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/buttons/jolu_button.dart';

/// Улучшенный BottomSheet с поддержкой disabled-состояния кнопки сохранения.
/// 
/// UX: кнопка "Сохранить" неактивна, пока форма невалидна — предотвращает
/// случайные отправки и даёт понять пользователю, что нужно заполнить.
class BottomSheetWrapper extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onSave;
  final bool canSave;
  final List<Widget> children;

  const BottomSheetWrapper({
    super.key,
    required this.title,
    required this.icon,
    required this.onSave,
    this.canSave = true,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radius24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + AppDimens.space16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Индикатор свайпа
          Container(
            margin: const EdgeInsets.only(top: AppDimens.space12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppDimens.space24),
          // Иконка заголовка
          _HeaderIcon(icon: icon),
          const SizedBox(height: AppDimens.space16),
          Text(title, style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppDimens.space24),
          // Контент
          Padding(
            padding: AppDimens.screenPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
          const SizedBox(height: AppDimens.space24),
          // Кнопки действий
          Padding(
            padding: AppDimens.screenPadding,
            child: Row(
              children: [
                Expanded(
                  child: JoluButton(
                    text: 'Отмена',
                    variant: JoluButtonVariant.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppDimens.space12),
                Expanded(
                  child: JoluButton(
                    text: 'Сохранить',
                    onPressed: canSave ? onSave : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;

  const _HeaderIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }
}