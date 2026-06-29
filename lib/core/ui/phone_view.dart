import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';

class PhoneView extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? hintText;
  final VoidCallback? onBack;
  final ValueChanged<String> onSubmit;
  final bool isLoading;

  const PhoneView({
    super.key,
    required this.title,
    this.subtitle,
    this.hintText,
    this.onBack,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<PhoneView> createState() => _PhoneViewState();
}

class _PhoneViewState extends State<PhoneView> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late final MaskTextInputFormatter _maskFormatter;
  late final AnimationController _inputFocusController;
  late final AnimationController _progressController;

  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _maskFormatter = MaskTextInputFormatter(
      mask: '+996 (###) ##-##-##',
      filter: {'#': RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );

    _inputFocusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _controller.text = '+996 ';
    _controller.selection = TextSelection.collapsed(offset: 5);

    _focusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      _inputFocusController.forward();
    } else {
      _inputFocusController.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _inputFocusController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  String _getCleanPhone() {
    final digits = _controller.text.replaceAll(RegExp(r'\D'), '');
    return '+$digits';
  }

  bool get _hasFullNumber {
    final digits = _controller.text.replaceAll(RegExp(r'\D'), '');
    return digits.length == 12;
  }

  int get _digitCount {
    return _controller.text.replaceAll(RegExp(r'\D'), '').length;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenPadding.left,
        vertical: AppDimens.screenPadding.top,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          if (widget.onBack != null) ...[
            _buildBackButton(),
            const SizedBox(height: 32),
          ],
          _buildHeaderText(),
          const SizedBox(height: 56),
          _buildPhoneInput(),
          const SizedBox(height: 24),
          _buildProgressIndicator(),
          const SizedBox(height: 48),
          _buildSubmitButton(),
          const SizedBox(height: 20),
          _buildHintText(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: widget.onBack,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: AppTextStyles.headline.copyWith(
            height: 1.1,
            fontSize: 36,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.subtitle!,
            style: AppTextStyles.subtext.copyWith(
              fontSize: 16,
              height: 1.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label с иконкой статуса
        Row(
          children: [
            Text(
              'Номер телефона',
              style: AppTextStyles.subtext.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.3,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            AnimatedOpacity(
              opacity: _hasFullNumber ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: _hasFullNumber
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Готово',
                          style: AppTextStyles.subtext.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Поле ввода
        AnimatedBuilder(
          animation: _inputFocusController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _isFocused
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.phone,
                inputFormatters: [_maskFormatter],
                style: AppTextStyles.title.copyWith(
                  fontSize: 28,
                  letterSpacing: 0.5,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: '+996 (XXX) XX-XX-XX',
                  hintStyle: AppTextStyles.title.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.25),
                    fontSize: 28,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: AppColors.cardDark.withOpacity(0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _hasFullNumber
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.borderDark.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _hasFullNumber
                          ? AppColors.success
                          : AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                ),
                onChanged: (_) => setState(() {}),
                onEditingComplete: () {
                  if (_hasFullNumber) {
                    _submitPhone();
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final progress = (_digitCount - 3) / 9;
    final clampedProgress = progress.clamp(0.0, 1.0);

    if (_digitCount < 4) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Прогресс бар
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: clampedProgress,
            minHeight: 4,
            backgroundColor: AppColors.borderDark.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              _hasFullNumber ? AppColors.success : AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Текст прогресса
        Row(
          children: [
            Text(
              _hasFullNumber
                  ? 'Номер подтвержден'
                  : 'Введите оставшиеся символы',
              style: AppTextStyles.subtext.copyWith(
                fontSize: 12,
                color: _hasFullNumber
                    ? AppColors.success
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '$_digitCount/12',
              style: AppTextStyles.subtext.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return JoluButton(
      text: 'Получить код',
      variant: JoluButtonVariant.primary,
      size: JoluButtonSize.large,
      isFullWidth: true,
      isLoading: widget.isLoading,
      onPressed: _hasFullNumber && !widget.isLoading ? _submitPhone : null,
    );
  }

  void _submitPhone() {
    if (_hasFullNumber) {
      widget.onSubmit(_getCleanPhone());
    }
  }

  Widget _buildHintText() {
    return Center(
      child: Text(
        'Мы отправим SMS с кодом подтверждения',
        style: AppTextStyles.subtext.copyWith(
          fontSize: 13,
          color: AppColors.textSecondary.withOpacity(0.7),
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}