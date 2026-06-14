import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';

class LocationHeroSection extends StatelessWidget {
  final LocationDetailEntity location;
  final VoidCallback? onVideoTap;

  const LocationHeroSection({
    super.key,
    required this.location,
    this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Image.network(
            location.thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: AppColors.cardDark,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
        ),

        // Градиент для читаемости
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.bgDark.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
        ),

        // Категория
        Positioned(
          bottom: AppDimens.spaceM,
          left: AppDimens.spaceM,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimens.radiusS),
            ),
            child: Text(
              location.category.toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ),

        // Название + короткое описание
        Positioned(
          bottom: 45,
          left: AppDimens.spaceM,
          right: AppDimens.spaceM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(location.name, style: AppTextStyles.headline),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }
}
