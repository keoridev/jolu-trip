// lib/features/location_detail/presentation/widgets/location_self_drive_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import '../../domain/entities/location_detail_entity.dart';

class LocationSelfDriveSheet extends StatelessWidget {
  final LocationDetailEntity location;

  const LocationSelfDriveSheet({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppDimens.spaceL,
        left: AppDimens.spaceL,
        right: AppDimens.spaceL,
        bottom: MediaQuery.of(context).padding.bottom + AppDimens.spaceL,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.spaceL),

          Text('Самостоятельная поездка', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppDimens.spaceS),
          Text(
            'Скопируйте координаты или откройте навигатор',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.spaceXL),

          // Координаты с кнопкой копирования
          Container(
            padding: const EdgeInsets.all(AppDimens.spaceM),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimens.radiusS),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppDimens.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Координаты', style: AppTextStyles.badge),
                      const SizedBox(height: 4),
                      Text(
                        location.formattedCoordinates,
                        style: AppTextStyles.mono.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _copyCoordinates(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.copy, color: Colors.black, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Копировать',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spaceXL),

          // Разделитель
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.borderDark)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'или откройте в',
                  style: AppTextStyles.subtext.copyWith(fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: AppColors.borderDark)),
            ],
          ),
          const SizedBox(height: AppDimens.spaceXL),

          // Кнопки навигаторов — сетка 2x2
          Row(
            children: [
              Expanded(
                child: _NavButton(
                  label: '2GIS',
                  icon: Icons.map,
                  color: const Color(0xFF00AAFF),
                  onTap: () => _open2Gis(context),
                ),
              ),
              const SizedBox(width: AppDimens.spaceM),
              Expanded(
                child: _NavButton(
                  label: 'Google Maps',
                  icon: Icons.public,
                  color: const Color(0xFF34A853),
                  onTap: () => _openGoogle(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceM),
          Row(
            children: [
              Expanded(
                child: _NavButton(
                  label: 'Yandex Maps',
                  icon: Icons.location_city,
                  color: const Color(0xFFFF3333),
                  onTap: () => _openYandex(context),
                ),
              ),
              const SizedBox(width: AppDimens.spaceM),
              Expanded(
                child: _NavButton(
                  label: 'Apple Maps',
                  icon: Icons.apple,
                  color: Colors.white,
                  onTap: () => _openApple(context),
                ),
              ),
            ],
          ),

          // Дополнительно: поделиться
          const SizedBox(height: AppDimens.spaceXL),
          GestureDetector(
            onTap: () => _shareLocation(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  Text('Поделиться локацией', style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyCoordinates(BuildContext context) {
    Clipboard.setData(ClipboardData(text: location.formattedCoordinates));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Координаты скопированы'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
      ),
    );
  }

  void _shareLocation(BuildContext context) {
    /* TODO: Share Plus */
  }

  void _open2Gis(BuildContext context) {
    /* TODO: url_launcher */
  }

  void _openGoogle(BuildContext context) {
    /* TODO: url_launcher */
  }

  void _openYandex(BuildContext context) {
    /* TODO: url_launcher */
  }

  void _openApple(BuildContext context) {
    /* TODO: url_launcher */
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
