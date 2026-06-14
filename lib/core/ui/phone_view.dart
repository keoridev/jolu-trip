import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _PhoneViewState extends State<PhoneView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller.text = '+996 ';
    _controller.selection = TextSelection.fromPosition(
      const TextPosition(offset: 5),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _getCleanPhone() {
    final digits = _controller.text.replaceAll(RegExp(r'\D'), '');
    return digits.startsWith('996') ? '+$digits' : '+996$digits';
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
            const SizedBox(height: AppDimens.spaceXL),
          ],
          _buildHeaderText(),
          const SizedBox(height: AppDimens.spaceXL * 2),
          _buildPhoneInput(),
          const SizedBox(height: AppDimens.spaceXL * 2),
          _buildSubmitButton(),
          const SizedBox(height: AppDimens.spaceL),
          _buildHintText(),
          const SizedBox(height: AppDimens.spaceXL),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: widget.onBack,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.spaceXS),
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
          widget.title,
          style: AppTextStyles.headline.copyWith(height: 1.2, fontSize: 32),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: AppDimens.spaceS),
          Text(
            widget.subtitle!,
            style: AppTextStyles.subtext.copyWith(fontSize: 15, height: 1.4),
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Номер телефона',
          style: AppTextStyles.subtext.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppDimens.spaceS),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.phone,
          style: AppTextStyles.title.copyWith(
            fontSize: 24,
            letterSpacing: 1,
            color: AppColors.textPrimary,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          decoration: InputDecoration(
            hintText: widget.hintText ?? '+996 (XXX) XX-XX-XX',
            hintStyle: AppTextStyles.title.copyWith(
              color: AppColors.textSecondary.withOpacity(0.3),
              fontSize: 24,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderDark, width: 1.5),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onChanged: (value) {
            final digits = value.replaceAll(RegExp(r'\D'), '');
            setState(() => _isValid = digits.length == 12);
          },
        ),
        if (!_isValid && _controller.text.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.spaceS),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Введите полный номер: +996 XXX XX-XX-XX',
                    style: AppTextStyles.subtext.copyWith(
                      color: AppColors.warning,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
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
      onPressed: _isValid && !widget.isLoading
          ? () => widget.onSubmit(_getCleanPhone())
          : null,
    );
  }

  Widget _buildHintText() {
    return Center(
      child: Text(
        'Мы отправим SMS с кодом подтверждения',
        style: AppTextStyles.subtext.copyWith(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}
