import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class BlockTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const BlockTitle({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: AppDimens.space16),
        Text(
          title,
          style: AppTextStyles.headline.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
