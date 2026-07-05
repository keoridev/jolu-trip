import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';

class OtpView extends StatefulWidget {
  final String phone;
  final VoidCallback? onBack;
  final ValueChanged<String> onVerify;
  final VoidCallback onResend;
  final int? invalidAttempt;
  final bool isLoading;
  final int secondsLeft;
  final bool canResend;

  const OtpView({
    super.key,
    required this.phone,
    this.onBack,
    required this.onVerify,
    required this.onResend,
    this.invalidAttempt,
    this.isLoading = false,
    this.secondsLeft = 59,
    this.canResend = false,
  });

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(OtpView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Тряска при ошибке
    if (widget.invalidAttempt != null && widget.invalidAttempt != oldWidget.invalidAttempt) {
      _shakeController.forward(from: 0.0);
      _clearInputs();
    }
    // Сброс при повторной отправке
    if (widget.canResend != oldWidget.canResend && widget.canResend == false && oldWidget.canResend == true) {
      _clearInputs();
    }
  }

  void _clearInputs() {
    for (var c in _controllers) {
      c.clear();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  String get _code => _controllers.map((c) => c.text).join();
  bool get _isCodeComplete => _code.length == 4;

  void _verifyCode() {
    if (_isCodeComplete && !widget.isLoading) {
      widget.onVerify(_code);
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                onPressed: widget.onBack,
              )
            : null,
        title: Text(
          widget.phone,
          style: AppTextStyles.subtext.copyWith(
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Введите код',
                style: AppTextStyles.headline.copyWith(fontSize: 32),
              ),
              const SizedBox(height: AppDimens.space8),
              Text(
                'Мы отправили SMS с кодом на ваш номер',
                style: AppTextStyles.subtext,
              ),
              const SizedBox(height: AppDimens.space48),
              // Поля ввода кода
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _shakeController.value * 20 * (1 - _shakeController.value),
                      0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        final hasError = widget.invalidAttempt != null;
                        return SizedBox(
                          width: 60,
                          height: 80,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: AppTextStyles.headline.copyWith(fontSize: 32),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: AppColors.cardDark,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                                borderSide: BorderSide(color: AppColors.borderDark),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                                borderSide: BorderSide(
                                  color: hasError ? AppColors.error : AppColors.borderDark,
                                  width: hasError ? 2 : 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                                borderSide: BorderSide(
                                  color: hasError ? AppColors.error : AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                if (index == 3) {
                                  _focusNodes[index].unfocus();
                                  if (_isCodeComplete) _verifyCode();
                                } else {
                                  FocusScope.of(context).nextFocus();
                                }
                              }
                              setState(() {});
                            },
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
              if (widget.invalidAttempt != null) ...[
                const SizedBox(height: AppDimens.space16),
                Center(
                  child: Text(
                    'Неверный код. Осталось попыток: ${4 - (widget.invalidAttempt ?? 0)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppDimens.space48),
              // Кнопка подтверждения
              JoluButton(
                text: 'Подтвердить код',
                variant: JoluButtonVariant.primary,
                size: JoluButtonSize.large,
                isFullWidth: true,
                isLoading: widget.isLoading,
                onPressed: _isCodeComplete && !widget.isLoading ? _verifyCode : null,
              ),
              const SizedBox(height: AppDimens.space16),
              // Таймер / Повторная отправка
              Center(
                child: widget.canResend
                    ? TextButton(
                        onPressed: widget.isLoading ? null : widget.onResend,
                        child: Text(
                          'Запросить код повторно',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : Text(
                        'Запросить код повторно через ${widget.secondsLeft} сек',
                        style: AppTextStyles.subtext.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}