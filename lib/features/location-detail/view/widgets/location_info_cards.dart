import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';

/// Ключевые факты о поездке: время, транспорт, связь, деньги.
class LocationInfoCards extends StatelessWidget {
  final LocationDetailEntity location;

  const LocationInfoCards({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final items = <_InfoData>[
      _InfoData(
        icon: Icons.access_time_rounded,
        title: 'ВРЕМЯ В ПУТИ',
        value: location.formattedDuration,
        color: AppColors.accent,
      ),
      _InfoData(
        icon: Icons.directions_car_rounded,
        title: 'ТРАНСПОРТ',
        value: location.carRequirement.isEmpty ? '—' : location.carRequirement,
        color: AppColors.primaryBright,
      ),
      _InfoData(
        icon: location.hasInternet ? Icons.wifi_rounded : Icons.wifi_off_rounded,
        title: 'СВЯЗЬ',
        value: location.hasInternet ? 'Есть' : 'Нет сигнала',
        color: location.hasInternet ? AppColors.success : AppColors.warning,
      ),
      _InfoData(
        icon: Icons.payments_rounded,
        title: 'СТОИМОСТЬ',
        value: location.priceStartsFrom > 0
            ? 'от ${location.priceStartsFrom.toStringAsFixed(0)} сом'
            : 'Бесплатно',
        color: location.priceStartsFrom > 0
            ? AppColors.primaryBright
            : AppColors.success,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16),
      child: Column(
        children: [
          // IntrinsicHeight, чтобы соседние карточки были одной высоты.
          // Один stretch без него роняет layout: в скролле высота не
          // ограничена, и stretch запрашивает бесконечную.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _InfoCard(data: items[0])),
                const SizedBox(width: AppDimens.space12),
                Expanded(child: _InfoCard(data: items[1])),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _InfoCard(data: items[2])),
                const SizedBox(width: AppDimens.space12),
                Expanded(child: _InfoCard(data: items[3])),
              ],
            ),
          ),
          if (location.entryFee != null && location.entryFee! > 0) ...[
            const SizedBox(height: AppDimens.space12),
            _InfoCard(
              data: _InfoData(
                icon: Icons.confirmation_number_rounded,
                title: 'ВХОДНОЙ БИЛЕТ',
                value: '${location.entryFee!.toStringAsFixed(0)} сом',
                color: AppColors.warning,
              ),
              isFullWidth: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoData {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoData({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });
}

class _InfoCard extends StatelessWidget {
  final _InfoData data;
  final bool isFullWidth;

  const _InfoCard({required this.data, this.isFullWidth = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(AppDimens.space14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
            child: Icon(data.icon, color: data.color, size: AppDimens.icon20),
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  style: AppTextStyles.badge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimens.space4),
                Text(
                  data.value,
                  style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                  // Две строки: «Нет сигнала» и «Нужен внедорожник» не влезают
                  // в одну на узких экранах и раньше обрезались троеточием.
                  maxLines: 2,
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
