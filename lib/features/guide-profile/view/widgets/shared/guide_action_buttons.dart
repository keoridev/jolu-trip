import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/buttons/jolu_button.dart';

class GuideActionButtons extends StatelessWidget {
  final bool isVerified;
  final VoidCallback? onCreateTour;
  final VoidCallback? onMyTours;
  final VoidCallback? onReuploadDocs;

  const GuideActionButtons({
    super.key,
    required this.isVerified,
    this.onCreateTour,
    this.onMyTours,
    this.onReuploadDocs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ Кнопка "Создать тур" — ВСЕГДА активна, без проверки verified
        JoluButton(
          text: 'Создать тур',
          trailingIcon: Icons.add_circle_outline,
          onPressed: onCreateTour, // ✅ Просто вызываем колбэк
        ),
        const SizedBox(height: AppDimens.space16),

        // Кнопка "Мои туры" — всегда активна
        JoluButton(
          text: 'Мои туры',
          variant: JoluButtonVariant.outline,
          trailingIcon: Icons.list_alt,
          onPressed: onMyTours,
        ),
        const SizedBox(height: AppDimens.space16),

        // Кнопка "Перезагрузить документы" — только если rejected
        if (onReuploadDocs != null) ...[
          JoluButton(
            text: 'Перезагрузить документы',
            variant: JoluButtonVariant.outline,
            trailingIcon: Icons.upload_file,
            onPressed: onReuploadDocs,
          ),
          const SizedBox(height: AppDimens.space16),
        ],
      ],
    );
  }
}
