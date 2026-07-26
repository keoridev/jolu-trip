import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

/// Пустой слот под фото автомобиля.
///
/// Слот всегда подписан нужным ракурсом, поэтому гид не гадает, какое фото
/// от него ждут в этой ячейке.
class AddPhotoButtonWidget extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;

  const AddPhotoButtonWidget({
    super.key,
    required this.onTap,
    this.label = 'Добавить фото',
    this.hint = '',
    this.icon = Icons.add_a_photo_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        child: CustomPaint(
          painter: const DashedBorderPainter(
            color: AppColors.borderDark,
            radius: AppDimens.radius16,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppDimens.space8),
            decoration: BoxDecoration(
              color: AppColors.cardDark.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppDimens.radius16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.textTertiary, size: 26),
                const SizedBox(height: AppDimens.space8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (hint.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    hint,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Пунктирная рамка — визуально отличает «сюда ещё надо положить фото»
/// от уже заполненных слотов.
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashLength;
  final double gapLength;
  final double strokeWidth;

  const DashedBorderPainter({
    required this.color,
    required this.radius,
    this.dashLength = 6,
    this.gapLength = 5,
    this.strokeWidth = 1.4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.dashLength != dashLength ||
      oldDelegate.gapLength != gapLength ||
      oldDelegate.strokeWidth != strokeWidth;
}
