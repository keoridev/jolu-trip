import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/ui/buttons/jolu_button.dart';

class CreateTourBottomNav extends StatelessWidget {
  final int currentStep;
  final bool isLoading;
  final bool canSubmit;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const CreateTourBottomNav({
    super.key,
    required this.currentStep,
    required this.isLoading,
    required this.canSubmit,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimens.space20,
        right: AppDimens.space20,
        bottom: MediaQuery.of(context).padding.bottom + AppDimens.space16,
        top: AppDimens.space16,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        border: Border(top: BorderSide(color: AppColors.borderDark)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (currentStep > 0) ...[
              Expanded(
                child: JoluButton(
                  text: 'Назад',
                  variant: JoluButtonVariant.outline,
                  onPressed: onPrev,
                ),
              ),
              const SizedBox(width: AppDimens.space12),
            ],
            Expanded(
              flex: currentStep > 0 ? 2 : 1,
              child: JoluButton(
                text: currentStep == 2 ? 'Создать тур' : 'Далее',
                isLoading: isLoading,
                onPressed: isLoading ? null : onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}