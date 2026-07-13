import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class CreateTourStepIndicator extends StatelessWidget {
  final int currentStep;

  const CreateTourStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.screenPadding,
      child: Row(
        children: [
          _StepDot(step: 0, label: 'Основное', currentStep: currentStep),
          _StepLine(step: 0, currentStep: currentStep),
          _StepDot(step: 1, label: 'Детали', currentStep: currentStep),
          _StepLine(step: 1, currentStep: currentStep),
          _StepDot(step: 2, label: 'Маршрут', currentStep: currentStep),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int step;
  final String label;
  final int currentStep;

  const _StepDot({
    required this.step,
    required this.label,
    required this.currentStep,
  });

  bool get isActive => step <= currentStep;
  bool get isCurrent => step == currentStep;
  bool get isCompleted => isActive && step < currentStep;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.cardDark,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isCurrent
                  ? AppColors.primary
                  : isActive
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final int step;
  final int currentStep;

  const _StepLine({required this.step, required this.currentStep});

  bool get isActive => step < currentStep;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24),
        color: isActive
            ? AppColors.primary
            : AppColors.textSecondary.withValues(alpha: 0.2),
      ),
    );
  }
}
