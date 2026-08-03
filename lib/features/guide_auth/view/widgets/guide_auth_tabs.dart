import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/buttons/jolu_back_button.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';

class GuideAuthTabs extends StatefulWidget {
  final bool isLogin;
  final bool isLoading;
  final ValueChanged<bool> onTabChanged;
  final ValueChanged<String> onLoginSubmit;
  final ValueChanged<String> onRegisterSubmit;
  final VoidCallback onBack;

  const GuideAuthTabs({
    super.key,
    required this.isLogin,
    required this.isLoading,
    required this.onTabChanged,
    required this.onLoginSubmit,
    required this.onRegisterSubmit,
    required this.onBack,
  });

  @override
  State<GuideAuthTabs> createState() => _GuideAuthTabsState();
}

class _GuideAuthTabsState extends State<GuideAuthTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final PhoneInputFieldController _phoneController =
      PhoneInputFieldController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.isLogin ? 0 : 1,
    );
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    // Реагируем только на ЗАВЕРШЕНИЕ анимации переключения таба
    if (_tabController.indexIsChanging) return;

    final isLogin = _tabController.index == 0;

    // 1. МГНОВЕННО обновляем UI (это ответственность StatefulWidget)
    // Мы не ждем BLoC, чтобы интерфейс был отзывчивым на 100%
    _phoneController.controller.clear();
    _phoneController.controller.text = '+996 ';
    setState(() => _isValid = false);

    // 2. Синхронизируем с BLoC только если режим действительно изменился
    // Это предотвращает лишние emmit-ы и дедупликацию состояний
    if (isLogin != widget.isLogin) {
      widget.onTabChanged(isLogin);
    }
  }

  @override
  void didUpdateWidget(GuideAuthTabs oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Этот блок срабатывает ТОЛЬКО при внешнем изменении (например,
    // при переходе с экрана GuideWelcome), но НЕ при кликах по табам,
    // потому что при кликах мы уже синхронизировали isLogin в _onTabChanged.
    if (widget.isLogin != oldWidget.isLogin) {
      final newIndex = widget.isLogin ? 0 : 1;

      // Если TabController уже на нужном индексе, просто чистим форму
      if (_tabController.index == newIndex) {
        _clearForm();
        return;
      }

      // Иначе анимируем переход и чистим форму
      _tabController.animateTo(newIndex);
      _clearForm();
    }
  }

  void _clearForm() {
    _phoneController.controller.clear();
    _phoneController.controller.text = '+996 ';
    setState(() => _isValid = false);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _phoneController.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: AppBackButton(
          onPressed: widget.onBack,
          style: BackButtonStyle.iconOnly,
        ),
        title: Text(
          widget.isLogin ? 'Вход гида' : 'Регистрация гида',
          style: AppTextStyles.subtext.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimens.space16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(AppDimens.radiusL),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.black,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: AppTextStyles.button.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: AppTextStyles.button.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Войти'),
                    Tab(text: 'Зарегистрироваться'),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.space32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        key: ValueKey(widget.isLogin),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isLogin
                                ? 'Введите номер телефона'
                                : 'Начните с номера',
                            style: AppTextStyles.headlineMedium.copyWith(
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: AppDimens.space8),
                          Text(
                            widget.isLogin
                                ? 'Мы отправим код для входа'
                                : 'Мы отправим код для создания аккаунта',
                            style: AppTextStyles.subtext,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.space32),

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
                    const Spacer(),

                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isValid ? 1.0 : 0.3,
                      child: JoluButton(
                        text: widget.isLogin ? 'Продолжить' : 'Создать аккаунт',
                        variant: JoluButtonVariant.primary,
                        size: JoluButtonSize.large,
                        isFullWidth: true,
                        isLoading: widget.isLoading,
                        onPressed: _isValid && !widget.isLoading
                            ? _submitPhone
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppDimens.space24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.isLogin
                              ? 'Нет аккаунта? '
                              : 'Уже есть аккаунт? ',
                          style: AppTextStyles.bodySmall,
                        ),
                        GestureDetector(
                          onTap: () {
                            final newIndex = widget.isLogin ? 1 : 0;
                            _tabController.animateTo(newIndex);
                            // Дублируем очистку для клика по тексту внизу
                            _clearForm();
                          },
                          child: Text(
                            widget.isLogin ? 'Зарегистрироваться' : 'Войти',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.space16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitPhone() {
    final phone = _phoneController.rawPhone;
    debugPrint('🔥 ОТПРАВКА: isLogin = ${widget.isLogin}, phone = $phone');

    if (widget.isLogin) {
      widget.onLoginSubmit(phone);
    } else {
      widget.onRegisterSubmit(phone);
    }
  }
}
