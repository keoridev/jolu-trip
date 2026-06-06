import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/safety/data/models/models.dart';
import 'package:url_launcher/url_launcher.dart';

class SosBlock extends StatelessWidget {
  final GpsCoordinates? coordinates;
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onSos;

  const SosBlock({
    super.key,
    this.coordinates,
    required this.isLoading,
    required this.onRefresh,
    required this.onSos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.error.withOpacity(0.2),
            AppColors.error.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // GPS координаты
          Padding(
            padding: const EdgeInsets.all(AppDimens.spaceM),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'GPS Координаты',
                      style: AppTextStyles.title.copyWith(fontSize: 16),
                    ),
                    const Spacer(),
                    if (isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.error,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: onRefresh,
                        child: Icon(
                          Icons.refresh,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimens.spaceM),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimens.spaceM),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coordinates?.decimal ?? '--.------, --.------',
                        style: AppTextStyles.body.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coordinates?.dms ?? '--° --\' --" N --° --\' --" E',
                        style: AppTextStyles.subtext.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.spaceS),

                // Кнопки действий
                Row(
                  children: [
                    // Копировать
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: coordinates != null
                            ? () => _copyCoords(context, coordinates!)
                            : null,
                        icon: Icon(
                          Icons.copy,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        label: Text('Копировать', style: AppTextStyles.subtext),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(color: AppColors.borderDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.spaceS),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: coordinates != null
                            ? () => _showMapPicker(context, coordinates!)
                            : null,
                        icon: Icon(Icons.map, color: Colors.black, size: 16),
                        label: Text(
                          'На карте',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // SOS Кнопка
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(AppDimens.spaceM),
            child: ElevatedButton.icon(
              onPressed: onSos,
              icon: const Icon(Icons.emergency, color: Colors.white),
              label: Text(
                'Вызвать МЧС 112',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyCoords(BuildContext context, GpsCoordinates coords) async {
    await Clipboard.setData(ClipboardData(text: coords.decimal));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${coords.decimal} — скопировано'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
          ),
        ),
      );
    }
  }

  void _showMapPicker(BuildContext context, GpsCoordinates coords) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusL),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: AppDimens.screenPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Индикатор сверху
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppDimens.spaceL),
                  decoration: BoxDecoration(
                    color: AppColors.borderDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Показать на карте',
                style: AppTextStyles.headline.copyWith(fontSize: 20),
              ),
              const SizedBox(height: AppDimens.spaceS),
              Text('Выберите приложение', style: AppTextStyles.subtext),
              const SizedBox(height: AppDimens.spaceXL),

              // 2GIS
              _MapOption(
                name: '2GIS',
                description: 'Офлайн-карты Кыргызстана',
                color: const Color(0xFF2688EB),
                icon: 'assets/icons/2gis.png',
                onTap: () => _open2Gis(context, coords),
              ),
              const SizedBox(height: AppDimens.spaceM),

              // Google Maps (fallback)
              _MapOption(
                name: 'Google Maps',
                description: 'Веб-версия (не нужно приложение)',
                color: const Color(0xFFEA4335),
                icon: 'assets/icons/maps.png',
                onTap: () => _openGoogleMaps(context, coords),
              ),
              const SizedBox(height: AppDimens.spaceXL),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open2Gis(BuildContext context, GpsCoordinates coords) async {
    final lat = coords.latitude;
    final lon = coords.longitude;

    // 🔥 Правильный deep link для 2GIS
    // Формат: geo:lat,lon или https://2gis.kg/geo/$lat,$lon
    final appUri = Uri.parse('geo:$lat,$lon?q=$lat,$lon');
    final webUri = Uri.parse('https://2gis.kg/geo/$lat,$lon?m=$lat,$lon/z=16');

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }

    if (context.mounted) Navigator.pop(context);
  }

  // Google Maps — точка, не поиск
  Future<void> _openGoogleMaps(
    BuildContext context,
    GpsCoordinates coords,
  ) async {
    final lat = coords.latitude;
    final lon = coords.longitude;

    // 🔥 Показываем точку, а не поиск
    final uri = Uri.parse(
      'https://www.google.com/maps/@?api=1&map_action=map&center=$lat,$lon&zoom=16',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (context.mounted) Navigator.pop(context);
  }
}

class _MapOption extends StatelessWidget {
  final String name;
  final String description;
  final Color color;
  final String icon;
  final VoidCallback onTap;

  const _MapOption({
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusL),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.spaceM),
        decoration: BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
              child: Image.asset(icon, color: color, width: 32, height: 32),
            ),
            const SizedBox(width: AppDimens.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTextStyles.subtext.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
