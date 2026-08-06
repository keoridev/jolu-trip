import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/feedback/jolu_snackbar.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';
import 'package:jolutrip_app/features/location-detail/view/widgets/trip_readiness_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class MapFullscreenSheet extends StatelessWidget {
  final LocationDetailEntity location;

  const MapFullscreenSheet({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9, // Чуть выше для лучшего вида
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusL)),
      ),
      child: Column(
        children: [
          // 1. Ручка и шапка
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: AppDimens.space16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppDimens.space16),
                Padding(
                  padding: AppDimens.screenPadding.copyWith(top: 0),
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
                              style: AppTextStyles.monoSmall.copyWith(color: AppColors.textSecondary),
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
                          child: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Стилизованная "Карта" (Выглядит как реальная темная карта без API ключей)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppDimens.space16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D21), // Темный фон карты
                borderRadius: BorderRadius.circular(AppDimens.radiusL),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusL),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Фоновая сетка (имитация карты)
                    CustomPaint(
                      size: Size.infinite,
                      painter: _MapGridPainter(),
                    ),
                    
                    // Пульсирующий маркер локации
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.2),
                      duration: const Duration(seconds: 2),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.location_on_rounded, color: Colors.black, size: 32),
                    ),

                    // Бейдж с координатами поверх "карты"
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(AppDimens.radiusM),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                              style: AppTextStyles.monoSmall.copyWith(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimens.space24),

          // 3. Панель выбора навигатора (Стиль iOS Share Sheet)
          Container(
            padding: EdgeInsets.only(
              left: AppDimens.space24,
              right: AppDimens.space24,
              bottom: MediaQuery.of(context).padding.bottom + AppDimens.space24,
              top: AppDimens.space16,
            ),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radiusL)),
              border: Border(top: BorderSide(color: AppColors.borderDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Открыть в приложении', style: AppTextStyles.subtext.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppDimens.space16),
                
                // Список приложений
                _AppLauncherOption(
                  name: '2GIS',
                  subtitle: 'Лучшие офлайн-карты Кыргызстана',
                  icon: Icons.map_rounded,
                  color: const Color(0xFF00AAFF),
                  onTap: () => _prepareAndNavigate(context, '2gis'),
                ),
                const SizedBox(height: AppDimens.space12),
                _AppLauncherOption(
                  name: 'Yandex Карты',
                  subtitle: 'Популярный навигатор с пробками',
                  icon: Icons.location_city_rounded,
                  color: const Color(0xFFFF3333),
                  onTap: () => _prepareAndNavigate(context, 'yandex'),
                ),
                const SizedBox(height: AppDimens.space12),
                _AppLauncherOption(
                  name: 'Google Maps',
                  subtitle: 'Для международных путешественников',
                  icon: Icons.public_rounded,
                  color: const Color(0xFF34A853),
                  onTap: () => _prepareAndNavigate(context, 'google'),
                ),

                const SizedBox(height: AppDimens.space24),

                // Главная кнопка действия
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => _prepareAndNavigate(context, '2gis'),
                    icon: const Icon(Icons.navigation_rounded, color: Colors.black, size: 22),
                    label: const Text('Построить маршрут', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM)),
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
    Clipboard.setData(ClipboardData(text: '${location.latitude}, ${location.longitude}'));
    HapticFeedback.selectionClick();
    if (context.mounted) {
      JoluSnackbar.show(context: context, message: 'Координаты скопированы', type: JoluSnackbarType.success);
    }
  }

  void _prepareAndNavigate(BuildContext context, String navigatorType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TripReadinessSheet(
        location: location,
        onReady: () => _openNavigator(context, navigatorType),
      ),
    );
  }

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
      Uri webUri;
      switch (type) {
        case '2gis': webUri = Uri.parse('https://2gis.kg/geo/$lon,$lat'); break;
        case 'yandex': webUri = Uri.parse('https://yandex.ru/maps/?pt=$lon,$lat&z=15'); break;
        case 'google': webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon'); break;
        default: webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
      }

      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          JoluSnackbar.show(context: context, message: 'Не удалось открыть карту', type: JoluSnackbarType.error);
        }
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════
// ВИДЖЕТЫ ДЛЯ КРАСИВОГО ОТОБРАЖЕНИЯ
// ═══════════════════════════════════════════════════════════

class _AppLauncherOption extends StatelessWidget {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AppLauncherOption({required this.name, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppDimens.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Художник для рисования фоновой сетки (имитация карты)
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}