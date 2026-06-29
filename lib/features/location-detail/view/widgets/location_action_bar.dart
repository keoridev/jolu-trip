
import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class LocationActionBar extends StatelessWidget {
  final VoidCallback? onSelfDrive;
  final VoidCallback? onWithGuide;

  const LocationActionBar({super.key, this.onSelfDrive, this.onWithGuide});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimens.space16,
        right: AppDimens.space16,
        bottom: MediaQuery.of(context).padding.bottom + AppDimens.space16,
        top: AppDimens.space16,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        border: Border(top: BorderSide(color: AppColors.borderDark)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Самостоятельно
            Expanded(
              child: _ActionButton(
                icon: Icons.navigation_outlined,
                label: 'Самостоятельно',
                subtitle: 'Координаты + навигатор',
                color: AppColors.cardElevated,
                onTap: onSelfDrive,
              ),
            ),
            const SizedBox(width: AppDimens.space16),
            // С гидом
            Expanded(
              child: _ActionButton(
                icon: Icons.person_outline,
                label: 'С гидом',
                subtitle: 'Проверенный гид',
                color: AppColors.primary,
                textColor: Colors.black,
                onTap: onWithGuide,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color? textColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: textColor == null
              ? Border.all(color: AppColors.borderDark)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: textColor ?? AppColors.textPrimary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.button.copyWith(
                    color: textColor ?? AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTextStyles.subtext.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
