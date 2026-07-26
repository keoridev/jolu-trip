import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';

import 'location_section.dart';

class LocationRoadsidePlaces extends StatelessWidget {
  final List<RoadsidePlaceEntity> places;

  const LocationRoadsidePlaces({super.key, required this.places});

  /// Высота карточки посчитана под её содержимое: фото 132 + падинги 28 +
  /// название 20 + описание в 2 строки 36 + подвал 20 + зазоры.
  /// Раньше здесь стояло 200 при фактических ~245 — список ронял
  /// RenderFlex overflow, как только у места был указан средний чек.
  static const double _cardHeight = 252;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return const SizedBox.shrink();

    return LocationSection(
      title: 'Где остановиться',
      subtitle: 'Кафе, юрты и заправки по дороге',
      contentFullBleed: true,
      child: SizedBox(
        height: _cardHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          // Падинг у списка, а не у секции: иначе крайние карточки
          // обрезаются и не видно, что список скроллится.
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16),
          clipBehavior: Clip.none,
          itemCount: places.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppDimens.space12),
          itemBuilder: (context, index) => _PlaceCard(place: places[index]),
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final RoadsidePlaceEntity place;

  const _PlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(AppDimens.radiusM),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Тап пока ничего не открывает — экрана места ещё нет, но карточка
        // должна отзываться на нажатие, иначе выглядит сломанной.
        onTap: () {},
        child: Container(
          width: 252,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _PlacePhoto(url: place.photos.isNotEmpty ? place.photos.first : null),
                  // Бейдж категории перенесён на фото — это освободило
                  // ~24px по высоте в текстовой части карточки.
                  Positioned(
                    left: AppDimens.space10,
                    top: AppDimens.space10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.space8,
                        vertical: AppDimens.space4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusRound,
                        ),
                      ),
                      child: Text(
                        place.categoryLabel,
                        style: AppTextStyles.accentBadge.copyWith(fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
              // Expanded + Spacer: содержимое подстраивается под фиксированную
              // высоту карточки и не может её переполнить.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.space14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: AppTextStyles.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimens.space4),
                      Expanded(
                        child: Text(
                          place.description,
                          style: AppTextStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (place.averageCheck != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.payments_outlined,
                              size: AppDimens.icon16,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: AppDimens.space6),
                            Expanded(
                              child: Text(
                                'Чек ~${place.averageCheck!.toStringAsFixed(0)} сом',
                                style: AppTextStyles.subtext.copyWith(
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlacePhoto extends StatelessWidget {
  final String? url;

  const _PlacePhoto({this.url});

  static const double _height = 132;

  @override
  Widget build(BuildContext context) {
    final url = this.url;

    if (url == null || url.isEmpty) return const _PhotoFallback();

    return Image.network(
      url,
      height: _height,
      width: double.infinity,
      fit: BoxFit.cover,
      // Раньше errorBuilder не было вовсе: битая ссылка красила карточку
      // серым блоком с исключением поверх.
      errorBuilder: (_, _, _) => const _PhotoFallback(),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return const SizedBox(
          height: _height,
          width: double.infinity,
          child: ColoredBox(color: AppColors.cardElevated),
        );
      },
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: _PlacePhoto._height,
      width: double.infinity,
      child: ColoredBox(
        color: AppColors.cardElevated,
        child: Center(
          child: Icon(
            Icons.photo_outlined,
            color: AppColors.textMuted,
            size: AppDimens.icon28,
          ),
        ),
      ),
    );
  }
}
