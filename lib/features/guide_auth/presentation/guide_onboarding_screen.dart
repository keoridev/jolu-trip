// lib/features/guide_auth/presentation/guide_onboarding_screen.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/inputs/kyrgyz_plate_input.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/guide_auth/bloc/guide_auth_cubit.dart';
import 'package:jolutrip_app/features/guide_auth/bloc/guide_auth_state.dart';

class GuideOnboardingScreen extends StatefulWidget {
  const GuideOnboardingScreen({super.key});

  @override
  State<GuideOnboardingScreen> createState() => _GuideOnboardingScreenState();
}

class _GuideOnboardingScreenState extends State<GuideOnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Step 1: Experience & Car
  final _experienceController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carNumberController = TextEditingController();
  final List<String> _selectedLanguages = ['ru'];

  // Step 2: Documents (СООТВЕТСТВУЕТ API)
  Uint8List? _passportScanBytes; // passport_scan
  Uint8List? _licensePhotoBytes; // license_photo
  final List<Uint8List> _carPhotosBytes = []; // car_photos

  final _picker = ImagePicker();

  @override
  void dispose() {
    _pageController.dispose();
    _experienceController.dispose();
    _carModelController.dispose();
    _carNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: BlocConsumer<GuideAuthCubit, GuideAuthState>(
          listener: (context, state) {
            if (state is GuideOnboardingPending) {
              _showPendingDialog();
            } else if (state is GuideAuthError) {
              JoluSnackbar.show(
                context: context,
                message: state.message,
                type: JoluSnackbarType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is GuideAuthLoading;

            return Column(
              children: [
                _buildProgressBar(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    children: [
                      _buildStep1Experience(),
                      _buildStep2Documents(),
                      _buildStep3Review(),
                    ],
                  ),
                ),
                _buildBottomBar(isLoading),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: AppDimens.screenPadding,
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index <= _currentPage
                    ? AppColors.primary
                    : AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // STEP 1: Experience & Vehicle
  // ═══════════════════════════════════════════════════
  Widget _buildStep1Experience() {
    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimens.spaceXL),
          Text('Опыт и автомобиль', style: AppTextStyles.headline),
          const SizedBox(height: AppDimens.spaceS),
          Text(
            'Расскажите о вашем опыте и транспорте',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.spaceXL * 1.5),

          JoluTextField(
            controller: _experienceController,
            label: 'Стаж вождения (лет)',
            hint: 'Например: 5',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.timer_outlined,
          ),
          const SizedBox(height: AppDimens.spaceXL),

          JoluTextField(
            controller: _carModelController,
            label: 'Модель автомобиля',
            hint: 'Toyota Sequoia',
            prefixIcon: Icons.directions_car_outlined,
          ),
          const SizedBox(height: AppDimens.spaceXL),

          KyrgyzPlateInput(
            controller: _carNumberController,
            label: 'Гос. номер автомобиля',
            onChanged: (raw, formatted) {
              debugPrint('Raw: $raw, Formatted: $formatted');
            },
          ),
          const SizedBox(height: AppDimens.spaceXL),

          Text('Языки', style: AppTextStyles.title),
          const SizedBox(height: AppDimens.spaceM),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _LanguageChip(
                label: 'Русский',
                code: 'ru',
                isSelected: _selectedLanguages.contains('ru'),
                onTap: () => _toggleLanguage('ru'),
              ),
              _LanguageChip(
                label: 'English',
                code: 'en',
                isSelected: _selectedLanguages.contains('en'),
                onTap: () => _toggleLanguage('en'),
              ),
              _LanguageChip(
                label: 'Кыргызча',
                code: 'ky',
                isSelected: _selectedLanguages.contains('ky'),
                onTap: () => _toggleLanguage('ky'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleLanguage(String code) {
    setState(() {
      if (_selectedLanguages.contains(code)) {
        if (_selectedLanguages.length > 1) _selectedLanguages.remove(code);
      } else {
        _selectedLanguages.add(code);
      }
    });
  }

  // ═══════════════════════════════════════════════════
  // STEP 2: Documents (ПОД ТЕКУЩИЙ API)
  // ═══════════════════════════════════════════════════
  Widget _buildStep2Documents() {
    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimens.spaceXL),

          Row(
            children: [
              Expanded(child: Text('Документы', style: AppTextStyles.headline)),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_getUploadedCount()}/6',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceS),
          Text(
            'Загрузите документы для верификации. Это займёт не больше минуты.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.spaceXL * 1.5),

          // Паспорт
          _buildDocumentCard(
            title: 'Паспорт',
            subtitle: 'Главная страница с фото',
            icon: Icons.credit_card_outlined,
            imageBytes: _passportScanBytes,
            onTap: () => _pickImage(
              (bytes) => setState(() => _passportScanBytes = bytes),
            ),
            hint: 'Чёткое фото главного разворота',
          ),
          const SizedBox(height: AppDimens.spaceL),

          // Водительские права
          _buildDocumentCard(
            title: 'Водительские права',
            subtitle: 'Фото прав (обе стороны)',
            icon: Icons.badge_outlined,
            imageBytes: _licensePhotoBytes,
            onTap: () => _pickImage(
              (bytes) => setState(() => _licensePhotoBytes = bytes),
            ),
            hint: 'Сфотографируйте обе стороны или сделайте коллаж',
          ),
          const SizedBox(height: AppDimens.spaceL),

          // Фото автомобиля
          Text('Фото автомобиля', style: AppTextStyles.title),
          const SizedBox(height: AppDimens.spaceM),
          Text(
            'Сделайте 4 фото: спереди, сзади, салон, багажник',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.spaceM),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: _carPhotosBytes.length + 1,
            itemBuilder: (context, index) {
              if (index == _carPhotosBytes.length) {
                return _buildAddPhotoButton();
              }
              return _buildPhotoPreview(_carPhotosBytes[index], index);
            },
          ),

          const SizedBox(height: AppDimens.spaceXL),

          // Security note
          Container(
            padding: const EdgeInsets.all(AppDimens.spaceM),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ваши данные в безопасности. Все документы проверяются в зашифрованном виде.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getUploadedCount() {
    int count = 0;
    if (_passportScanBytes != null) count++;
    if (_licensePhotoBytes != null) count++;
    count += _carPhotosBytes.length;
    return count;
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Uint8List? imageBytes,
    required VoidCallback onTap,
    required String hint,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.spaceL),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(
            color: imageBytes != null
                ? AppColors.primary
                : AppColors.borderDark,
            width: imageBytes != null ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: imageBytes != null
                        ? AppColors.primary.withOpacity(0.15)
                        : AppColors.borderDark,
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  ),
                  child: Icon(
                    imageBytes != null ? Icons.check_circle : icon,
                    color: imageBytes != null
                        ? AppColors.primary
                        : AppColors.textMuted,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppDimens.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.subtitle),
                      const SizedBox(height: 4),
                      Text(
                        imageBytes != null ? 'Загружено ✓' : subtitle,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (imageBytes == null) ...[
              const SizedBox(height: AppDimens.spaceM),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radiusS),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hint,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: () =>
          _pickImage((bytes) => setState(() => _carPhotosBytes.add(bytes))),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(
            color: AppColors.borderDark,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.textMuted,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text('Добавить фото', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(Uint8List bytes, int index) {
    final photoTypes = ['Перед', 'Зад', 'Салон', 'Багажник'];

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              photoTypes[index % photoTypes.length],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => setState(() => _carPhotosBytes.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(void Function(Uint8List) onPicked) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      onPicked(bytes);
    }
  }

  // ═══════════════════════════════════════════════════
  // STEP 3: Review & Submit
  // ═══════════════════════════════════════════════════
  Widget _buildStep3Review() {
    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimens.spaceXL),
          Text('Проверьте данные', style: AppTextStyles.headline),
          const SizedBox(height: AppDimens.spaceXL * 1.5),

          _buildReviewItem('Стаж', '${_experienceController.text} лет'),
          _buildReviewItem('Автомобиль', _carModelController.text),
          _buildReviewItem('Номер', _carNumberController.text),
          _buildReviewItem(
            'Языки',
            _selectedLanguages.map((l) => l.toUpperCase()).join(', '),
          ),
          const SizedBox(height: AppDimens.spaceL),

          _buildReviewItem(
            'Паспорт',
            _passportScanBytes != null ? 'Загружено ✓' : 'Не загружено',
            isWarning: _passportScanBytes == null,
          ),
          _buildReviewItem(
            'Водительские права',
            _licensePhotoBytes != null ? 'Загружено ✓' : 'Не загружено',
            isWarning: _licensePhotoBytes == null,
          ),
          _buildReviewItem(
            'Фото автомобиля',
            '${_carPhotosBytes.length}/4 шт.',
            isWarning: _carPhotosBytes.length < 4,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(
    String label,
    String value, {
    bool isWarning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.spaceM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.subtext),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: isWarning ? AppColors.warning : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // Bottom Navigation
  // ═══════════════════════════════════════════════════
  Widget _buildBottomBar(bool isLoading) {
    final canProceed = switch (_currentPage) {
      0 =>
        _experienceController.text.trim().isNotEmpty &&
            _carModelController.text.trim().isNotEmpty &&
            _carNumberController.text.trim().isNotEmpty &&
            _selectedLanguages.isNotEmpty,
      1 =>
        _passportScanBytes != null &&
            _licensePhotoBytes != null &&
            _carPhotosBytes.length >= 4,
      2 => true,
      _ => false,
    };

    return Container(
      padding: AppDimens.screenPadding,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        border: Border(top: BorderSide(color: AppColors.borderDark)),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: JoluButton(
                text: 'Назад',
                variant: JoluButtonVariant.outline,
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: AppDimens.spaceM),
          Expanded(
            flex: _currentPage > 0 ? 1 : 2,
            child: JoluButton(
              text: _currentPage == 2 ? 'Отправить на проверку' : 'Далее',
              variant: JoluButtonVariant.primary,
              isLoading: isLoading,
              onPressed: canProceed ? _onNext : null,
            ),
          ),
        ],
      ),
    );
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitOnboarding();
    }
  }

  void _submitOnboarding() {
    final allCarPhotos = _carPhotosBytes.map((e) => e.toList()).toList();

    context.read<GuideAuthCubit>().submitOnboarding(
      experienceYears: int.parse(_experienceController.text),
      carModel: _carModelController.text,
      carNumber: _carNumberController.text,
      languages: _selectedLanguages,
      passportScanBytes: _passportScanBytes!.toList(),
      licensePhotoBytes: _licensePhotoBytes!.toList(),
      carPhotosBytes: allCarPhotos,
    );
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
        ),
        title: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text('Заявка отправлена!', style: AppTextStyles.headline),
          ],
        ),
        content: Text(
          'Мы проверим ваши документы в течение 24 часов. Вы получите уведомление, как только станете проверенным гидом.',
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
        actions: [
          JoluButton(
            text: 'Понятно',
            variant: JoluButtonVariant.primary,
            isFullWidth: true,
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to main screen
            },
          ),
        ],
      ),
    );
  }
}

// Language Chip Widget
class _LanguageChip extends StatelessWidget {
  final String label;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderDark,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
