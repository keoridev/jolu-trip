import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/info_note_widget.dart';

/// Карточка видео-визитки.
///
/// Кадр из видео здесь не отрисовать без декодера, поэтому загруженный ролик
/// подтверждается размером файла — гид видит, что залилось не пустое.
class VideoPreviewWidget extends StatelessWidget {
  final Uint8List? videoBytes;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const VideoPreviewWidget({
    super.key,
    required this.videoBytes,
    required this.onTap,
    required this.onRemove,
  });

  bool get _isUploaded => videoBytes != null;

  String get _sizeLabel {
    final mb = (videoBytes?.lengthInBytes ?? 0) / (1024 * 1024);
    if (mb < 0.1) return 'меньше 0.1 МБ';
    return '${mb.toStringAsFixed(1)} МБ';
  }

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
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isUploaded
                            ? [
                                AppColors.success.withValues(alpha: 0.35),
                                AppColors.primary.withValues(alpha: 0.35),
                              ]
                            : [
                                AppColors.bgElevated,
                                AppColors.cardElevated,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(AppDimens.radius12),
                    ),
                    child: Icon(
                      _isUploaded
                          ? Icons.play_arrow_rounded
                          : Icons.videocam_outlined,
                      size: _isUploaded ? 28 : 24,
                      color: _isUploaded
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: AppDimens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Видео-визитка',
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
                                _isUploaded
                                    ? 'Загружено · $_sizeLabel'
                                    : 'Ролик до 1 минуты',
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
                  if (_isUploaded)
                    _CircleAction(
                      icon: Icons.delete_outline_rounded,
                      tint: AppColors.error,
                      tooltip: 'Удалить видео',
                      onTap: onRemove,
                    )
                  else
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
              const SizedBox(height: AppDimens.space12),
              InfoNoteWidget(
                message: _isUploaded
                    ? 'Нажмите на карточку, чтобы перезаписать видео'
                    : 'Расскажите на камеру, кто вы и какие туры водите',
                tone: _isUploaded ? InfoNoteTone.success : InfoNoteTone.info,
                icon: _isUploaded
                    ? Icons.autorenew_rounded
                    : Icons.lightbulb_outline_rounded,
                compact: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleAction({
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
