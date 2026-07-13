import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/buttons/jolu_icon_button.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';

/// Блок автомобиля гида.
///
/// Структура: фото машины на всю ширину → таблица характеристик.
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
            _buildCarPhoto(),
            const SizedBox(height: AppDimens.space16),
            _buildSpecsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.directions_car_outlined,
              color: AppColors.primary,
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

  Widget _buildCarPhoto() {
    final photoUrl = onboarding.carPhotosUrls?.firstOrNull;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusM),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: photoUrl != null && photoUrl.isNotEmpty
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPhotoPlaceholder(),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return _buildPhotoPlaceholder(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  );
                },
              )
            : _buildPhotoPlaceholder(),
      ),
    );
  }

  Widget _buildPhotoPlaceholder({Widget? child}) {
    return Container(
      color: AppColors.cardDark,
      child: Center(
        child: child ??
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

  Widget _buildSpecsTable() {
    final specs = <_SpecRow>[
      _SpecRow(
        icon: Icons.directions_car_outlined,
        label: 'Модель',
        value: onboarding.carModel.isNotEmpty
            ? onboarding.carModel
            : 'Не указана',
      ),
      _SpecRow(
        icon: Icons.confirmation_number_outlined,
        label: 'Гос. номер',
        value: onboarding.carNumber.isNotEmpty
            ? onboarding.carNumber.toUpperCase()
            : 'Не указан',
      ),
      _SpecRow(
        icon: Icons.people_outline,
        label: 'Вместимость',
        value: '8 пассажиров', // TODO: добавить в onboarding если нужно
      ),
      _SpecRow(
        icon: Icons.calendar_today_outlined,
        label: 'Год выпуска',
        value: '2022', // TODO: добавить в onboarding если нужно
      ),
    ];

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
                color: AppColors.textSecondary.withValues(alpha: 0.5),
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
        if (showDivider)
          Divider(
            height: 1,
            color: AppColors.borderDark,
          ),
      ],
    );
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