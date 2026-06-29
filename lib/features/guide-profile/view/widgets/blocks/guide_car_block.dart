// lib/features/guide_profile/presentation/widgets/blocks/guide_car_block.dart

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';

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
    return _buildBlock(
      title: 'Автомобиль',
      trailing: isEditable
          ? IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: onEdit,
              color: AppColors.primary,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              const SizedBox(width: AppDimens.space16),
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
                    Text('Модель автомобиля', style: AppTextStyles.headlineMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space24),
          Text('Гос. номер', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppDimens.space12),
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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 18,
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
            height: 22,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlock({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.subtitle),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: AppDimens.space24),
          child,
        ],
      ),
    );
  }
}
