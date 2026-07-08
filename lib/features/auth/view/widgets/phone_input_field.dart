
import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/buttons/jolu_back_button.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';

class PhoneView extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onBack;
  final ValueChanged<String> onSubmit;
  final bool isLoading;
  final bool showBackButton;
  final bool showHint;

  const PhoneView({
    super.key,
    required this.title,
    this.subtitle,
    this.buttonText = 'Получить код',
    this.onBack,
    required this.onSubmit,
    this.isLoading = false,
    this.showBackButton = true,
    this.showHint = true,
  });

  @override
  State<PhoneView> createState() => _PhoneViewState();
}

class _PhoneViewState extends State<PhoneView> {
  final PhoneInputFieldController _phoneController =
      PhoneInputFieldController();
  bool _isValid = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.showBackButton && widget.onBack != null
            ? AppBackButton(
                onPressed: widget.onBack!,
                style: BackButtonStyle.iconOnly,
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Text(
                widget.title,
                style: AppTextStyles.headline.copyWith(fontSize: 32),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: AppDimens.space8),
                Text(widget.subtitle!, style: AppTextStyles.subtext),
              ],
              const SizedBox(height: AppDimens.space48),

              // Поле ввода телефона
              PhoneInputField(
                controller: _phoneController.controller,
                focusNode: _phoneController.focusNode,
                autoFocus: true,
                hintText: '700 000 000',
                onValidityChanged: (isValid) {
                  setState(() => _isValid = isValid);
                },
                onSubmitted: () {
                  if (_isValid && !widget.isLoading) {
                    _submitPhone();
                  }
                },
              ),

              if (widget.showHint) ...[
                const SizedBox(height: AppDimens.space8),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Введите 9 цифр после +996',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppDimens.space24),

              // Кнопка с анимацией
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isValid
                    ? JoluButton(
                        key: const ValueKey('submit_button'),
                        text: widget.buttonText!,
                        variant: JoluButtonVariant.primary,
                        size: JoluButtonSize.large,
                        isFullWidth: true,
                        isLoading: widget.isLoading,
                        onPressed: _submitPhone,
                      )
                    : Container(
                        key: const ValueKey('disabled_button'),
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.borderDark,
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusM,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Введите номер',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: AppDimens.space16),
              Center(
                child: Text(
                  'Мы отправим SMS с кодом подтверждения',
                  style: AppTextStyles.subtext.copyWith(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitPhone() {
    if (_isValid && !widget.isLoading) {
      widget.onSubmit(_phoneController.rawPhone);
    }
  }
}
