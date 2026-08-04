import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/feedback/jolu_snackbar.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';
import 'package:url_launcher/url_launcher.dart';

class MapFullscreenSheet extends StatelessWidget {
  final LocationDetailEntity location;

  const MapFullscreenSheet({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusL),
        ),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.space16),

          Padding(
            padding: AppDimens.screenPadding,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(location.name, style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        location.formattedCoordinates,
                        style: AppTextStyles.monoSmall,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cardElevated,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimens.space16),

          Expanded(
            child: Container(
              margin: AppDimens.screenPadding,
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 80,
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Интерактивная карта',
                      style: AppTextStyles.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Выберите приложение для построения маршрута',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _MapButton(
                          label: '2GIS',
                          icon: Icons.map,
                          onTap: () => _openNavigator(context, '2gis'),
                        ),
                        _MapButton(
                          label: 'Yandex',
                          icon: Icons.location_city,
                          onTap: () => _openNavigator(context, 'yandex'),
                        ),
                        _MapButton(
                          label: 'Google',
                          icon: Icons.public,
                          onTap: () => _openNavigator(context, 'google'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.only(
              left: AppDimens.space16,
              right: AppDimens.space16,
              bottom: MediaQuery.of(context).padding.bottom + AppDimens.space16,
              top: AppDimens.space16,
            ),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderDark)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _copyCoordinates(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardElevated,
                        borderRadius: BorderRadius.circular(AppDimens.radiusM),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.copy, size: 18),
                          const SizedBox(width: 8),
                          Text('Копировать', style: AppTextStyles.button),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.space16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openNavigator(context, '2gis'), // По умолчанию 2GIS
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppDimens.radiusM),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.navigation,
                            size: 18,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Маршрут',
                            style: AppTextStyles.button.copyWith(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyCoordinates(BuildContext context) {
    Clipboard.setData(
      ClipboardData(text: '${location.latitude}, ${location.longitude}'),
    );
    HapticFeedback.selectionClick();
    if (context.mounted) {
      JoluSnackbar.show(
        context: context,
        message: 'Координаты скопированы',
        type: JoluSnackbarType.success,
      );
    }
  }

  // ✅ ЕДИНАЯ ЛОГИКА ОТКРЫТИЯ НАВИГАТОРА (дублируем для автономности виджета)
  Future<void> _openNavigator(BuildContext context, String type) async {
    final lat = location.latitude;
    final lon = location.longitude;
    Uri uri;

    switch (type) {
      case '2gis':
        uri = Uri.parse('geo:$lat,$lon');
        break;
      case 'yandex':
        uri = Uri.parse('yandexmaps://maps.yandex.ru/?pt=$lon,$lat&z=15&l=map');
        break;
      case 'google':
        uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lon');
        break;
      default:
        uri = Uri.parse('geo:$lat,$lon');
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback на веб
      Uri webUri;
      switch (type) {
        case '2gis':
          webUri = Uri.parse('https://2gis.kg/geo/$lon,$lat');
          break;
        case 'yandex':
          webUri = Uri.parse('https://yandex.ru/maps/?pt=$lon,$lat&z=15');
          break;
        case 'google':
          webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
          break;
        default:
          webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
      }

      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          JoluSnackbar.show(
            context: context,
            message: 'Не удалось открыть карту',
            type: JoluSnackbarType.error,
          );
        }
      }
    }
  }
}

class _MapButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _MapButton({required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardElevated,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}