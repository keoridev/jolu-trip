import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/location-detail/domain/entities/location_detail_entity.dart';

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
          Text('Координаты', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppDimens.spaceM),
          GestureDetector(
            onTap: onOpenMap,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Stack(
                children: [
                  // Заглушка карты (позже интегрируете 2GIS/Google Maps)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Нажмите для открытия в картах',
                          style: AppTextStyles.subtext,
                        ),
                      ],
                    ),
                  ),
                  // Координаты
                  Positioned(
                    bottom: AppDimens.spaceM,
                    left: AppDimens.spaceM,
                    right: AppDimens.spaceM,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(AppDimens.radiusS),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                              ),
                            ),
                          ),
                          Icon(
                            Icons.open_in_new,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
