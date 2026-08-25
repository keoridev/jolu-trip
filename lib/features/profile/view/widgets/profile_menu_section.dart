import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class ProfileMenuSection extends StatelessWidget {
  final String title;
  final Color themeColor;
  final List<Widget> children;

  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.themeColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppDimens.space10),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.accentBadge.copyWith(
                  color: themeColor,
                  letterSpacing: 0.8,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppDimens.radius16),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(children: _divideWithBorders(children)),
        ),
      ],
    );
  }

  List<Widget> _divideWithBorders(List<Widget> children) {
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(
          Padding(
            padding: const EdgeInsets.only(left: 68),
            child: Divider(height: 1, color: AppColors.borderSoft),
          ),
        );
      }
    }
    return result;
  }
}
