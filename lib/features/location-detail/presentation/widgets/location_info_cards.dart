import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';

class LocationInfoCards extends StatelessWidget {
  final LocationDetailEntity location;

  const LocationInfoCards({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.screenPadding,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.access_time_rounded,
                  title: 'Время в пути',
                  value: location.formattedDuration,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: AppDimens.spaceM),
              Expanded(
                child: _InfoCard(
                  icon: Icons.directions_car_rounded,
                  title: 'Транспорт',
                  value: location.carRequirement,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceM),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: location.hasInternet
                      ? Icons.wifi_rounded
                      : Icons.wifi_off_rounded,
                  title: 'Связь',
                  value: location.hasInternet ? 'Есть' : 'Нет сигнала',
                  color: location.hasInternet
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
              const SizedBox(width: AppDimens.spaceM),
              Expanded(
                child: _InfoCard(
                  icon: Icons.payments_rounded,
                  title: 'Стоимость',
                  value: location.priceStartsFrom > 0
                      ? 'от ${location.priceStartsFrom.toStringAsFixed(0)} сом'
                      : 'Бесплатно',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (location.entryFee != null && location.entryFee! > 0) ...[
            const SizedBox(height: AppDimens.spaceM),
            _InfoCard(
              icon: Icons.confirmation_number_rounded,
              title: 'Входной билет',
              value: '${location.entryFee!.toStringAsFixed(0)} сом',
              color: AppColors.warning,
              isFullWidth: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isFullWidth;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(AppDimens.spaceM),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppDimens.radiusS),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppDimens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.badge),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
