import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/safety/data/models/safety_models.dart';
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
            AppColors.error.withValues(alpha: 0.15),
            AppColors.error.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimens.space16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Text('GPS Координаты', style: AppTextStyles.title.copyWith(fontSize: 16)),
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
                        child: const Icon(
                          Icons.refresh,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimens.space16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimens.space16),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coordinates?.decimal ?? '--.------, --.------',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coordinates?.dms ?? '--° --\' --" N, --° --\' --" E',
                        style: AppTextStyles.subtext.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.space16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: coordinates != null ? () => _shareLocation(context, coordinates!) : null,
                        icon: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                        label: const Text(
                          'Отправить близким',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM)),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.space12),
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        onPressed: coordinates != null ? () => _showMapPicker(context, coordinates!) : null,
                        icon: const Icon(Icons.map_rounded, size: 18),
                        label: const Text('Карта', style: TextStyle(fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: BorderSide(color: AppColors.borderDark),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(AppDimens.space16),
            child: ElevatedButton.icon(
              onPressed: onSos,
              icon: const Icon(Icons.emergency_rounded, color: Colors.white),
              label: const Text(
                'Вызвать МЧС: 112',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareLocation(BuildContext context, GpsCoordinates coords) async {
    final message = '📍 Мои координаты (JoLuTrip):\n'
        'Широта: ${coords.latitude}\n'
        'Долгота: ${coords.longitude}\n'
        'Ссылка на карту: https://www.google.com/maps?q=${coords.latitude},${coords.longitude}';

    await Share.share(message, subject: 'Мое местоположение');
  }

  void _showMapPicker(BuildContext context, GpsCoordinates coords) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusL)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: AppDimens.screenPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppDimens.space24),
                  decoration: BoxDecoration(
                    color: AppColors.borderDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Показать на карте', style: AppTextStyles.headline.copyWith(fontSize: 20)),
              const SizedBox(height: AppDimens.space12),
              Text('Выберите приложение', style: AppTextStyles.subtext),
              const SizedBox(height: AppDimens.space32),
              _MapOption(
                name: '2GIS',
                description: 'Офлайн-карты Кыргызстана',
                color: const Color(0xFF2688EB),
                icon: 'assets/icons/2gis.png',
                onTap: () => _open2Gis(context, coords),
              ),
              const SizedBox(height: AppDimens.space16),
              _MapOption(
                name: 'Google Maps',
                description: 'Веб-версия (не нужно приложение)',
                color: const Color(0xFFEA4335),
                icon: 'assets/icons/maps.png',
                onTap: () => _openGoogleMaps(context, coords),
              ),
              const SizedBox(height: AppDimens.space32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open2Gis(BuildContext context, GpsCoordinates coords) async {
    final lat = coords.latitude;
    final lon = coords.longitude;
    final appUri = Uri.parse('geo:$lat,$lon?q=$lat,$lon');
    final webUri = Uri.parse('https://2gis.kg/geo/$lat,$lon?m=$lat,$lon/z=16');

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _openGoogleMaps(BuildContext context, GpsCoordinates coords) async {
    final lat = coords.latitude;
    final lon = coords.longitude;
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
        padding: const EdgeInsets.all(AppDimens.space16),
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
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
              child: Image.asset(
                icon,
                color: color,
                width: 32,
                height: 32,
                errorBuilder: (_, __, ___) => Icon(Icons.map, color: color, size: 32),
              ),
            ),
            const SizedBox(width: AppDimens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(description, style: AppTextStyles.subtext.copyWith(fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}