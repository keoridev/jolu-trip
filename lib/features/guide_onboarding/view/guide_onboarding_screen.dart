import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jolutrip_app/core/storage/secure_storage.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/core/utils/image_picker_utils.dart';
import 'package:jolutrip_app/features/guide_auth/domain/entities/guide_entity.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/bloc/guide_onboarding_cubit.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/bloc/guide_onboarding_state.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/bottom_bar_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/progress_bar_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/steps/step1_experience_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/steps/step2_documents_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/steps/step3_review_widget.dart';

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
  String? _selectedCarCategory;

  // Step 2 — 4 фото документов + 4 фото авто + видео
  Uint8List? _passportMainPhotoBytes;
  Uint8List? _passportRegistrationPhotoBytes;
  Uint8List? _licensePhotoFrontBytes;
  Uint8List? _licensePhotoBackBytes;
  final List<Uint8List> _carPhotosBytes = [];
  Uint8List? _presentationVideoBytes;

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

  Future<void> _pickVideo(Function(Uint8List) onPicked) async {
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 60),
      );

      if (video != null) {
        final bytes = await video.readAsBytes();
        onPicked(bytes);
        JoluSnackbar.show(
          context: context,
          message: 'Видео загружено!',
          type: JoluSnackbarType.success,
        );
      }
    } catch (e) {
      JoluSnackbar.show(
        context: context,
        message: 'Ошибка при загрузке видео',
        type: JoluSnackbarType.error,
      );
    }
  }

  Future<void> _recordVideo(Function(Uint8List) onPicked) async {
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 60),
      );

      if (video != null) {
        final bytes = await video.readAsBytes();
        onPicked(bytes);
        JoluSnackbar.show(
          context: context,
          message: 'Видео записано!',
          type: JoluSnackbarType.success,
        );
      }
    } catch (e) {
      JoluSnackbar.show(
        context: context,
        message: 'Ошибка при записи видео',
        type: JoluSnackbarType.error,
      );
    }
  }

  void _showVideoPickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Добавить видео-визитку',
                style: AppTextStyles.headline.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Text(
                'Видео до 1 минуты, где вы рассказываете о себе как о гиде',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _VideoPickerOption(
                      icon: Icons.video_library_outlined,
                      label: 'Выбрать из галереи',
                      onTap: () {
                        Navigator.pop(context);
                        _pickVideo((bytes) {
                          setState(() => _presentationVideoBytes = bytes);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _VideoPickerOption(
                      icon: Icons.videocam_outlined,
                      label: 'Записать видео',
                      onTap: () {
                        Navigator.pop(context);
                        _recordVideo((bytes) {
                          setState(() => _presentationVideoBytes = bytes);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Отмена',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
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
    if (_presentationVideoBytes == null) {
      JoluSnackbar.show(
        context: context,
        message: 'Добавьте видео-визитку',
        type: JoluSnackbarType.warning,
      );
      return;
    }

    final allCarPhotos = _carPhotosBytes.map((e) => e.toList()).toList();

    context.read<GuideOnboardingCubit>().submitOnboarding(
      token: widget.token,
      experienceYears: int.parse(_experienceController.text),
      carCategory: _selectedCarCategory ?? 'sedan',
      carModel: _carModelController.text,
      carNumber: _carNumberController.text,
      languages: _selectedLanguages,
      passportMainPhotoBytes: _passportMainPhotoBytes!.toList(),
      passportRegistrationPhotoBytes: _passportRegistrationPhotoBytes!.toList(),
      licensePhotoFrontBytes: _licensePhotoFrontBytes!.toList(),
      licensePhotoBackBytes: _licensePhotoBackBytes!.toList(),
      carPhotosBytes: allCarPhotos,
      presentationVideoBytes: _presentationVideoBytes!.toList(),
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
        onDismiss: () async {
          Navigator.of(context).pop();

          // Сохраняем НОВЫЙ токен, если backend его прислал
          final newToken = state.onboarding.newToken ?? widget.token;

          await SecureStorage.saveAuthData(
            token: newToken, // ← используем новый токен
            userId: widget.guideId,
            phone: state.onboarding.phone ?? '',
            name: state.onboarding.fullName ?? 'Гид',
            role: 'guide',
          );

          final guide = GuideEntity(
            id: widget.guideId,
            fullName: state.onboarding.fullName ?? 'Гид',
            phone: state.onboarding.phone ?? '',
            gender: GuideGender.male,
            status: GuideStatus.pending,
            createdAt: DateTime.now(),
          );

          await SecureStorage.saveGuideData(guide);
          await SecureStorage.saveOnboardingData(state.onboarding);

          if (context.mounted) {
            context.go('/profile');
            JoluSnackbar.show(
              context: context,
              message: 'Профиль отправлен на проверку!',
              type: JoluSnackbarType.success,
            );
          }
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
                        selectedCarCategory: _selectedCarCategory,
                        onToggleLanguage: _toggleLanguage,
                        onCategoryChanged: (value) =>
                            setState(() => _selectedCarCategory = value),
                      ),
                      Step2DocumentsWidget(
                        passportMainPhotoBytes: _passportMainPhotoBytes,
                        passportRegistrationPhotoBytes:
                            _passportRegistrationPhotoBytes,
                        licensePhotoFrontBytes: _licensePhotoFrontBytes,
                        licensePhotoBackBytes: _licensePhotoBackBytes,
                        carPhotosBytes: _carPhotosBytes,
                        presentationVideoBytes: _presentationVideoBytes,
                        onPickPassportMain: (bytes) =>
                            setState(() => _passportMainPhotoBytes = bytes),
                        onPickPassportRegistration: (bytes) => setState(
                          () => _passportRegistrationPhotoBytes = bytes,
                        ),
                        onPickLicenseFront: (bytes) =>
                            setState(() => _licensePhotoFrontBytes = bytes),
                        onPickLicenseBack: (bytes) =>
                            setState(() => _licensePhotoBackBytes = bytes),
                        onAddCarPhoto: (bytes) =>
                            setState(() => _carPhotosBytes.add(bytes)),
                        onRemoveCarPhoto: (index) =>
                            setState(() => _carPhotosBytes.removeAt(index)),
                        onPickImage: _pickImage,
                        onPickVideo: _showVideoPickerDialog,
                        onRemoveVideo: () =>
                            setState(() => _presentationVideoBytes = null),
                      ),
                      Step3ReviewWidget(
                        experience: _experienceController.text,
                        carCategory: _selectedCarCategory ?? 'Не выбрана',
                        carModel: _carModelController.text,
                        carNumber: _carNumberController.text,
                        languages: _selectedLanguages,
                        hasPassportMain: _passportMainPhotoBytes != null,
                        hasPassportRegistration:
                            _passportRegistrationPhotoBytes != null,
                        hasLicenseFront: _licensePhotoFrontBytes != null,
                        hasLicenseBack: _licensePhotoBackBytes != null,
                        carPhotosCount: _carPhotosBytes.length,
                        hasVideo: _presentationVideoBytes != null,
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
          _selectedCarCategory != null &&
          _carModelController.text.trim().isNotEmpty &&
          _carNumberController.text.trim().isNotEmpty &&
          _selectedLanguages.isNotEmpty,
    1 =>
      _passportMainPhotoBytes != null &&
          _passportRegistrationPhotoBytes != null &&
          _licensePhotoFrontBytes != null &&
          _licensePhotoBackBytes != null &&
          _carPhotosBytes.length == 4 &&
          _presentationVideoBytes != null,
    2 => true,
    _ => false,
  };
}

// ═══════════════════════════════════════════════════
// Video Picker Option Widget
// ═══════════════════════════════════════════════════
class _VideoPickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _VideoPickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// Dialog widget
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
        'Мы проверим ваши документы и видео-визитку в течение 24 часов. '
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
