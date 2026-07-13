import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _OtpViewState extends State<OtpView> with TickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  
  late final AnimationController _errorShakeController;

  @override
  void initState() {
    super.initState();
    
    _errorShakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNodes[0].requestFocus(),
    );
  }

  @override
  void didUpdateWidget(OtpView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.invalidAttempt != null &&
        widget.invalidAttempt != oldWidget.invalidAttempt) {
      _clearInputs();
      _triggerErrorShake();
    }
    
    if (widget.canResend != oldWidget.canResend && 
        widget.canResend == false &&
        oldWidget.canResend == true) {
      _clearInputs();
    }
  }

  void _triggerErrorShake() {
    _errorShakeController.forward().then((_) => _errorShakeController.reverse());
  }

  void _clearInputs() {
    for (var c in _controllers) {
      c.clear();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
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

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty) {
      HapticFeedback.lightImpact();
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        Future.delayed(const Duration(milliseconds: 150), _verifyCode);
      }
    }
  }

  void _onDigitRemoved(int index) {
    if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    _errorShakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppDimens.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (widget.onBack != null) ...[
              _buildBackButton(),
              const SizedBox(height: 24),
            ],
            _buildHeaderText(),
            const Spacer(flex: 2),
            _buildOtpInputs(),
            const SizedBox(height: 32),
            _buildTimerSection(),
            const Spacer(flex: 3),
            _buildSubmitButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return JoluIconButton(
      icon: Icons.arrow_back_rounded,
      onPressed: widget.onBack,
      variant: JoluIconButtonVariant.secondary,
      size: 40,
      iconSize: 20,
    );
  }

  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Подтверждение',
          style: AppTextStyles.headline.copyWith(
            fontSize: 28,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            text: 'Код отправлен на ',
            style: AppTextStyles.subtext.copyWith(fontSize: 15),
            children: [
              TextSpan(
                text: _formattedPhone,
                style: AppTextStyles.subtext.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        if (widget.invalidAttempt != null) ...[
          const SizedBox(height: 16),
          _buildErrorBanner(),
        ],
      ],
    );
  }

  Widget _buildErrorBanner() {
    return AnimatedBuilder(
      animation: _errorShakeController,
      builder: (context, child) {
        final offset = sin(_errorShakeController.value * pi * 4) * 6;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Неверный код. Осталось попыток: ${4 - (widget.invalidAttempt ?? 0)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpInputs() {
    return AnimatedBuilder(
      animation: _errorShakeController,
      builder: (context, child) {
        final offset = sin(_errorShakeController.value * pi * 4) * 4;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _OtpInputField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              isLast: index == 3,
              hasError: widget.invalidAttempt != null,
              onChanged: (value) => _onDigitEntered(index, value),
              onDeleted: () => _onDigitRemoved(index),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimerSection() {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: widget.canResend
            ? TextButton(
                key: const ValueKey('resend'),
                onPressed: widget.isLoading ? null : widget.onResend,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Отправить код повторно',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              )
            : Text(
                key: const ValueKey('timer'),
                'Повторная отправка через ${widget.secondsLeft} сек',
                style: AppTextStyles.subtext.copyWith(
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
              ),
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

class _OtpInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLast;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final VoidCallback onDeleted;

  const _OtpInputField({
    required this.controller,
    required this.focusNode,
    required this.isLast,
    required this.hasError,
    required this.onChanged,
    required this.onDeleted,
  });

  @override
  State<_OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<_OtpInputField> with SingleTickerProviderStateMixin {
  late final AnimationController _focusAnimationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _focusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _focusAnimationController,
        curve: Curves.easeOut,
      ),
    );
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (widget.focusNode.hasFocus) {
      _focusAnimationController.forward();
    } else {
      _focusAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _focusAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: SizedBox(
        width: 52,
        height: 60,
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: AppTextStyles.headline.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: widget.focusNode.hasFocus 
                ? AppColors.cardElevated 
                : AppColors.cardDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide(
                color: widget.hasError 
                    ? AppColors.error.withValues(alpha: 0.5)
                    : AppColors.borderDark,
                width: widget.hasError ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide(
                color: widget.hasError ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
          onChanged: (value) {
            if (value.isEmpty) {
              widget.onDeleted();
            } else {
              widget.onChanged(value);
            }
          },
        ),
      ),
    );
  }
}