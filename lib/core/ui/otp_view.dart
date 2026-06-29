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

class _OtpViewState extends State<OtpView> {
 final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  
  // Отслеживаем, был ли сброс таймера
  bool _wasResent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNodes[0].requestFocus(),
    );
  }

  @override
  void didUpdateWidget(OtpView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 1. Очищаем поля при неверном коде
    if (widget.invalidAttempt != null &&
        widget.invalidAttempt != oldWidget.invalidAttempt) {
      _clearInputs();
    }
    
    // 2. Очищаем поля при повторной отправке (таймер сброшен)
    // Если canResend изменился с true на false (начался новый таймер)
    if (widget.canResend != oldWidget.canResend && 
        widget.canResend == false &&
        oldWidget.canResend == true) {
      _clearInputs();
      _wasResent = true;
    }
    
    // 3. Если секунды обнулились и canResend стал true - таймер закончился
    if (widget.secondsLeft == 0 && 
        widget.canResend == true &&
        oldWidget.secondsLeft != 0) {
      // Таймер закончился, ничего не делаем
    }
  }

  void _clearInputs() {
    for (var c in _controllers) {
      c.clear();
    }
    // Фокус на первое поле
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  String get _formattedPhone {
    final p = widget.phone;
    if (p.length == 12) {
      return '+${p.substring(0, 3)} (${p.substring(3, 6)}) ${p.substring(6, 8)}-${p.substring(8, 10)}-${p.substring(10)}';
    }
    return widget.phone;
  }

  String get _code => _controllers.map((c) => c.text).join();
  bool get _isCodeComplete => _code.length == 4;

  void _verifyCode() {
    if (_isCodeComplete && !widget.isLoading) {
      widget.onVerify(_code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          if (widget.onBack != null) ...[
            _buildBackButton(),
            const SizedBox(height: AppDimens.space32),
          ],
          _buildHeaderText(),
          const SizedBox(height: AppDimens.space32 * 1.5),
          _buildOtpInputs(),
          const SizedBox(height: AppDimens.space32),
          _buildTimerSection(),
          const SizedBox(height: AppDimens.space32 * 2),
          _buildSubmitButton(),
          const SizedBox(height: AppDimens.space24),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: widget.onBack,
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

  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Подтверждение',
          style: AppTextStyles.headline.copyWith(height: 1.2),
        ),
        const SizedBox(height: AppDimens.space12),
        RichText(
          text: TextSpan(
            text: 'Код отправлен на номер ',
            style: AppTextStyles.subtext,
            children: [
              TextSpan(
                text: _formattedPhone,
                style: AppTextStyles.subtext.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (widget.invalidAttempt != null) ...[
          const SizedBox(height: AppDimens.space12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Неверный код. Попробуйте снова. Осталось попыток: ${4 - (widget.invalidAttempt ?? 0)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOtpInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: _OtpInputField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            isLast: index == 3,
            onCompleted: _verifyCode,
            hasError: widget.invalidAttempt != null,
          ),
        );
      }),
    );
  }

  Widget _buildTimerSection() {
    return Center(
      child: widget.canResend
          ? TextButton(
              onPressed: widget.isLoading ? null : widget.onResend,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.space16,
                  vertical: AppDimens.space12,
                ),
              ),
              child: Text(
                'Отправить код повторно',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : Column(
              children: [
                Text(
                  'Повторить отправку через',
                  style: AppTextStyles.subtext.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(AppDimens.radiusRound),
                  ),
                  child: Text(
                    '00:${widget.secondsLeft.toString().padLeft(2, '0')}',
                    style: AppTextStyles.title.copyWith(
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSubmitButton() {
    return JoluButton(
      text: 'Войти',
      variant: JoluButtonVariant.primary,
      size: JoluButtonSize.large,
      isFullWidth: true,
      isLoading: widget.isLoading,
      onPressed: _isCodeComplete && !widget.isLoading ? _verifyCode : null,
    );
  }
}

class _OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLast;
  final VoidCallback onCompleted;
  final bool hasError;

  const _OtpInputField({
    required this.controller,
    required this.focusNode,
    required this.isLast,
    required this.onCompleted,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 64,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: AppTextStyles.headline.copyWith(fontSize: 28),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.cardDark,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            borderSide: BorderSide(color: AppColors.borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            borderSide: BorderSide(
              color: hasError ? Colors.red : AppColors.primary,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            borderSide: BorderSide(
              color: hasError ? Colors.red : AppColors.borderDark,
              width: hasError ? 2 : 1,
            ),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (isLast) {
              focusNode.unfocus();
              onCompleted();
            } else {
              FocusScope.of(context).nextFocus();
            }
          }
        },
      ),
    );
  }
}
