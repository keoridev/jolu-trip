import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';

class GuideProfileSkeleton extends StatelessWidget {
  const GuideProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: AppDimens.space16),
          _buildSkeletonCircle(80),
          const SizedBox(height: AppDimens.space16),
          _buildSkeletonBox(width: 150, height: 20),
          const SizedBox(height: 8),
          _buildSkeletonBox(width: 100, height: 14),
          const SizedBox(height: AppDimens.space32),
          _buildSkeletonCard(height: 80),
          const SizedBox(height: AppDimens.space16),
          _buildSkeletonCard(height: 120),
        ],
      ),
    );
  }

  Widget _buildSkeletonCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.cardDark,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSkeletonBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
    );
  }

  Widget _buildSkeletonCard({required double height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
      ),
    );
  }
}
