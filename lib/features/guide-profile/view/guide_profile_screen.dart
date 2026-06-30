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
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: switch (state) {
                GuideProfileInitial() ||
                GuideProfileLoading() => const _ProfileSkeleton(),
                GuideProfileLoaded(profile: final profile) => _ProfileContent(
                  key: const ValueKey('loaded'),
                  profile: profile,
                ),
                GuideProfileError() => _ProfileError(state: state),
                GuideProfileState() => throw UnimplementedError(),
              },
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// SKELETON LOADING
// ═══════════════════════════════════════════════════
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: AppDimens.space16),
          // Avatar skeleton
          _buildSkeletonCircle(80),
          const SizedBox(height: AppDimens.space16),
          _buildSkeletonBox(width: 150, height: 20),
          const SizedBox(height: 8),
          _buildSkeletonBox(width: 100, height: 14),
          const SizedBox(height: AppDimens.space32),
          // Cards skeleton
          _buildSkeletonCard(height: 120),
          const SizedBox(height: AppDimens.space16),
          _buildSkeletonCard(height: 100),
          const SizedBox(height: AppDimens.space16),
          _buildSkeletonCard(height: 80),
        ],
      ),
    );
  }

  Widget _buildSkeletonCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSkeletonBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
    );
  }

  Widget _buildSkeletonCard({required double height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// LOADED CONTENT
// ═══════════════════════════════════════════════════
class _ProfileContent extends StatelessWidget {
  final GuideProfileEntity profile;

  const _ProfileContent({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final onboarding = profile.onboarding;

    return CustomScrollView(
      slivers: [
        // Header with gradient
        SliverToBoxAdapter(
          child: _ProfileHeaderCard(
            profile: profile,
            onAvatarTap: profile.canEdit ? () => _onAvatarTap(context) : null,
          ),
        ),

        // Status banner (if pending/rejected)
        if (profile.isPending || profile.isRejected)
          SliverToBoxAdapter(
            child: Padding(
              padding: AppDimens.screenPadding.copyWith(top: 0, bottom: 0),
              child: Column(
                children: [
                  const SizedBox(height: AppDimens.space16),
                  GuideStatusBanner(profile: profile),
                ],
              ),
            ),
          ),

        // Info cards
        SliverToBoxAdapter(
          child: Padding(
            padding: AppDimens.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimens.space24),

                // Car info
                if (onboarding != null) ...[
                  _InfoCard(
                    icon: Icons.directions_car_rounded,
                    title: 'Транспорт',
                    subtitle:
                        '${onboarding.carModel} • ${onboarding.carNumber}',
                    onEdit: profile.canEdit
                        ? () => _showEditCarBottomSheet(context, onboarding)
                        : null,
                  ),
                  const SizedBox(height: AppDimens.space16),

                  // Experience
                  _InfoCard(
                    icon: Icons.verified_user_rounded,
                    title: 'Опыт и языки',
                    subtitle:
                        '${onboarding.experienceYears} лет • ${onboarding.languages.join(', ')}',
                    onEdit: profile.canEdit
                        ? () => _showEditExperienceBottomSheet(
                            context,
                            onboarding,
                          )
                        : null,
                  ),
                  const SizedBox(height: AppDimens.space16),
                ],

                // Actions section
                Text('Действия', style: AppTextStyles.subtitle),
                const SizedBox(height: AppDimens.space12),
                _ActionCard(
                  icon: Icons.add_circle_rounded,
                  title: 'Создать тур',
                  subtitle: 'Новое путешествие',
                  color: AppColors.primary,
                  onTap: () => context.push('/guide/tours/create'),
                ),
                const SizedBox(height: AppDimens.space12),
                _ActionCard(
                  icon: Icons.list_alt_rounded,
                  title: 'Мои туры',
                  subtitle: 'Управление турами',
                  color: AppColors.textPrimary,
                  onTap: () => context.push('/guide/tours'),
                ),
                const SizedBox(height: AppDimens.space12),
                if (profile.isRejected)
                  _ActionCard(
                    icon: Icons.upload_file_rounded,
                    title: 'Перезагрузить документы',
                    subtitle: 'Исправить и отправить заново',
                    color: AppColors.warning,
                    onTap: () => _goToOnboarding(context, profile),
                  ),

                const SizedBox(height: AppDimens.space32),

                // Logout
                SizedBox(
                  width: double.infinity,
                  child: JoluButton(
                    text: 'Выйти из аккаунта',
                    variant: JoluButtonVariant.outline,
                    leadingIcon: Icons.logout_rounded,
                    onPressed: () => _showLogoutBottomSheet(context),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onAvatarTap(BuildContext context) async {
    final bytes = await ImagePickerUtils().showImagePickerDialog(context);
    if (bytes != null && context.mounted) {
      context.read<GuideProfileCubit>().updateAvatar(bytes);
    }
  }

  void _showEditCarBottomSheet(
    BuildContext context,
    OnboardingEntity onboarding,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _EditCarSheet(
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

  void _showEditExperienceBottomSheet(
    BuildContext context,
    OnboardingEntity onboarding,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _EditExperienceSheet(
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

  void _showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.logout_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Выйти из аккаунта?', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            Text(
              'Вы уверены что хотите выйти?',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: JoluButton(
                    text: 'Отмена',
                    variant: JoluButtonVariant.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: JoluButton(
                    text: 'Выйти',
                    variant: JoluButtonVariant.primary,
                    onPressed: () {
                      Navigator.pop(context);
                      Future.microtask(() {
                        if (context.mounted) {
                          context.read<GuideProfileCubit>().logout();
                          context.pushReplacement('/auth');
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// PROFILE HEADER CARD
// ═══════════════════════════════════════════════════
class _ProfileHeaderCard extends StatelessWidget {
  final GuideProfileEntity profile;
  final VoidCallback? onAvatarTap;

  const _ProfileHeaderCard({required this.profile, this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppDimens.screenPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.cardDark,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radius20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar with status badge
            Stack(
              children: [
                GestureDetector(
                  onTap: onAvatarTap,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _getStatusColor(), width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.cardDark,
                      backgroundImage: profile.guide.avatarUrl != null
                          ? NetworkImage(profile.guide.avatarUrl!)
                          : null,
                      child: profile.guide.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
                // Status badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.bgDark, width: 2),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Name
            Text(
              profile.guide.fullName ?? 'Гид',
              style: AppTextStyles.headline.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 4),
            // Phone
            Text(
              profile.guide.phone,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            // Rating or status info
            if (profile.isVerified)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified,
                    color: AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Верифицированный гид',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (profile.isVerified) return AppColors.success;
    if (profile.isPending) return AppColors.warning;
    if (profile.isRejected) return AppColors.error;
    return AppColors.textSecondary;
  }

  String _getStatusText() {
    if (profile.isVerified) return 'VERIFIED';
    if (profile.isPending) return 'PENDING';
    if (profile.isRejected) return 'REJECTED';
    return 'NEW';
  }
}

// ═══════════════════════════════════════════════════
// INFO CARD
// ═══════════════════════════════════════════════════
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onEdit;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.body.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(
                Icons.edit_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// STATS ROW
// ═══════════════════════════════════════════════════

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.title.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// ACTION CARD
// ═══════════════════════════════════════════════════
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.subtitle.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// ERROR STATE
// ═══════════════════════════════════════════════════
class _ProfileError extends StatelessWidget {
  final GuideProfileError state;

  const _ProfileError({required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppDimens.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 64),
            const SizedBox(height: 24),
            Text(
              'Не удалось загрузить профиль',
              style: AppTextStyles.headline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            JoluButton(
              text: 'Повторить',
              leadingIcon: Icons.refresh_rounded,
              onPressed: () => context.read<GuideProfileCubit>().loadProfile(),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// EDIT CAR BOTTOM SHEET
// ═══════════════════════════════════════════════════
class _EditCarSheet extends StatefulWidget {
  final String carModel;
  final String carNumber;
  final Function(String model, String number) onSave;

  const _EditCarSheet({
    required this.carModel,
    required this.carNumber,
    required this.onSave,
  });

  @override
  State<_EditCarSheet> createState() => _EditCarSheetState();
}

class _EditCarSheetState extends State<_EditCarSheet> {
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
    return _BottomSheetWrapper(
      title: 'Редактировать авто',
      icon: Icons.directions_car_rounded,
      onSave: () {
        widget.onSave(_modelController.text, _numberController.text);
        Navigator.pop(context);
      },
      children: [
        _buildTextField(
          controller: _modelController,
          label: 'Модель автомобиля',
          icon: Icons.car_rental_rounded,
        ),
        const SizedBox(height: AppDimens.space16),
        _buildTextField(
          controller: _numberController,
          label: 'Гос. номер',
          icon: Icons.pin_rounded,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// EDIT EXPERIENCE BOTTOM SHEET
// ═══════════════════════════════════════════════════
class _EditExperienceSheet extends StatefulWidget {
  final int experienceYears;
  final List<String> languages;
  final Function(int years, List<String> languages) onSave;

  const _EditExperienceSheet({
    required this.experienceYears,
    required this.languages,
    required this.onSave,
  });

  @override
  State<_EditExperienceSheet> createState() => _EditExperienceSheetState();
}

class _EditExperienceSheetState extends State<_EditExperienceSheet> {
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
    return _BottomSheetWrapper(
      title: 'Опыт и языки',
      icon: Icons.verified_user_rounded,
      onSave: () {
        widget.onSave(_years, _selectedLanguages.toList());
        Navigator.pop(context);
      },
      children: [
        Text('Стаж вождения', style: AppTextStyles.subtitle),
        const SizedBox(height: AppDimens.space12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CircleButton(
              icon: Icons.remove,
              onPressed: _years > 0 ? () => setState(() => _years--) : null,
            ),
            const SizedBox(width: 24),
            Text(
              '$_years',
              style: AppTextStyles.headline.copyWith(fontSize: 32),
            ),
            const SizedBox(width: 24),
            _CircleButton(
              icon: Icons.add,
              onPressed: () => setState(() => _years++),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.space24),
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
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// BOTTOM SHEET WRAPPER
// ═══════════════════════════════════════════════════
class _BottomSheetWrapper extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onSave;
  final List<Widget> children;

  const _BottomSheetWrapper({
    required this.title,
    required this.icon,
    required this.onSave,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 16),
          // Title
          Text(title, style: AppTextStyles.headline),
          const SizedBox(height: 24),
          // Content
          Padding(
            padding: AppDimens.screenPadding,
            child: Column(mainAxisSize: MainAxisSize.min, children: children),
          ),
          const SizedBox(height: 24),
          // Actions
          Padding(
            padding: AppDimens.screenPadding,
            child: Row(
              children: [
                Expanded(
                  child: JoluButton(
                    text: 'Отмена',
                    variant: JoluButtonVariant.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: JoluButton(text: 'Сохранить', onPressed: onSave),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CircleButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
}) {
  return TextFormField(
    controller: controller,
    style: const TextStyle(color: AppColors.textPrimary),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.bgDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    ),
  );
}
