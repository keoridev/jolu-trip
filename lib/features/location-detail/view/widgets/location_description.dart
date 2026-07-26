import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';

import 'location_section.dart';

/// «О локации» + снаряжение + особенности дороги.
class LocationDescription extends StatelessWidget {
  final LocationDetailEntity location;

  const LocationDescription({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (location.description.isNotEmpty)
          LocationSection(
            title: 'О локации',
            child: _ExpandableText(text: location.description),
          ),

        if (location.gearList.isNotEmpty)
          LocationSection(
            title: 'Что взять с собой',
            subtitle: '${location.gearList.length} пунктов в списке',
            child: Wrap(
              spacing: AppDimens.space8,
              runSpacing: AppDimens.space8,
              children: location.gearList
                  .map((item) => _GearChip(label: item))
                  .toList(),
            ),
          ),

        if (location.roadFeatures.isNotEmpty)
          LocationSection(
            title: 'Особенности дороги',
            subtitle: 'Прочитайте до выезда',
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
                vertical: AppDimens.space4,
              ),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < location.roadFeatures.length; i++) ...[
                    if (i > 0)
                      const Divider(height: 1, color: AppColors.borderSoft),
                    _RoadFeatureRow(feature: location.roadFeatures[i]),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Длинное описание сворачивается: раньше портянка на 15 строк отодвигала
/// карту и остановки далеко за пределы первого экрана.
class _ExpandableText extends StatefulWidget {
  static const int collapsedLines = 5;

  final String text;

  const _ExpandableText({required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const style = AppTextStyles.body;

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: _ExpandableText.collapsedLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Text(
                widget.text,
                style: style.copyWith(color: AppColors.textSecondary),
                maxLines: _expanded ? null : _ExpandableText.collapsedLines,
                overflow: _expanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
            ),
            if (isOverflowing)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimens.space8,
                    ),
                    minimumSize: const Size(0, 40),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.primaryBright,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _expanded ? 'Свернуть' : 'Читать полностью',
                        style: AppTextStyles.accentBadge.copyWith(fontSize: 13),
                      ),
                      const SizedBox(width: AppDimens.space4),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primaryBright,
                        size: AppDimens.icon20,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GearChip extends StatelessWidget {
  final String label;

  const _GearChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space12,
        vertical: AppDimens.space8,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(AppDimens.radiusRound),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_rounded,
            size: AppDimens.icon16,
            color: AppColors.primaryBright,
          ),
          const SizedBox(width: AppDimens.space6),
          // Flexible обязателен: Wrap отдаёт ребёнку всю ширину строки как
          // максимум, и длинный пункт вроде «Канистра с топливом на 20 л»
          // переполнял чип по горизонтали.
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadFeatureRow extends StatelessWidget {
  final String feature;

  const _RoadFeatureRow({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7, right: AppDimens.space12),
            decoration: const BoxDecoration(
              color: AppColors.primaryBright,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              feature,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
