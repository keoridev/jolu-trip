import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/core/utils/image_picker_utils.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_cubit.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_state.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/guide_profile_entity.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/blocks/guide_car_block.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/blocks/guide_experience_block.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/blocks/guide_header.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/blocks/guide_status_banner.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/shared/guide_action_buttons.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/entities/onboarding_entity.dart';

class GuideProfileScreen extends StatelessWidget {
  const GuideProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: BlocConsumer<GuideProfileCubit, GuideProfileState>(
          listener: (context, state) {
            if (state is GuideProfileError) {
              JoluSnackbar.show(
                context: context,
                message: state.message,
                type: JoluSnackbarType.error,
              );
            }
          },
          builder: (context, state) {
            return switch (state) {
              GuideProfileInitial() || GuideProfileLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              GuideProfileLoaded(profile: final profile) => _buildContent(
                context,
                profile,
              ),
              GuideProfileError() => _buildError(context, state),
              // TODO: Handle this case.
              GuideProfileState() => throw UnimplementedError(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, GuideProfileEntity profile) {
    final onboarding = profile.onboarding;

    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimens.space16),

          if (profile.isPending || profile.isRejected)
            GuideStatusBanner(profile: profile),
          if (profile.isPending || profile.isRejected)
            const SizedBox(height: AppDimens.space32),

          GuideHeader(
            profile: profile,
            onAvatarTap: profile.canEdit ? () => _onAvatarTap(context) : null,
          ),
          const SizedBox(height: AppDimens.space32 * 1.5),

          if (onboarding != null) ...[
            GuideCarBlock(
              onboarding: onboarding,
              isEditable: profile.canEdit,
              onEdit: () => _showEditCarDialog(context, onboarding),
            ),
            const SizedBox(height: AppDimens.space32),

            GuideExperienceBlock(
              onboarding: onboarding,
              isEditable: profile.canEdit,
              onEdit: () => _showEditExperienceDialog(context, onboarding),
            ),
            const SizedBox(height: AppDimens.space32 * 2),
          ],

          GuideActionButtons(
            isVerified: profile.isVerified,
            onCreateTour: profile.isVerified
                ? () => context.push('/guide/tours/create')
                : null,
            onMyTours: profile.isVerified
                ? () => context.push('/guide/tours')
                : null,
            onReuploadDocs: profile.isRejected
                ? () => _goToOnboarding(context, profile)
                : null,
          ),

          const SizedBox(height: AppDimens.space32),

          SizedBox(
            width: double.infinity,
            child: JoluButton(
              text: 'Выйти из аккаунта',
              variant: JoluButtonVariant.outline,
              onPressed: () => _showLogoutDialog(context),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, GuideProfileError state) {
    return Center(
      child: Padding(
        padding: AppDimens.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            JoluButton(
              text: 'Повторить',
              onPressed: () => context.read<GuideProfileCubit>().loadProfile(),
            ),
          ],
        ),
      ),
    );
  }

  void _onAvatarTap(BuildContext context) async {
    final bytes = await ImagePickerUtils().showImagePickerDialog(context);
    if (bytes != null && context.mounted) {
      context.read<GuideProfileCubit>().updateAvatar(bytes);
    }
  }

  void _showEditCarDialog(BuildContext context, OnboardingEntity onboarding) {
    showDialog(
      context: context,
      builder: (_) => _EditCarDialog(
        carModel: onboarding.carModel,
        carNumber: onboarding.carNumber,
        onSave: (model, number) {
          context.read<GuideProfileCubit>().updateProfile(
            carModel: model,
            carNumber: number,
          );
        },
      ),
    );
  }

  void _showEditExperienceDialog(
    BuildContext context,
    OnboardingEntity onboarding,
  ) {
    showDialog(
      context: context,
      builder: (_) => _EditExperienceDialog(
        experienceYears: onboarding.experienceYears,
        languages: onboarding.languages,
        onSave: (years, langs) {
          context.read<GuideProfileCubit>().updateProfile(
            experienceYears: years,
            languages: langs,
          );
        },
      ),
    );
  }

  void _goToOnboarding(BuildContext context, GuideProfileEntity profile) {
    context.push(
      '/guide/onboarding',
      extra: {'guideId': profile.guide.id, 'isReupload': true},
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => JoluDialog(
        title: 'Выход из аккаунта',
        message: 'Вы уверены?',
        icon: Icons.logout_rounded,
        confirmText: 'Выйти',
        onConfirm: () {
          context.read<GuideProfileCubit>().logout();
          context.go('/auth');
        },
      ),
    );
  }
}

class _EditCarDialog extends StatefulWidget {
  final String carModel;
  final String carNumber;
  final Function(String model, String number) onSave;

  const _EditCarDialog({
    required this.carModel,
    required this.carNumber,
    required this.onSave,
  });

  @override
  State<_EditCarDialog> createState() => _EditCarDialogState();
}

class _EditCarDialogState extends State<_EditCarDialog> {
  late final _modelController = TextEditingController(text: widget.carModel);
  late final _numberController = TextEditingController(text: widget.carNumber);

  @override
  void dispose() {
    _modelController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
      ),
      title: Text('Редактировать авто', style: AppTextStyles.headline),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _modelController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Модель',
              labelStyle: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppDimens.space16),
          TextField(
            controller: _numberController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Гос. номер',
              labelStyle: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        JoluButton(
          text: 'Сохранить',
          onPressed: () {
            widget.onSave(_modelController.text, _numberController.text);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// EDIT EXPERIENCE DIALOG
// ═══════════════════════════════════════════════════
class _EditExperienceDialog extends StatefulWidget {
  final int experienceYears;
  final List<String> languages;
  final Function(int years, List<String> languages) onSave;

  const _EditExperienceDialog({
    required this.experienceYears,
    required this.languages,
    required this.onSave,
  });

  @override
  State<_EditExperienceDialog> createState() => _EditExperienceDialogState();
}

class _EditExperienceDialogState extends State<_EditExperienceDialog> {
  late int _years;
  late final Set<String> _selectedLanguages;

  final _allLanguages = const {
    'ru': '🇷🇺 Русский',
    'en': '🇬🇧 English',
    'ky': '🇰🇬 Кыргызча',
  };

  @override
  void initState() {
    super.initState();
    _years = widget.experienceYears;
    _selectedLanguages = Set.from(widget.languages);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
      ),
      title: Text('Опыт и языки', style: AppTextStyles.headline),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Стаж
            Text('Стаж вождения (лет)', style: AppTextStyles.subtitle),
            const SizedBox(height: AppDimens.space12),
            Row(
              children: [
                IconButton(
                  onPressed: _years > 0 ? () => setState(() => _years--) : null,
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '$_years',
                  style: AppTextStyles.title.copyWith(fontSize: 20),
                ),
                IconButton(
                  onPressed: () => setState(() => _years++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space24),

            // Языки
            Text('Языки', style: AppTextStyles.subtitle),
            const SizedBox(height: AppDimens.space12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allLanguages.entries.map((entry) {
                final isSelected = _selectedLanguages.contains(entry.key);
                return FilterChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedLanguages.add(entry.key);
                      } else if (_selectedLanguages.length > 1) {
                        _selectedLanguages.remove(entry.key);
                      }
                    });
                  },
                  backgroundColor: AppColors.cardDark,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        JoluButton(
          text: 'Сохранить',
          onPressed: () {
            widget.onSave(_years, _selectedLanguages.toList());
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
