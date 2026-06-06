// lib/features/auth/presentation/widgets/phone_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/auth/bloc/auth_cubit.dart';
import 'package:jolutrip_app/features/auth/bloc/auth_state.dart';
import 'package:jolutrip_app/features/auth/presentation/widgets/phone_input_field.dart';

class PhoneView extends StatefulWidget {
  const PhoneView({super.key});

  @override
  State<PhoneView> createState() => _PhoneViewState();
}

class _PhoneViewState extends State<PhoneView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isValid = false;

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
    final isLoading = context.watch<AuthCubit>().state is AuthLoading;

    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          _buildLogo(),
          const SizedBox(height: AppDimens.spaceXL),
          _buildHeaderText(),
          const SizedBox(height: AppDimens.spaceXL * 2),
          _buildPhoneInput(),
          const SizedBox(height: AppDimens.spaceXL * 2),
          _buildSubmitButton(isLoading),
          const SizedBox(height: AppDimens.spaceL),
          _buildHintText(),
          const SizedBox(height: AppDimens.spaceXL),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: const Center(
        child: Icon(Icons.explore_rounded, color: Colors.black, size: 28),
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Добро пожаловать\nв JoLuTrip',
          style: AppTextStyles.headline.copyWith(height: 1.2, fontSize: 32),
        ),
        const SizedBox(height: AppDimens.spaceS),
        Text(
          'Войдите, чтобы исследовать горы\nКыргызстана',
          style: AppTextStyles.subtext.copyWith(fontSize: 15, height: 1.4),
        ),
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
        PhoneInputField(
          controller: _controller,
          focusNode: _focusNode,
          onPhoneChanged: (value) {
            final digits = value.replaceAll(RegExp(r'\D'), '');
            setState(() => _isValid = digits.length == 12);
          },
        ),
        if (!_isValid && _controller.text.isNotEmpty)
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

  Widget _buildSubmitButton(bool isLoading) {
    return JoluButton(
      text: 'Получить код',
      variant: JoluButtonVariant.primary,
      size: JoluButtonSize.large,
      isFullWidth: true,
      isLoading: isLoading,
      onPressed: _isValid && !isLoading
          ? () => context.read<AuthCubit>().sendOtp(_getCleanPhone())
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
