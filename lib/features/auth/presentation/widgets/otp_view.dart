import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/auth/bloc/auth_cubit.dart';
import 'package:jolutrip_app/features/auth/bloc/auth_state.dart';
import 'package:jolutrip_app/features/auth/presentation/widgets/otp_input_field.dart';

class OtpView extends StatefulWidget {
  final String phone;

  const OtpView({super.key, required this.phone});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  Timer? _timer;
  int _secondsLeft = 59;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNodes[0].requestFocus(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = 59;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsLeft--);
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
    if (_isCodeComplete) {
      context.read<AuthCubit>().verifyOtp(widget.phone, _code);
    }
  }

  void _resendCode() {
    context.read<AuthCubit>().sendOtp(widget.phone);
    _startTimer();
    for (var c in _controllers) c.clear();
    _focusNodes[0].requestFocus();
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
          _buildBackButton(),
          const SizedBox(height: AppDimens.spaceXL),
          _buildHeaderText(),
          const SizedBox(height: AppDimens.spaceXL * 1.5),
          _buildOtpInputs(),
          const SizedBox(height: AppDimens.spaceXL),
          _buildTimerSection(),
          const SizedBox(height: AppDimens.spaceXL * 2),
          _buildSubmitButton(isLoading),
          const SizedBox(height: AppDimens.spaceL),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => context.read<AuthCubit>().reset(),
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
          'Подтверждение',
          style: AppTextStyles.headline.copyWith(height: 1.2),
        ),
        const SizedBox(height: AppDimens.spaceS),
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
      ],
    );
  }

  Widget _buildOtpInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: OtpInputField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            index: index,
            isLast: index == 3,
            onCompleted: _verifyCode,
          ),
        );
      }),
    );
  }

  Widget _buildTimerSection() {
    return Center(
      child: _canResend
          ? TextButton(
              onPressed: _resendCode,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.spaceM,
                  vertical: AppDimens.spaceS,
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
                    '00:${_secondsLeft.toString().padLeft(2, '0')}',
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

  Widget _buildSubmitButton(bool isLoading) {
    return JoluButton(
      text: 'Войти',
      variant: JoluButtonVariant.primary,
      size: JoluButtonSize.large,
      isFullWidth: true,
      isLoading: isLoading,
      onPressed: _isCodeComplete && !isLoading ? _verifyCode : null,
    );
  }
}
