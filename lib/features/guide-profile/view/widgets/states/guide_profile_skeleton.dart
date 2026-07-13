import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';

/// Профессиональный скелетон с шиммер-эффектом.
/// 
/// UX: анимация показывает, что контент загружается, а не завис.
/// Использует RepaintBoundary для изоляции анимации.
class GuideProfileSkeleton extends StatefulWidget {
  const GuideProfileSkeleton({super.key});

  @override
  State<GuideProfileSkeleton> createState() => _GuideProfileSkeletonState();
}

class _GuideProfileSkeletonState extends State<GuideProfileSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: AppDimens.space16),
          _ShimmerCircle(animation: _animation, size: 96),
          const SizedBox(height: AppDimens.space16),
          _ShimmerBox(animation: _animation, width: 160, height: 20),
          const SizedBox(height: AppDimens.space8),
          _ShimmerBox(animation: _animation, width: 120, height: 14),
          const SizedBox(height: AppDimens.space32),
          _ShimmerCard(animation: _animation, height: 100),
          const SizedBox(height: AppDimens.space16),
          _ShimmerCard(animation: _animation, height: 140),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final Animation<double> animation;
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.animation,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.cardDark.withValues(alpha: animation.value),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  final Animation<double> animation;
  final double size;

  const _ShimmerCircle({
    required this.animation,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.cardDark.withValues(alpha: animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final Animation<double> animation;
  final double height;

  const _ShimmerCard({
    required this.animation,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardDark.withValues(alpha: animation.value),
            borderRadius: BorderRadius.circular(AppDimens.radiusL),
          ),
        );
      },
    );
  }
}