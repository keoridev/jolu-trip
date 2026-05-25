import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/auth/bloc/auth_cubit.dart';
import 'package:jolutrip_app/features/auth/bloc/auth_state.dart';
import 'package:jolutrip_app/features/auth/presentation/widgets/widgets.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: AnimatedBackground(
        child: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                context.go('/reels');
              }
              if (state is AuthError) {
                _showErrorSnackBar(context, state.message);
              }
            },
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: state is AuthOtpSent
                    ? _OtpView(phone: state.phone)
                    : const _PhoneView(),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: AppTextStyles.body)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
        margin: AppDimens.screenPadding,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// ВВОД ТЕЛЕФОНА
// ═══════════════════════════════════════════════════
class _PhoneView extends StatefulWidget {
  const _PhoneView();

  @override
  State<_PhoneView> createState() => _PhoneViewState();
}

class _PhoneViewState extends State<_PhoneView> {
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
    if (digits.startsWith('996')) {
      return '+$digits';
    }
    return '+996$digits';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;
    final isLoading = state is AuthLoading;

    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),

          // Hero анимация для лого
          Hero(
            tag: 'logo',
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
              child: const Center(
                child: Icon(
                  Icons.explore_rounded,
                  color: Colors.black,
                  size: 32,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimens.spaceXL),

          Text(
            'Добро пожаловать\nв JoLuTrip',
            style: AppTextStyles.headline.copyWith(height: 1.2, fontSize: 32),
          ),

          const SizedBox(height: AppDimens.spaceS),

          Text(
            'Войдите, чтобы исследовать горы\nКыргызстана',
            style: AppTextStyles.subtext.copyWith(fontSize: 15, height: 1.4),
          ),

          const SizedBox(height: AppDimens.spaceXL * 2),

          // Поле ввода телефона
          Column(
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
                  setState(() {
                    _isValid = digits.length == 12;
                  });
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
          ),

          const SizedBox(height: AppDimens.spaceXL * 2),

          // Кнопка
          GradientButton(
            onPressed: _isValid && !isLoading
                ? () {
                    final cleanPhone = _getCleanPhone();
                    debugPrint('📞 Отправка номера: $cleanPhone');
                    context.read<AuthCubit>().sendOtp(cleanPhone);
                  }
                : null,
            text: 'Получить код',
            isLoading: isLoading,
          ),

          const SizedBox(height: AppDimens.spaceL),

          // Подсказка
          Center(
            child: Text(
              'Мы отправим SMS с кодом подтверждения',
              style: AppTextStyles.subtext.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: AppDimens.spaceXL),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// ВВОД OTP КОДА
// ═══════════════════════════════════════════════════
class _OtpView extends StatefulWidget {
  final String phone;

  const _OtpView({required this.phone});

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;
    final isLoading = state is AuthLoading;

    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),

          // Кнопка назад
          GestureDetector(
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
          ),

          const SizedBox(height: AppDimens.spaceXL),

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

          const SizedBox(height: AppDimens.spaceXL * 1.5),

          // Поля ввода кода
          Row(
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
          ),

          const SizedBox(height: AppDimens.spaceXL),

          // Таймер / кнопка повторной отправки
          Center(
            child: _canResend
                ? TextButton(
                    onPressed: () {
                      context.read<AuthCubit>().sendOtp(widget.phone);
                      _startTimer();
                      for (var c in _controllers) {
                        c.clear();
                      }
                      _focusNodes[0].requestFocus();
                    },
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
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusRound,
                          ),
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
          ),

          const SizedBox(height: AppDimens.spaceXL * 2),

          // Кнопка входа
          GradientButton(
            onPressed: _isCodeComplete && !isLoading ? _verifyCode : null,
            text: 'Войти',
            isLoading: isLoading,
            isDisabled: !_isCodeComplete,
          ),

          const SizedBox(height: AppDimens.spaceL),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}
