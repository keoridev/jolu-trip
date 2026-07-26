import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

enum InfoNoteTone { info, warning, success, danger }

/// Небольшая тонированная плашка-подсказка.
///
/// Заменяет четыре почти одинаковых inline-контейнера, которые раньше жили
/// в карточках документов, видео и на шагах 2–3.
class InfoNoteWidget extends StatelessWidget {
  final String message;
  final InfoNoteTone tone;
  final IconData? icon;

  /// Компактный режим — для подсказок внутри карточек.
  final bool compact;

  const InfoNoteWidget({
    super.key,
    required this.message,
    this.tone = InfoNoteTone.info,
    this.icon,
    this.compact = false,
  });

  Color get _tint => switch (tone) {
    InfoNoteTone.info => AppColors.accent,
    InfoNoteTone.warning => AppColors.warning,
    InfoNoteTone.success => AppColors.success,
    InfoNoteTone.danger => AppColors.error,
  };

  IconData get _icon =>
      icon ??
      switch (tone) {
        InfoNoteTone.info => Icons.info_outline_rounded,
        InfoNoteTone.warning => Icons.warning_amber_rounded,
        InfoNoteTone.success => Icons.check_circle_outline_rounded,
        InfoNoteTone.danger => Icons.error_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final tint = _tint;

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(
              horizontal: AppDimens.space10,
              vertical: AppDimens.space8,
            )
          : const EdgeInsets.all(AppDimens.space14),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        border: Border.all(color: tint.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, size: compact ? 15 : 18, color: tint),
          SizedBox(width: compact ? AppDimens.space8 : AppDimens.space12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: tint,
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
