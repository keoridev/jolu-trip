import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';


class AuthShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget child;

  const AuthShell({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          if (onBack != null) ...[
            _BackButton(onTap: onBack!),
            const SizedBox(height: AppDimens.space32),
          ],
          _HeaderText(title: title, subtitle: subtitle),
          const SizedBox(height: AppDimens.space32 * 1.5),
          child,
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space8),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _HeaderText({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headline.copyWith(height: 1.2)),
        if (subtitle != null) ...[
          const SizedBox(height: AppDimens.space12),
          Text(subtitle!, style: AppTextStyles.subtext),
        ],
      ],
    );
  }
}
