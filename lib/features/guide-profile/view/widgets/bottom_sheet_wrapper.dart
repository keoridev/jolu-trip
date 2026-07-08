import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';

class BottomSheetWrapper extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onSave;
  final List<Widget> children;

  const BottomSheetWrapper({
    super.key,
    required this.title,
    required this.icon,
    required this.onSave,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.headline),
          const SizedBox(height: 24),
          Padding(
            padding: AppDimens.screenPadding,
            child: Column(mainAxisSize: MainAxisSize.min, children: children),
          ),
          const SizedBox(height: 24),
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
                const SizedBox(width: 12),
                Expanded(
                  child: JoluButton(text: 'Сохранить', onPressed: onSave),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}