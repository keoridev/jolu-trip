import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';

class LocationRoadsidePlaces extends StatelessWidget {
  final List<RoadsidePlaceEntity> places;

  const LocationRoadsidePlaces({super.key, required this.places});

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Где остановиться', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppDimens.spaceM),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: places.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppDimens.spaceM),
              itemBuilder: (context, index) {
                final place = places[index];
                return _PlaceCard(place: place);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final RoadsidePlaceEntity place;

  const _PlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Фото
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusM),
            ),
            child: place.photos.isNotEmpty
                ? Image.network(
                    place.photos.first,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 100,
                    color: AppColors.cardElevated,
                    child: const Center(
                      child: Icon(Icons.image, color: AppColors.textMuted),
                    ),
                  ),
          ),
          Padding(
            padding: AppDimens.cardContentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Категория
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppDimens.radiusS),
                  ),
                  child: Text(
                    place.categoryLabel,
                    style: AppTextStyles.accentBadge.copyWith(fontSize: 10),
                  ),
                ),
                const SizedBox(height: 6),
                // Название
                Text(
                  place.name,
                  style: AppTextStyles.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Описание
                Text(
                  place.description,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (place.averageCheck != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Средний чек: ${place.averageCheck!.toStringAsFixed(0)} сом',
                        style: AppTextStyles.subtext.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
