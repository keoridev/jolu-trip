import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class CreateTourAppBar extends StatelessWidget {
  final int currentStep;
  final VoidCallback onBack;

  const CreateTourAppBar({
    super.key,
    required this.currentStep,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space20,
          vertical: AppDimens.space12,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: AppDimens.space8),
            Expanded(
              child: Text(
                'Создание тура',
                style: AppTextStyles.headline,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 48), // Баланс
          ],
        ),
      ),
    );
  }
}