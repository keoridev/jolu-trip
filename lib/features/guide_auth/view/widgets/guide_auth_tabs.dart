// lib/features/guide_auth/presentation/widgets/guide_auth_tabs.dart

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/auth/view/widgets/phone_view.dart';

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
    if (!_tabController.indexIsChanging) {
      final isLogin = _tabController.index == 0;
      widget.onTabChanged(isLogin);
      // Сбрасываем валидацию при смене вкладки
      setState(() => _isValid = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
        child: Column(
          children: [
            // Навигация
            const SizedBox(height: AppDimens.space8),
            Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  widget.isLogin ? 'Вход гида' : 'Регистрация гида',
                  style: AppTextStyles.subtext.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: AppDimens.space24),

            // Вкладки
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppDimens.radiusL),
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

            // 🔥 Используем единый компонент
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isLogin
                        ? 'Введите номер телефона'
                        : 'Начните с номера',
                    style: AppTextStyles.headlineMedium.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: AppDimens.space8),
                  Text(
                    widget.isLogin
                        ? 'Мы отправим код для входа'
                        : 'Мы отправим код для создания аккаунта',
                    style: AppTextStyles.subtext,
                  ),
                  const SizedBox(height: AppDimens.space32),

                  PhoneInputField(
                    controller: _phoneController.controller,
                    focusNode: _phoneController.focusNode,
                    autoFocus: true,
                    onValidityChanged: (isValid) {
                      setState(() => _isValid = isValid);
                    },
                    onSubmitted: () {
                      if (_isValid && !widget.isLoading) {
                        _submitPhone();
                      }
                    },
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

                  // Переключатель режима
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
    );
  }

  void _submitPhone() {
    final phone = _phoneController.rawPhone;
    if (widget.isLogin) {
      widget.onLoginSubmit(phone);
    } else {
      widget.onRegisterSubmit(phone);
    }
  }
}
