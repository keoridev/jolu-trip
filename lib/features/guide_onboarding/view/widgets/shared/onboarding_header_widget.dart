import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/progress_bar_widget.dart';

/// Шапка анкеты: кнопка выхода, счётчик шагов, индикатор прогресса и
/// заголовок текущего шага.
///
/// Заголовок живёт здесь, а не внутри шагов — так он не уезжает при скролле
/// и гид всегда видит, где он находится.
class OnboardingHeaderWidget extends StatelessWidget {
  final int currentPage;
  final int stepCount;
  final String title;
  final String subtitle;
  final VoidCallback onClose;

  const OnboardingHeaderWidget({
    super.key,
    required this.currentPage,
    required this.stepCount,
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space12,
        AppDimens.space16,
        AppDimens.space20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CloseButton(onTap: onClose),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.space12,
                  vertical: AppDimens.space6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardElevated,
                  borderRadius: BorderRadius.circular(AppDimens.radiusRound),
                ),
                child: Text(
                  'Шаг ${currentPage + 1} из $stepCount',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space20),

          ProgressBarWidget(currentPage: currentPage),
          const SizedBox(height: AppDimens.space24),

          // Заголовок мягко подменяется при смене шага, чтобы переход
          // не выглядел как резкий скачок текста.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.12),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Column(
              key: ValueKey<int>(currentPage),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headline),
                const SizedBox(height: AppDimens.space6),
                Text(
                  subtitle,
                  style: AppTextStyles.subtext.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusRound),
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: AppColors.cardElevated,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 19,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
