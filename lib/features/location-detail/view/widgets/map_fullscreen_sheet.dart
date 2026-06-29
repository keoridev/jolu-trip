import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';

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
          // Handle
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

          // Header
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

          // Карта (заглушка)
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
                      'Скоро: 2GIS, Yandex Maps, Google Maps',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    // Кнопки быстрого открытия
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _MapButton(
                          label: '2GIS',
                          icon: Icons.map,
                          onTap: () => _open2Gis(context),
                        ),
                        _MapButton(
                          label: 'Yandex',
                          icon: Icons.location_city,
                          onTap: () => _openYandex(context),
                        ),
                        _MapButton(
                          label: 'Google',
                          icon: Icons.public,
                          onTap: () => _openGoogle(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Нижняя панель
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
                    onTap: () => _openNavigator(context),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Координаты скопированы')));
  }

  void _openNavigator(BuildContext context) {
    // Показываем выбор навигатора
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _NavigatorPickerSheet(location: location),
    );
  }

  void _open2Gis(BuildContext context) {
    /* TODO */
  }
  void _openYandex(BuildContext context) {
    /* TODO */
  }
  void _openGoogle(BuildContext context) {
    /* TODO */
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

/// Выбор навигатора
class _NavigatorPickerSheet extends StatelessWidget {
  final LocationDetailEntity location;

  const _NavigatorPickerSheet({required this.location});

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
          Text('Построить маршрут', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppDimens.space12),
          Text(
            'Выберите приложение для навигации',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.space32),

          // 2GIS — приоритет для КР
          _NavigatorOption(
            icon: Icons.map,
            label: '2GIS',
            subtitle: 'Лучшие карты Кыргызстана',
            color: const Color(0xFF00AAFF),
            onTap: () => _launch2Gis(),
          ),
          const SizedBox(height: AppDimens.space16),

          // Yandex Maps
          _NavigatorOption(
            icon: Icons.location_city,
            label: 'Yandex Maps',
            subtitle: 'Популярный в СНГ',
            color: const Color(0xFFFF3333),
            onTap: () => _launchYandex(),
          ),
          const SizedBox(height: AppDimens.space16),

          // Google Maps
          _NavigatorOption(
            icon: Icons.public,
            label: 'Google Maps',
            subtitle: 'Для международных туристов',
            color: const Color(0xFF34A853),
            onTap: () => _launchGoogle(),
          ),
        ],
      ),
    );
  }

  void _launch2Gis() {
    // 2gis://geo?lat=...&lon=...
    // https://2gis.kg/
  }

  void _launchYandex() {
    // yandexmaps://maps.yandex.ru/?pt=lng,lat&z=15&l=map
  }

  void _launchGoogle() {
    // https://www.google.com/maps/dir/?api=1&destination=lat,lng
  }
}

class _NavigatorOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _NavigatorOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimens.radiusS),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppDimens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.subtitle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
