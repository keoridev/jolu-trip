import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/feedback/jolu_snackbar.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';
import 'package:jolutrip_app/features/location-detail/view/widgets/trip_readiness_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationSelfDriveSheet extends StatelessWidget {
  final LocationDetailEntity location;

  const LocationSelfDriveSheet({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppDimens.space24,
        left: AppDimens.space24,
        right: AppDimens.space24,
        bottom: MediaQuery.of(context).padding.bottom + AppDimens.space24,
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
          const SizedBox(height: AppDimens.space24),

          Text('Самостоятельная поездка', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppDimens.space12),
          Text(
            'Скопируйте координаты или откройте навигатор',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.space32),

          Container(
            padding: const EdgeInsets.all(AppDimens.space16),
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
                const SizedBox(width: AppDimens.space16),
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
          const SizedBox(height: AppDimens.space32),

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
          const SizedBox(height: AppDimens.space32),

          Row(
            children: [
              Expanded(
                child: _NavButton(
                  label: '2GIS',
                  icon: Icons.map,
                  color: const Color(0xFF00AAFF),
                  onTap: () => _prepareAndNavigate(context, '2gis'),
                ),
              ),
              const SizedBox(width: AppDimens.space16),
              Expanded(
                child: _NavButton(
                  label: 'Google Maps',
                  icon: Icons.public,
                  color: const Color(0xFF34A853),
                  onTap: () => _prepareAndNavigate(context, 'google'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space16),
          Row(
            children: [
              Expanded(
                child: _NavButton(
                  label: 'Yandex Maps',
                  icon: Icons.location_city,
                  color: const Color(0xFFFF3333),
                  onTap: () => _prepareAndNavigate(context, 'yandex'),
                ),
              ),
              const SizedBox(width: AppDimens.space16),
              Expanded(
                child: _NavButton(
                  label: 'Apple Maps',
                  icon: Icons.apple,
                  color: Colors.white,
                  onTap: () => _prepareAndNavigate(context, 'apple'),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimens.space32),
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
                  const Icon(
                    Icons.share,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
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
    HapticFeedback.selectionClick();
    if (context.mounted) {
      JoluSnackbar.show(
        context: context,
        message: 'Координаты скопированы',
        type: JoluSnackbarType.success,
      );
    }
  }

  void _shareLocation(BuildContext context) {
    // Можно интегрировать share_plus, если нужно, но пока оставим как есть
  }

  void _prepareAndNavigate(BuildContext context, String navigatorType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TripReadinessSheet(
        location: location,
        onReady: () {
          // Этот колбэк сработает после того, как пользователь нажмет "Поехали"
          _openNavigator(context, navigatorType);
        },
      ),
    );
  }

  Future<void> _openNavigator(BuildContext context, String type) async {
    final lat = location.latitude;
    final lon = location.longitude;

    debugPrint('🗺️ Попытка открыть навигатор: $type (Lat: $lat, Lon: $lon)');

    Uri appUri;
    switch (type) {
      case '2gis':
        appUri = Uri.parse('geo:$lat,$lon');
        break;
      case 'yandex':
        appUri = Uri.parse(
          'yandexmaps://maps.yandex.ru/?pt=$lon,$lat&z=15&l=map',
        );
        break;
      case 'google':
        appUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon',
        );
        break;
      case 'apple':
        appUri = Uri.parse('http://maps.apple.com/?daddr=$lat,$lon');
        break;
      default:
        appUri = Uri.parse('geo:$lat,$lon');
    }

    if (await canLaunchUrl(appUri)) {
      debugPrint('✅ Открываю приложение по ссылке: $appUri');
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
      return;
    }

    debugPrint('⚠️ Приложение не найдено, пробую веб-версию (fallback)...');

    Uri webUri;
    switch (type) {
      case '2gis':
        webUri = Uri.parse('https://2gis.kg/geo/$lon,$lat');
        break;
      case 'yandex':
        webUri = Uri.parse('https://yandex.ru/maps/?pt=$lon,$lat&z=15&l=map');
        break;
      case 'google':
        webUri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
        );
        break;
      case 'apple':
        webUri = Uri.parse('https://maps.apple.com/?daddr=$lat,$lon');
        break;
      default:
        webUri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
        );
    }

    if (await canLaunchUrl(webUri)) {
      debugPrint('✅ Открываю веб-версию по ссылке: $webUri');
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ ОШИБКА: Не удалось открыть даже веб-версию: $webUri');
      if (context.mounted) {
        JoluSnackbar.show(
          context: context,
          message: 'Не удалось открыть карту. Проверьте интернет.',
          type: JoluSnackbarType.error,
        );
      }
    }
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
