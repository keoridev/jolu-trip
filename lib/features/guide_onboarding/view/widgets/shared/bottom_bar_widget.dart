import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';

class BottomBarWidget extends StatelessWidget {
  final int currentPage;
  final bool isLoading;
  final bool canProceed;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const BottomBarWidget({
    super.key,
    required this.currentPage,
    required this.isLoading,
    required this.canProceed,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimens.screenPadding,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        border: Border(top: BorderSide(color: AppColors.borderDark)),
      ),
      child: Row(
        children: [
          if (currentPage > 0)
            Expanded(
              child: JoluButton(
                text: 'Назад',
                variant: JoluButtonVariant.outline,
                onPressed: onBack,
              ),
            ),
          if (currentPage > 0) const SizedBox(width: AppDimens.space16),
          Expanded(
            flex: currentPage > 0 ? 1 : 2,
            child: JoluButton(
              text: currentPage == 2 ? 'Отправить' : 'Далее',
              variant: JoluButtonVariant.primary,
              isLoading: isLoading,
              onPressed: canProceed ? onNext : null,
            ),
          ),
        ],
      ),
    );
  }
}
