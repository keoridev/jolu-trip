import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/info_note_widget.dart';

/// Карточка одного документа.
///
/// Пока фото нет — иконка, подсказка и явный призыв загрузить. После загрузки
/// показывается миниатюра, чтобы гид видел, что именно он отправляет, и мог
/// заменить или удалить снимок.
class DocumentCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Uint8List? imageBytes;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final String hint;

  const DocumentCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.imageBytes,
    required this.onTap,
    required this.hint,
    this.onRemove,
  });

  bool get _isUploaded => imageBytes != null;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppDimens.space14),
          decoration: BoxDecoration(
            color: _isUploaded
                ? AppColors.success.withValues(alpha: 0.06)
                : AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppDimens.radius16),
            border: Border.all(
              color: _isUploaded
                  ? AppColors.success.withValues(alpha: 0.5)
                  : AppColors.borderDark,
              width: _isUploaded ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _Leading(icon: icon, imageBytes: imageBytes),
                  const SizedBox(width: AppDimens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            if (_isUploaded) ...[
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 13,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                _isUploaded ? 'Загружено' : subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 12,
                                  color: _isUploaded
                                      ? AppColors.success
                                      : AppColors.textTertiary,
                                  fontWeight: _isUploaded
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.space8),
                  if (_isUploaded && onRemove != null)
                    _CardAction(
                      icon: Icons.delete_outline_rounded,
                      tint: AppColors.error,
                      tooltip: 'Удалить',
                      onTap: onRemove!,
                    )
                  else if (!_isUploaded)
                    Container(
                      padding: const EdgeInsets.all(AppDimens.space6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 17,
                        color: AppColors.accent,
                      ),
                    ),
                ],
              ),
              if (!_isUploaded) ...[
                const SizedBox(height: AppDimens.space12),
                InfoNoteWidget(
                  message: hint,
                  tone: InfoNoteTone.info,
                  icon: Icons.lightbulb_outline_rounded,
                  compact: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Leading extends StatelessWidget {
  final IconData icon;
  final Uint8List? imageBytes;

  const _Leading({required this.icon, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    const size = 52.0;

    if (imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Image.memory(
          imageBytes!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Icon(icon, size: 24, color: AppColors.textTertiary),
    );
  }
}

class _CardAction extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String tooltip;
  final VoidCallback onTap;

  const _CardAction({
    required this.icon,
    required this.tint,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusRound),
          child: Container(
            padding: const EdgeInsets.all(AppDimens.space6),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: tint),
          ),
        ),
      ),
    );
  }
}
