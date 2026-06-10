import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';

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
            'Скопируйте координаты и постройте маршрут в удобном навигаторе',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.spaceXL),

          // Координаты
          Container(
            padding: const EdgeInsets.all(AppDimens.spaceM),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary),
                const SizedBox(width: AppDimens.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Координаты', style: AppTextStyles.badge),
                      const SizedBox(height: 2),
                      Text(
                        location.formattedCoordinates,
                        style: AppTextStyles.mono,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: location.formattedCoordinates),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Координаты скопированы'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppDimens.radiusS),
                    ),
                    child: const Icon(
                      Icons.copy,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spaceXL),

          // Кнопки навигаторов
          Text('Открыть в навигаторе', style: AppTextStyles.title),
          const SizedBox(height: AppDimens.spaceM),
          Row(
            children: [
              Expanded(
                child: _NavigatorButton(
                  label: '2GIS',
                  iconPath: 'assets/icons/2gis.png',
                  onTap: () => _open2Gis(location),
                ),
              ),
              const SizedBox(width: AppDimens.spaceM),
              Expanded(
                child: _NavigatorButton(
                  label: 'Google Maps',
                  iconPath: 'assets/icons/maps.png',
                  onTap: () => _openGoogleMaps(location),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceM),
          Row(
            children: [
              Expanded(
                child: _NavigatorButton(
                  label: 'Yandex Maps',
                  iconPath: 'assets/icons/yandex.png',
                  onTap: () => _openYandexMaps(location),
                ),
              ),
              const SizedBox(width: AppDimens.spaceM),
              Expanded(
                child: _NavigatorButton(
                  label: 'Apple Maps',
                  icon: Icons.apple,
                  onTap: () => _openAppleMaps(location),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _open2Gis(LocationDetailEntity location) {
    // geo:// или https://2gis.kg/
  }

  void _openGoogleMaps(LocationDetailEntity location) {
    // https://www.google.com/maps/search/?api=1&query=lat,lng
  }

  void _openYandexMaps(LocationDetailEntity location) {
    // yandexmaps://maps.yandex.ru/?pt=lng,lat
  }

  void _openAppleMaps(LocationDetailEntity location) {
    // http://maps.apple.com/?q=lat,lng
  }
}

class _NavigatorButton extends StatelessWidget {
  final String label;
  final String? iconPath;
  final IconData? icon;
  final VoidCallback? onTap;

  const _NavigatorButton({
    required this.label,
    this.iconPath,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath != null)
              Image.asset(iconPath!, width: 20, height: 20)
            else if (icon != null)
              Icon(icon, size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
