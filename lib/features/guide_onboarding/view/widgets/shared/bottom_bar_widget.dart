import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';

class BottomBarWidget extends StatelessWidget {
  final int currentPage;
  final int lastPage;
  final bool isLoading;
  final bool canProceed;

  /// Почему кнопка «Далее» недоступна. Показывается над кнопками, чтобы гид
  /// не гадал, чего ещё не хватает.
  final String? blockedReason;

  final VoidCallback onBack;
  final VoidCallback onNext;

  const BottomBarWidget({
    super.key,
    required this.currentPage,
    required this.lastPage,
    required this.isLoading,
    required this.canProceed,
    required this.onBack,
    required this.onNext,
    this.blockedReason,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == lastPage;
    final showBack = currentPage > 0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardDark,
        border: Border(top: BorderSide(color: AppColors.borderDark)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.space16,
            AppDimens.space16,
            AppDimens.space16,
            AppDimens.space12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: (!canProceed && blockedReason != null && !isLoading)
                    ? Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimens.space12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 15,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: AppDimens.space8),
                            Expanded(
                              child: Text(
                                blockedReason!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
              Row(
                children: [
                  if (showBack) ...[
                    Expanded(
                      child: JoluButton(
                        text: 'Назад',
                        variant: JoluButtonVariant.outline,
                        size: JoluButtonSize.large,
                        leadingIcon: Icons.arrow_back_rounded,
                        onPressed: isLoading ? null : onBack,
                      ),
                    ),
                    const SizedBox(width: AppDimens.space12),
                  ],
                  Expanded(
                    flex: showBack ? 1 : 2,
                    child: JoluButton(
                      text: isLast ? 'Отправить' : 'Далее',
                      variant: JoluButtonVariant.primary,
                      size: JoluButtonSize.large,
                      trailingIcon: isLast
                          ? Icons.send_rounded
                          : Icons.arrow_forward_rounded,
                      isLoading: isLoading,
                      onPressed: canProceed ? onNext : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
