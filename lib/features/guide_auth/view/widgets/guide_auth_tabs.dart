import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/buttons/jolu_back_button.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';

class GuideAuthTabs extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onBack;
  final ValueChanged<String> onLoginSubmit;
  final Function(String phone, String name, GuideGender gender)
  onRegisterSubmit;

  const GuideAuthTabs({
    super.key,
    required this.isLoading,
    required this.onBack,
    required this.onLoginSubmit,
    required this.onRegisterSubmit,
  });

  @override
  State<GuideAuthTabs> createState() => _GuideAuthTabsState();
}

class _GuideAuthTabsState extends State<GuideAuthTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final PhoneInputFieldController _phoneController =
      PhoneInputFieldController();
  final TextEditingController _nameController = TextEditingController();

  bool _isValidPhone = false;
  GuideGender? _selectedGender;
  bool _isNameTouched = false;

  bool get _isLogin => _tabController.index == 0;

  bool get _isFormValid {
    if (_isLogin) return _isValidPhone;
    return _isValidPhone &&
        _nameController.text.trim().length >= 3 &&
        _selectedGender != null;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Триггерим перестройку для плавного появления полей
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_isFormValid || widget.isLoading) return;

    final phone = _phoneController.rawPhone;
    if (_isLogin) {
      widget.onLoginSubmit(phone);
    } else {
      widget.onRegisterSubmit(
        phone,
        _nameController.text.trim(),
        _selectedGender!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimens.space16),
              AppBackButton(
                onPressed: widget.onBack,
                style: BackButtonStyle.iconOnly,
              ),
              const SizedBox(height: AppDimens.space24),
              Text(
                _isLogin ? 'Вход для гидов' : 'Регистрация гида',
                style: AppTextStyles.headline.copyWith(fontSize: 28),
              ),
              const SizedBox(height: AppDimens.space8),
              Text(
                _isLogin
                    ? 'Введите номер телефона для получения кода'
                    : 'Создайте аккаунт, чтобы начать зарабатывать',
                style: AppTextStyles.subtext,
              ),
              const SizedBox(height: AppDimens.space24),
            ],
          ),
        ),

        // Tabs
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
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
              Tab(text: 'Регистрация'),
            ],
          ),
        ),

        const SizedBox(height: AppDimens.space24),

        // Scrollable Form
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Анимированное появление полей регистрации
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _buildRegistrationFields(),
                  crossFadeState: _isLogin
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 300),
                ),

                const SizedBox(height: AppDimens.space24),

                // Телефон (всегда виден)
                Text(
                  'Номер телефона',
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimens.space12),
                PhoneInputField(
                  controller: _phoneController.controller,
                  focusNode: _phoneController.focusNode,
                  autoFocus: true,
                  hintText: '700 000 000',
                  onValidityChanged: (isValid) =>
                      setState(() => _isValidPhone = isValid),
                  onSubmitted: _isFormValid ? _submit : null,
                ),
                const SizedBox(height: AppDimens.space8),
                Row(
                  children: [
                    const Icon(
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

                const SizedBox(height: AppDimens.space48),

                // Кнопка
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isFormValid ? 1.0 : 0.4,
                  child: JoluButton(
                    text: _isLogin ? 'Получить код' : 'Создать аккаунт',
                    variant: JoluButtonVariant.primary,
                    size: JoluButtonSize.large,
                    isFullWidth: true,
                    isLoading: widget.isLoading,
                    onPressed: _isFormValid && !widget.isLoading
                        ? _submit
                        : null,
                  ),
                ),
                const SizedBox(height: AppDimens.space32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ваше полное имя',
          style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppDimens.space12),
        TextField(
          controller: _nameController,
          onChanged: (_) => setState(() => _isNameTouched = true),
          style: AppTextStyles.body.copyWith(fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Иванов Иван Иванович',
            filled: true,
            fillColor: AppColors.cardDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide(color: AppColors.borderDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide(color: AppColors.error),
            ),
            errorText: _isNameTouched && _nameController.text.trim().length < 3
                ? 'Минимум 3 символа'
                : null,
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppDimens.space16,
              horizontal: AppDimens.space16,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.space24),

        Text(
          'Ваш пол',
          style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppDimens.space12),
        Row(
          children: [
            Expanded(
              child: _GenderCard(
                icon: Icons.male,
                label: 'Мужской',
                isSelected: _selectedGender == GuideGender.male,
                onTap: () => setState(() => _selectedGender = GuideGender.male),
              ),
            ),
            const SizedBox(width: AppDimens.space16),
            Expanded(
              child: _GenderCard(
                icon: Icons.female,
                label: 'Женский',
                isSelected: _selectedGender == GuideGender.female,
                onTap: () =>
                    setState(() => _selectedGender = GuideGender.female),
              ),
            ),
          ],
        ),
        if (_isNameTouched && _selectedGender == null) ...[
          const SizedBox(height: AppDimens.space8),
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'Пожалуйста, выберите пол',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppDimens.space24),
      ],
    );
  }
}

class _GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderDark,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 28,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
