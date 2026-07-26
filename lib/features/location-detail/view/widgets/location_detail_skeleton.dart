import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:shimmer/shimmer.dart';

/// Скелет страницы вместо одинокого спиннера по центру: пользователь сразу
/// видит структуру, и переход в загруженное состояние не дёргает layout.
class LocationDetailSkeleton extends StatelessWidget {
  const LocationDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final heroHeight = (MediaQuery.sizeOf(context).width * 0.78).clamp(
      300.0,
      420.0,
    );

    return Shimmer.fromColors(
      baseColor: AppColors.cardDark,
      highlightColor: AppColors.cardElevated,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Box(height: heroHeight, radius: 0),
            const SizedBox(height: AppDimens.space20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _Box(height: 66)),
                      SizedBox(width: AppDimens.space12),
                      Expanded(child: _Box(height: 66)),
                    ],
                  ),
                  SizedBox(height: AppDimens.space12),
                  Row(
                    children: [
                      Expanded(child: _Box(height: 66)),
                      SizedBox(width: AppDimens.space12),
                      Expanded(child: _Box(height: 66)),
                    ],
                  ),
                  SizedBox(height: AppDimens.space32),
                  _Box(height: 20, width: 140),
                  SizedBox(height: AppDimens.space16),
                  _Box(height: 14),
                  SizedBox(height: AppDimens.space8),
                  _Box(height: 14),
                  SizedBox(height: AppDimens.space8),
                  _Box(height: 14, width: 220),
                  SizedBox(height: AppDimens.space32),
                  _Box(height: 20, width: 110),
                  SizedBox(height: AppDimens.space16),
                  _Box(height: 170),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;

  const _Box({required this.height, this.width, this.radius = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
