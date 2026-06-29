
import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';

import 'map_fullscreen_sheet.dart';

class LocationMapPreview extends StatelessWidget {
  final LocationDetailEntity location;
  final VoidCallback? onOpenMap;

  const LocationMapPreview({super.key, required this.location, this.onOpenMap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Координаты', style: AppTextStyles.headlineMedium),
              GestureDetector(
                onTap: () => _showFullscreenMap(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimens.radiusRound),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fullscreen,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'На весь экран',
                        style: AppTextStyles.accentBadge.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space16),
          GestureDetector(
            onTap: onOpenMap,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                child: Stack(
                  children: [
                    // Статическая карта через Mapbox/2GIS Static API
                    // Или кастомная заглушка с координатной сеткой
                    _MapPlaceholder(
                      latitude: location.latitude,
                      longitude: location.longitude,
                    ),

                    // Градиент снизу
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 80,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.bgDark.withValues(alpha: 0.9),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Координаты + кнопка "Построить маршрут"
                    Positioned(
                      bottom: AppDimens.space16,
                      left: AppDimens.space16,
                      right: AppDimens.space16,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radiusS,
                                ),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      location.formattedCoordinates,
                                      style: AppTextStyles.monoSmall.copyWith(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _copyCoordinates(context),
                                    child: Icon(
                                      Icons.copy,
                                      color: AppColors.textSecondary,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Кнопка "Маршрут"
                          GestureDetector(
                            onTap: onOpenMap,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radiusM,
                                ),
                              ),
                              child: const Icon(
                                Icons.navigation,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Маркер по центру
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyCoordinates(BuildContext context) {
    // TODO: Clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Координаты скопированы'),
        backgroundColor: AppColors.cardElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
      ),
    );
  }

  void _showFullscreenMap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MapFullscreenSheet(location: location),
    );
  }
}

/// Заглушка карты с координатной сеткой
class _MapPlaceholder extends StatelessWidget {
  final double latitude;
  final double longitude;

  const _MapPlaceholder({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1a1a2e),
      child: CustomPaint(
        size: Size.infinite,
        painter: _GridPainter(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.terrain,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              const SizedBox(height: 8),
              Text(
                '${latitude.toStringAsFixed(2)}°N',
                style: AppTextStyles.mono.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              Text(
                '${longitude.toStringAsFixed(2)}°E',
                style: AppTextStyles.mono.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const spacing = 40.0;

    // Вертикальные линии
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Горизонтальные линии
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
