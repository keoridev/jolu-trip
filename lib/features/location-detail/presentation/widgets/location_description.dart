
import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';

class LocationDescription extends StatelessWidget {
  final LocationDetailEntity location;

  const LocationDescription({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('О локации', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppDimens.spaceM),
          Text(location.description, style: AppTextStyles.body),
          if (location.gearList.isNotEmpty) ...[
            const SizedBox(height: AppDimens.spaceXL),
            Text('Что взять с собой', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppDimens.spaceM),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: location.gearList.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardElevated,
                    borderRadius: BorderRadius.circular(AppDimens.radiusRound),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(item, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          if (location.roadFeatures.isNotEmpty) ...[
            const SizedBox(height: AppDimens.spaceXL),
            Text('Особенности дороги', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppDimens.spaceM),
            Column(
              children: location.roadFeatures.map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.arrow_right_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Expanded(child: Text(feature, style: AppTextStyles.body)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
