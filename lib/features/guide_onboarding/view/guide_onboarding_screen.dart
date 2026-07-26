import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/bottom_bar_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/onboarding_header_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/onboarding_options.dart';
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
  static const _stepCount = 3;
  static const _pageDuration = Duration(milliseconds: 320);

  static const _stepTitles = ['Опыт и автомобиль', 'Документы', 'Проверка'];
  static const _stepSubtitles = [
    'Расскажите, на чём и как давно вы возите гостей',
    'Загрузите документы и видео-визитку для верификации',
    'Убедитесь, что всё заполнено верно, и отправляйте',
  ];

  final _pageController = PageController();
  int _currentPage = 0;

  // Шаг 1
  final _experienceController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carNumberController = TextEditingController();
  final List<String> _selectedLanguages = ['ru'];
  String? _selectedCarCategory;

  // Шаг 2 — 4 фото документов + 4 фото авто (по слотам) + видео
  Uint8List? _passportMainPhotoBytes;
  Uint8List? _passportRegistrationPhotoBytes;
  Uint8List? _licensePhotoFrontBytes;
  Uint8List? _licensePhotoBackBytes;
  final List<Uint8List?> _carPhotos = List<Uint8List?>.filled(
    carPhotoSlots.length,
    null,
    growable: false,
  );
  Uint8List? _presentationVideoBytes;

  final ImagePickerUtils _imagePickerUtils = ImagePickerUtils();

  @override
  void initState() {
    super.initState();
    // Доступность кнопки «Далее» зависит от текста в полях, поэтому её нужно
    // пересчитывать на каждый ввод, а не только при выборе категории/языка.
    for (final controller in [
      _experienceController,
      _carModelController,
      _carNumberController,
    ]) {
      controller.addListener(_onFormChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _experienceController,
      _carModelController,
      _carNumberController,
    ]) {
      controller.removeListener(_onFormChanged);
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  // ─── Выбор файлов ──────────────────────────────────────────────────────
  Future<void> _pickImage(void Function(Uint8List) onPicked) async {
    final bytes = await _imagePickerUtils.showImagePickerDialog(context);
    if (bytes != null) onPicked(bytes);
  }

  Future<void> _pickVideoFrom(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 60),
      );
      if (video == null) return;

      final bytes = await video.readAsBytes();
      if (!mounted) return;

      setState(() => _presentationVideoBytes = bytes);
      JoluSnackbar.show(
        context: context,
        message: source == ImageSource.camera
            ? 'Видео записано'
            : 'Видео загружено',
        type: JoluSnackbarType.success,
      );
    } catch (_) {
      if (!mounted) return;
      JoluSnackbar.show(
        context: context,
        message: 'Не удалось получить видео',
        type: JoluSnackbarType.error,
      );
    }
  }

  void _showVideoPickerSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radius24),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.space20,
            AppDimens.space12,
            AppDimens.space20,
            AppDimens.space24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDark,
                  borderRadius: BorderRadius.circular(AppDimens.radiusRound),
                ),
              ),
              const SizedBox(height: AppDimens.space24),
              Text('Видео-визитка', style: AppTextStyles.headlineSmall),
              const SizedBox(height: AppDimens.space8),
              Text(
                'Ролик до минуты: представьтесь и расскажите, какие туры водите',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.space24),
              Row(
                children: [
                  Expanded(
                    child: _VideoPickerOption(
                      icon: Icons.videocam_rounded,
                      label: 'Записать',
                      description: 'Снять сейчас',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _pickVideoFrom(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimens.space12),
                  Expanded(
                    child: _VideoPickerOption(
                      icon: Icons.video_library_rounded,
                      label: 'Из галереи',
                      description: 'Выбрать файл',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _pickVideoFrom(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Навигация по шагам ────────────────────────────────────────────────
  void _goToStep(int step) {
    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      step,
      duration: _pageDuration,
      curve: Curves.easeInOut,
    );
  }

  void _onNext() {
    FocusScope.of(context).unfocus();
    if (_currentPage < _stepCount - 1) {
      _goToStep(_currentPage + 1);
    } else {
      _submitOnboarding();
    }
  }

  void _onBack() {
    FocusScope.of(context).unfocus();
    _goToStep(_currentPage - 1);
  }

  Future<void> _onClose() async {
    if (_currentPage > 0) {
      _onBack();
      return;
    }

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius20),
        ),
        title: Text('Выйти из анкеты?', style: AppTextStyles.headlineSmall),
        contentPadding: const EdgeInsets.fromLTRB(
          AppDimens.space24,
          AppDimens.space12,
          AppDimens.space24,
          AppDimens.space20,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Заполненные данные не сохранятся — заполнять придётся заново.',
              style: AppTextStyles.bodySmall.copyWith(height: 1.45),
            ),
            const SizedBox(height: AppDimens.space24),
            JoluButton(
              text: 'Остаться',
              variant: JoluButtonVariant.outline,
              onPressed: () => Navigator.pop(dialogContext, false),
            ),
            const SizedBox(height: AppDimens.space8),
            JoluButton(
              text: 'Выйти',
              variant: JoluButtonVariant.text,
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        ),
      ),
    );

    if (shouldLeave == true && mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/profile');
      }
    }
  }

  // ─── Валидация ─────────────────────────────────────────────────────────
  int? get _experienceYears => int.tryParse(_experienceController.text.trim());

  int get _uploadedFilesCount =>
      (_passportMainPhotoBytes != null ? 1 : 0) +
      (_passportRegistrationPhotoBytes != null ? 1 : 0) +
      (_licensePhotoFrontBytes != null ? 1 : 0) +
      (_licensePhotoBackBytes != null ? 1 : 0) +
      _carPhotos.whereType<Uint8List>().length +
      (_presentationVideoBytes != null ? 1 : 0);

  static const int _requiredFilesCount = 9;

  /// Что мешает уйти с шага [step]; null — можно идти дальше.
  String? _blockerFor(int step) {
    switch (step) {
      case 0:
        final missing = <String>[
          if (_experienceYears == null) 'стаж',
          if (_selectedCarCategory == null) 'категорию авто',
          if (_carModelController.text.trim().isEmpty) 'модель авто',
          if (_carNumberController.text.trim().isEmpty) 'гос. номер',
          if (_selectedLanguages.isEmpty) 'язык',
        ];
        if (missing.isEmpty) return null;
        return 'Укажите ${missing.join(', ')}';

      case 1:
      case 2:
        final left = _requiredFilesCount - _uploadedFilesCount;
        if (left <= 0) return null;
        return 'Осталось загрузить файлов: $left';

      default:
        return null;
    }
  }

  bool get _canProceed => _blockerFor(_currentPage) == null;

  void _submitOnboarding() {
    // Проверяем оба шага, а не только текущий: иначе `!` ниже может
    // выстрелить, если анкету собрали не по прямому пути.
    final years = _experienceYears;
    if (years == null ||
        _selectedCarCategory == null ||
        _blockerFor(0) != null ||
        _blockerFor(1) != null) {
      JoluSnackbar.show(
        context: context,
        message: 'Заполните все обязательные поля и файлы',
        type: JoluSnackbarType.warning,
      );
      return;
    }

    context.read<GuideOnboardingCubit>().submitOnboarding(
      token: widget.token,
      experienceYears: years,
      carCategory: _selectedCarCategory!,
      carModel: _carModelController.text.trim(),
      carNumber: _carNumberController.text.trim(),
      languages: _selectedLanguages,
      passportMainPhotoBytes: _passportMainPhotoBytes!.toList(),
      passportRegistrationPhotoBytes: _passportRegistrationPhotoBytes!.toList(),
      licensePhotoFrontBytes: _licensePhotoFrontBytes!.toList(),
      licensePhotoBackBytes: _licensePhotoBackBytes!.toList(),
      carPhotosBytes: _carPhotos
          .whereType<Uint8List>()
          .map((e) => e.toList())
          .toList(),
      presentationVideoBytes: _presentationVideoBytes!.toList(),
    );
  }

  void _toggleLanguage(String code) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedLanguages.contains(code)) {
        // Хотя бы один язык должен остаться выбранным.
        if (_selectedLanguages.length > 1) _selectedLanguages.remove(code);
      } else {
        _selectedLanguages.add(code);
      }
    });
  }

  void _showPendingDialog(
    BuildContext context,
    GuideOnboardingSubmitted state,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PendingDialog(
        onDismiss: () async {
          Navigator.of(context).pop();

          // Сохраняем НОВЫЙ токен, если backend его прислал
          final newToken = state.onboarding.newToken ?? widget.token;

          await SecureStorage.saveAuthData(
            token: newToken,
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onClose();
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SafeArea(
          bottom: false,
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
                  OnboardingHeaderWidget(
                    currentPage: _currentPage,
                    stepCount: _stepCount,
                    title: _stepTitles[_currentPage],
                    subtitle: _stepSubtitles[_currentPage],
                    onClose: _onClose,
                  ),
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
                          onCategoryChanged: (value) {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedCarCategory = value);
                          },
                        ),
                        Step2DocumentsWidget(
                          passportMainPhotoBytes: _passportMainPhotoBytes,
                          passportRegistrationPhotoBytes:
                              _passportRegistrationPhotoBytes,
                          licensePhotoFrontBytes: _licensePhotoFrontBytes,
                          licensePhotoBackBytes: _licensePhotoBackBytes,
                          carPhotos: _carPhotos,
                          presentationVideoBytes: _presentationVideoBytes,
                          onPassportMainChanged: (bytes) =>
                              setState(() => _passportMainPhotoBytes = bytes),
                          onPassportRegistrationChanged: (bytes) => setState(
                            () => _passportRegistrationPhotoBytes = bytes,
                          ),
                          onLicenseFrontChanged: (bytes) =>
                              setState(() => _licensePhotoFrontBytes = bytes),
                          onLicenseBackChanged: (bytes) =>
                              setState(() => _licensePhotoBackBytes = bytes),
                          onCarPhotoChanged: (index, bytes) =>
                              setState(() => _carPhotos[index] = bytes),
                          onPickImage: _pickImage,
                          onPickVideo: _showVideoPickerSheet,
                          onRemoveVideo: () =>
                              setState(() => _presentationVideoBytes = null),
                        ),
                        Step3ReviewWidget(
                          experience: _experienceController.text.trim(),
                          carCategory: _selectedCarCategory,
                          carModel: _carModelController.text.trim(),
                          carNumber: _carNumberController.text.trim(),
                          languages: _selectedLanguages,
                          hasPassportMain: _passportMainPhotoBytes != null,
                          hasPassportRegistration:
                              _passportRegistrationPhotoBytes != null,
                          hasLicenseFront: _licensePhotoFrontBytes != null,
                          hasLicenseBack: _licensePhotoBackBytes != null,
                          carPhotosCount:
                              _carPhotos.whereType<Uint8List>().length,
                          hasVideo: _presentationVideoBytes != null,
                          onEditStep: _goToStep,
                        ),
                      ],
                    ),
                  ),
                  BottomBarWidget(
                    currentPage: _currentPage,
                    lastPage: _stepCount - 1,
                    isLoading: isLoading,
                    canProceed: _canProceed,
                    blockedReason: _blockerFor(_currentPage),
                    onBack: _onBack,
                    onNext: _onNext,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// Выбор источника видео
// ═══════════════════════════════════════════════════
class _VideoPickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _VideoPickerOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space12,
            vertical: AppDimens.space20,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppDimens.radius16),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.accent, size: 28),
              const SizedBox(height: AppDimens.space12),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// Диалог «заявка отправлена»
// ═══════════════════════════════════════════════════
class _PendingDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const _PendingDialog({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius24),
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        AppDimens.space24,
        AppDimens.space32,
        AppDimens.space24,
        AppDimens.space16,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.success.withValues(alpha: 0.28),
                  AppColors.primary.withValues(alpha: 0.28),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 38,
            ),
          ),
          const SizedBox(height: AppDimens.space20),
          Text(
            'Заявка отправлена',
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.space12),
          Text(
            'Мы проверим документы и видео-визитку в течение 24 часов и '
            'пришлём уведомление, как только вы станете проверенным гидом.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.45),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppDimens.space24,
        0,
        AppDimens.space24,
        AppDimens.space24,
      ),
      actions: [
        JoluButton(
          text: 'Перейти в профиль',
          variant: JoluButtonVariant.primary,
          size: JoluButtonSize.large,


          isFullWidth: true,
          onPressed: onDismiss,
        ),
      ],
    );
  }
}
