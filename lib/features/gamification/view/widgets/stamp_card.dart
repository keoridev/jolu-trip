// lib/features/gamification/presentation/widgets/stamp_card.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/stamp.dart';

class StampCard extends StatelessWidget {
  final Stamp stamp;

  const StampCard({super.key, required this.stamp});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Картинка печати
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              border: Border.all(
                color: _getRarityColor(stamp.rarity).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusM - 2),
              child: Image.asset(
                stamp.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: _getRarityColor(stamp.rarity).withOpacity(0.15),
                  child: Center(
                    child: Icon(
                      _getFallbackIcon(stamp.id),
                      size: 40,
                      color: _getRarityColor(stamp.rarity),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Название
        Text(
          stamp.title,
          style: AppTextStyles.body.copyWith(fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 2),
        
        // Редкость
        Text(
          _getRarityLabel(stamp.rarity),
          style: AppTextStyles.subtext.copyWith(
            fontSize: 9,
            color: _getRarityColor(stamp.rarity),
          ),
        ),
      ],
    );
  }

  Color _getRarityColor(StampRarity rarity) {
    return switch (rarity) {
      StampRarity.common => Colors.grey[400]!,
      StampRarity.silver => const Color(0xFFC0C0C0),
      StampRarity.gold => const Color(0xFFFFD700),
      StampRarity.legendary => const Color(0xFFB388FF),
    };
  }

  String _getRarityLabel(StampRarity rarity) {
    return switch (rarity) {
      StampRarity.common => 'Обычная',
      StampRarity.silver => 'Серебряная',
      StampRarity.gold => 'Золотая',
      StampRarity.legendary => 'Легендарная',
    };
  }

  IconData _getFallbackIcon(String stampId) {
    return switch (stampId) {
      'first_step' => Icons.hiking,
      'first_canyon' => Icons.terrain,
      'issyk_kul' => Icons.water,
      'ala_archa' => Icons.landscape,
      'guided' => Icons.verified_user,
      'son_kul' => Icons.grass,
      _ => Icons.stars,
    };
  }
}