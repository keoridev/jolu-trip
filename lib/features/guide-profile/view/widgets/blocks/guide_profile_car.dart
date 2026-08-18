import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/buttons/jolu_icon_button.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/onboarding_options.dart';

/// Блок автомобиля гида.
///
/// Структура:
/// - Фото машины (с горизонтальной прокруткой, если несколько)
/// - Заголовок: "Внедорожник · Toyota Sequoia"
/// - Таблица характеристик (год, места, руль, гос. номер)
/// - Преимущества авто (чипсы, если есть)
class GuideCarBlock extends StatelessWidget {
  final OnboardingEntity onboarding;
  final bool isEditable;
  final VoidCallback? onEdit;

  const GuideCarBlock({
    super.key,
    required this.onboarding,
    required this.isEditable,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.screenPadding,
      child: _AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppDimens.space16),
            _buildCarPhotos(),
            const SizedBox(height: AppDimens.space16),
            _buildTitleRow(),
            const SizedBox(height: AppDimens.space12),
            _buildSpecsTable(),
            if (onboarding.carFeatures.isNotEmpty) ...[
              const SizedBox(height: AppDimens.space16),
              _buildFeatures(),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Header: иконка + кнопка "Изменить" ──────────────────────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.directions_car_outlined,
              color: AppColors.accent,
              size: 20,
            ),
            const SizedBox(width: AppDimens.space8),
            Text('Автомобиль', style: AppTextStyles.subtitle),
          ],
        ),
        if (isEditable)
          JoluIconButton(
            icon: Icons.edit_outlined,
            onPressed: onEdit,
            variant: JoluIconButtonVariant.secondary,
            size: 36,
            iconSize: 18,
          ),
      ],
    );
  }

  // ─── Фото машины (1 или 4) ──────────────────────────────────────────
  Widget _buildCarPhotos() {
    final photos = onboarding.carPhotosUrls ?? const [];

    if (photos.isEmpty) {
      return _buildPhotoPlaceholder();
    }

    if (photos.length == 1) {
      return _buildPhotoTile(photos.first);
    }

    // Горизонтальная галерея для нескольких фото
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.space8),
        itemBuilder: (context, index) =>
            SizedBox(width: 240, child: _buildPhotoTile(photos[index])),
      ),
    );
  }

  Widget _buildPhotoTile(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusM),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPhotoPlaceholder(),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return _buildPhotoPlaceholder(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder({Widget? child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: Center(
        child:
            child ??
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_car_outlined,
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  size: 48,
                ),
                const SizedBox(height: AppDimens.space8),
                Text(
                  'Фото не добавлено',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  // ─── Заголовок: "Внедорожник · Toyota Sequoia" ──────────────────────
  Widget _buildTitleRow() {
    final category = carCategoryByValue(onboarding.carCategory);
    final categoryLabel = category?.label;
    final model = onboarding.carModel.isNotEmpty ? onboarding.carModel : null;

    String title;
    if (categoryLabel != null && model != null) {
      title = '$categoryLabel · $model';
    } else if (categoryLabel != null) {
      title = categoryLabel;
    } else if (model != null) {
      title = model;
    } else {
      title = 'Автомобиль не указан';
    }

    return Text(
      title,
      style: AppTextStyles.headlineSmall.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // ─── Таблица характеристик ──────────────────────────────────────────
  Widget _buildSpecsTable() {
    final year = onboarding.carYear;
    final seats = onboarding.carSeats;
    final steering = onboarding.steeringWheel;
    final number = onboarding.carNumber;

    final specs = <_SpecRow>[
      if (year > 0)
        _SpecRow(
          icon: Icons.calendar_today_outlined,
          label: 'Год выпуска',
          value: '$year',
        ),
      if (seats > 0)
        _SpecRow(
          icon: Icons.airline_seat_recline_normal_outlined,
          label: 'Количество мест',
          value: '$seats ${_pluralSeats(seats)}',
        ),
      _SpecRow(
        icon: Icons.circle_outlined,
        label: 'Руль',
        value: steering == 'right' ? 'Правый' : 'Левый',
      ),
      if (number.isNotEmpty)
        _SpecRow(
          icon: Icons.confirmation_number_outlined,
          label: 'Гос. номер',
          value: number.toUpperCase(),
        ),
    ];

    if (specs.isEmpty) {
      return Text(
        'Характеристики не указаны',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
      );
    }

    return Column(
      children: specs.asMap().entries.map((entry) {
        final isLast = entry.key == specs.length - 1;
        return _buildSpecRow(entry.value, showDivider: !isLast);
      }).toList(),
    );
  }

  Widget _buildSpecRow(_SpecRow spec, {required bool showDivider}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.space12),
          child: Row(
            children: [
              Icon(
                spec.icon,
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                size: 18,
              ),
              const SizedBox(width: AppDimens.space12),
              Text(
                spec.label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                spec.value,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, color: AppColors.borderDark),
      ],
    );
  }

  // ─── Преимущества авто (чипсы) ──────────────────────────────────────
  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Преимущества',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimens.space8),
        Wrap(
          spacing: AppDimens.space8,
          runSpacing: AppDimens.space8,
          children: onboarding.carFeatures.map((feature) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space12,
                vertical: AppDimens.space6,
              ),
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(AppDimens.radiusRound),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Text(
                carFeatureLabel(feature),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _pluralSeats(int n) {
    final last = n % 10;
    final lastTwo = n % 100;
    if (lastTwo >= 11 && lastTwo <= 14) return 'мест';
    if (last == 1) return 'место';
    if (last >= 2 && last <= 4) return 'места';
    return 'мест';
  }
}

class _SpecRow {
  final IconData icon;
  final String label;
  final String value;

  const _SpecRow({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _AppCard extends StatelessWidget {
  final Widget child;

  const _AppCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: child,
    );
  }
}
