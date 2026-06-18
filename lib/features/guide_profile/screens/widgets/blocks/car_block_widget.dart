// lib/features/guide_profile/presentation/widgets/blocks/car_block_widget.dart

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';

class CarBlockWidget extends StatelessWidget {
  final OnboardingEntity onboarding;

  const CarBlockWidget({super.key, required this.onboarding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.spaceL),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Автомобиль', style: AppTextStyles.subtitle),
          const SizedBox(height: AppDimens.spaceL),

          // Модель
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
                child: Icon(
                  Icons.directions_car_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      onboarding.carModel,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('Модель автомобиля'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimens.spaceL),

          // Госномер КР (стилизованная рамка)
          Text('Гос. номер'),
          const SizedBox(height: AppDimens.spaceS),
          _buildKyrgyzPlate(onboarding.carNumber),
        ],
      ),
    );
  }

  Widget _buildKyrgyzPlate(String number) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Флаг КР (упрощённо)
          Container(
            width: 24,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFF0066CC),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Center(
              child: Text(
                'KG',
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: Colors.black,
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),
          Text(
            number.toUpperCase(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontFamily: 'RobotoMono',
            ),
          ),
        ],
      ),
    );
  }
}
