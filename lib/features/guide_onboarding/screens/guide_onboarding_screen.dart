// lib/features/guide_onboarding/presentation/screens/guide_onboarding_screen.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/core/utils/image_picker_utils.dart';
import 'package:jolutrip_app/features/guide_onboarding/bloc/guide_onboarding_cubit.dart';
import 'package:jolutrip_app/features/guide_onboarding/bloc/guide_onboarding_state.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';

import 'package:jolutrip_app/features/guide_onboarding/screens/widgets/shared/bottom_bar_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/screens/widgets/shared/progress_bar_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/screens/widgets/steps/step1_experience_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/screens/widgets/steps/step2_documents_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/screens/widgets/steps/step3_review_widget.dart';

class GuideOnboardingScreen extends StatefulWidget {
  final String guideId;
  final String token;

  const GuideOnboardingScreen({
    super.key,
    required this.guideId,
    required this.token,
  });

  @override
  State<GuideOnboardingScreen> createState() => _GuideOnboardingScreenState();
}

class _GuideOnboardingScreenState extends State<GuideOnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Step 1
  final _experienceController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carNumberController = TextEditingController();
  final List<String> _selectedLanguages = ['ru'];

  // Step 2
  Uint8List? _passportScanBytes;
  Uint8List? _licensePhotoBytes;
  final List<Uint8List> _carPhotosBytes = [];
  final ImagePickerUtils _imagePickerUtils = ImagePickerUtils();

  @override
  void dispose() {
    _pageController.dispose();
    _experienceController.dispose();
    _carModelController.dispose();
    _carNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(Function(Uint8List) onPicked) async {
    final bytes = await _imagePickerUtils.showImagePickerDialog(context);
    if (bytes != null) onPicked(bytes);
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

    context.read<GuideOnboardingCubit>().submitOnboarding(
      token: widget.token,
      experienceYears: int.parse(_experienceController.text),
      carModel: _carModelController.text,
      carNumber: _carNumberController.text,
      languages: _selectedLanguages,
      passportScanBytes: _passportScanBytes!.toList(),
      licensePhotoBytes: _licensePhotoBytes!.toList(),
      carPhotosBytes: allCarPhotos,
    );
  }

  void _showPendingDialog(
    BuildContext context,
    GuideOnboardingSubmitted state,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PendingDialog(
        onboarding: state.onboarding,
        guideId: widget.guideId,
        token: widget.token,
        onDismiss: () {
          // Закрываем диалог и переходим на профиль
          Navigator.of(context).pop();

          // Переходим на профиль с данными
          context.pushReplacement(
            '/guide/profile',
            extra: {
              'guideId': widget.guideId,
              'token': widget.token,
              'onboarding': state.onboarding,
              'fullName': state.onboarding.fullName ?? 'Гид',
              'phone': state.onboarding.phone ?? '',
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: BlocConsumer<GuideOnboardingCubit, GuideOnboardingState>(
          listener: (context, state) {
            if (state is GuideOnboardingSubmitted) {
              _showPendingDialog(context, state);
            } else if (state is GuideOnboardingError) {
              JoluSnackbar.show(
                context: context,
                message: state.message,
                type: JoluSnackbarType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is GuideOnboardingLoading;

            return Column(
              children: [
                ProgressBarWidget(currentPage: _currentPage),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    children: [
                      Step1ExperienceWidget(
                        experienceController: _experienceController,
                        carModelController: _carModelController,
                        carNumberController: _carNumberController,
                        selectedLanguages: _selectedLanguages,
                        onToggleLanguage: _toggleLanguage,
                      ),
                      Step2DocumentsWidget(
                        passportScanBytes: _passportScanBytes,
                        licensePhotoBytes: _licensePhotoBytes,
                        carPhotosBytes: _carPhotosBytes,
                        onPickPassport: (bytes) =>
                            setState(() => _passportScanBytes = bytes),
                        onPickLicense: (bytes) =>
                            setState(() => _licensePhotoBytes = bytes),
                        onAddCarPhoto: (bytes) =>
                            setState(() => _carPhotosBytes.add(bytes)),
                        onRemoveCarPhoto: (index) =>
                            setState(() => _carPhotosBytes.removeAt(index)),
                        onPickImage: _pickImage,
                      ),
                      Step3ReviewWidget(
                        experience: _experienceController.text,
                        carModel: _carModelController.text,
                        carNumber: _carNumberController.text,
                        languages: _selectedLanguages,
                        hasPassport: _passportScanBytes != null,
                        hasLicense: _licensePhotoBytes != null,
                        carPhotosCount: _carPhotosBytes.length,
                      ),
                    ],
                  ),
                ),
                BottomBarWidget(
                  currentPage: _currentPage,
                  isLoading: isLoading,
                  canProceed: _canProceed,
                  onBack: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  onNext: _onNext,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool get _canProceed => switch (_currentPage) {
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
}

// ═══════════════════════════════════════════════════
// Dialog widget (private, only used here)
// ═══════════════════════════════════════════════════
class _PendingDialog extends StatelessWidget {
  final OnboardingEntity onboarding;
  final String guideId;
  final String token;
  final VoidCallback onDismiss;

  const _PendingDialog({
    required this.onboarding,
    required this.guideId,
    required this.token,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
      ),
      title: Column(
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.success, size: 60),
          const SizedBox(height: 16),
          Text('Заявка отправлена!', style: AppTextStyles.headline),
        ],
      ),
      content: Text(
        'Мы проверим ваши документы в течение 24 часов. '
        'Вы получите уведомление, как только станете проверенным гидом.',
        style: AppTextStyles.body,
        textAlign: TextAlign.center,
      ),
      actions: [
        JoluButton(
          text: 'Перейти в профиль',
          variant: JoluButtonVariant.primary,
          isFullWidth: true,
          onPressed: onDismiss,
        ),
      ],
    );
  }
}
