import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

/// Заполненный слот фото автомобиля.
///
/// Подпись ракурса приходит извне и привязана к слоту, а не к позиции в
/// списке — удаление одного фото больше не переименовывает остальные.
class PhotoPreviewWidget extends StatelessWidget {
  final Uint8List bytes;
  final String label;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const PhotoPreviewWidget({
    super.key,
    required this.bytes,
    required this.label,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radius16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true),

          // Затемнение снизу, чтобы подпись читалась на любом кадре.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC000000)],
              ),
            ),
          ),

          if (onTap != null)
            Material(
              color: Colors.transparent,
              child: InkWell(onTap: onTap, child: const SizedBox.expand()),
            ),

          Positioned(
            left: AppDimens.space8,
            right: AppDimens.space8,
            bottom: AppDimens.space8,
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppDimens.space6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: AppDimens.space6,
            right: AppDimens.space6,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(AppDimens.radiusRound),
                child: Container(
                  padding: const EdgeInsets.all(AppDimens.space6),
                  decoration: const BoxDecoration(
                    color: Color(0xB3000000),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
