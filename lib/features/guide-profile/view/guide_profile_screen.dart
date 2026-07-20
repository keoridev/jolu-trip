import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/core/utils/image_picker_utils.dart';
import 'package:jolutrip_app/features/guide-profile/domain/entities/entities.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_cubit.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_state.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/blocks/guide_profile_experience.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/modals/edit_car_sheet.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/modals/edit_experience_sheet.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/blocks/guide_profile_car.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/sections/guide_profile_header.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/sections/guide_profile_media_grid.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/sections/guide_status_banner.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/shared/guide_action_buttons.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/states/guide_profile_error.dart';
import 'package:jolutrip_app/features/guide-profile/view/widgets/states/guide_profile_skeleton.dart';

// ═══════════════════════════════════════════════════════════════
// MODERATION WARNING SHEET (встроен в этот файл)
// ═══════════════════════════════════════════════════════════════

/// Предупреждение перед редактированием полей, требующих повторной модерации.
///
/// Критичные поля (требуют предупреждения):
/// - Фото профиля
/// - Видео-визитка
/// - Машина (модель, номер, фото)
///
/// Некритичные поля (без предупреждения):
/// - Языки
/// - Опыт (лет)
class ModerationWarningSheet extends StatelessWidget {
  final String fieldName;
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  const ModerationWarningSheet({
    super.key,
    required this.fieldName,
    required this.onContinue,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimens.space20,
        right: AppDimens.space20,
        top: AppDimens.space16,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.space24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.space24),

          // Warning icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusL),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(height: AppDimens.space16),

          // Title
          Text(
            'Изменение $fieldName',
            style: AppTextStyles.subtitle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimens.space8),

          // Description
          Text(
            'Если вы измените $fieldName, ваш профиль отправится на повторную проверку. '
            'Во время модерации вы не сможете создавать новые туры.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppDimens.space24),

          // Impact list
          _ImpactItem(
            icon: Icons.timer_outlined,
            text: 'Профиль на проверке — туры недоступны',
            isNegative: true,
          ),
          const SizedBox(height: AppDimens.space12),
          _ImpactItem(
            icon: Icons.check_circle_outline,
            text: 'После одобрения всё восстановится',
            isNegative: false,
          ),
          const SizedBox(height: AppDimens.space32),

          // Primary CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.space14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
                elevation: 0,
              ),
              child: Text(
                'Понятно, продолжить',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.space12),

          // Secondary CTA
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.space12,
                ),
              ),
              child: Text(
                'Отмена',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isNegative;

  const _ImpactItem({
    required this.icon,
    required this.text,
    required this.isNegative,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isNegative ? AppColors.warning : AppColors.success,
        ),
        const SizedBox(width: AppDimens.space10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// GUIDE PROFILE SCREEN
// ═══════════════════════════════════════════════════════════════

/// Редизайн экрана профиля гида.
///
/// Новая структура:
/// 1. Хедер с аватаром (имя, статус, верификация)
/// 2. Видео-визитка (главный блок доверия)
/// 3. Мои туры (горизонтальная карусель)
/// 4. Автомобиль (фото + характеристики)
/// 5. Опыт и языки (бейдж + чипы)
/// 6. Действия (Создать тур / Мои туры / Выйти)
///
/// UX-принципы:
/// - Статистика с нулями скрыта (убивает доверие)
/// - Статус интегрирован в хедер, не отдельный баннер
/// - Редактирование — текстовые ссылки, не иконки-карандаши
/// - CTA "Создать тур" — фиксированный primary внизу
/// - Предупреждение перед редактированием критичных полей
class GuideProfileScreen extends StatefulWidget {
  const GuideProfileScreen({super.key});

  @override
  State<GuideProfileScreen> createState() => _GuideProfileScreenState();
}

class _GuideProfileScreenState extends State<GuideProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GuideProfileCubit>().loadProfile();
  }

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
            // 🔥 Редирект при выходе или если аккаунт не найден
            if (state is GuideProfileNotFound ||
                state is GuideProfileLoggedOut) {
              context.go('/login');
            }
          },
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: switch (state) {
                GuideProfileInitial() || GuideProfileLoading() =>
                  const GuideProfileSkeleton(key: ValueKey('skeleton')),
                GuideProfileLoaded(profile: final profile) => _ProfileContent(
                  key: const ValueKey('loaded'),
                  profile: profile,
                ),
                GuideProfileError() => GuideProfileErrorWidget(
                  key: const ValueKey('error'),
                  state: state,
                ),
                GuideProfileNotFound() || GuideProfileLoggedOut() =>
                  const SizedBox.shrink(key: ValueKey('redirect')),
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final GuideProfileEntity profile;

  const _ProfileContent({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // === HEADER ===
        SliverToBoxAdapter(
          child: GuideProfileHeader(
            profile: profile,
            onAvatarTap: profile.canEdit
                ? () => _onEditCriticalField(
                    context,
                    fieldName: 'фото профиля',
                    onContinue: () => _onAvatarTap(context),
                  )
                : null,
          ),
        ),

        // === STATUS BANNER ===
        if (!profile.isOnboardingComplete ||
            profile.isPending ||
            profile.isRejected)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space20,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppDimens.space16),
                  GuideStatusBanner(profile: profile),
                ],
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: AppDimens.space24)),

        // === MEDIA GRID ===
        SliverToBoxAdapter(
          child: GuideProfileMediaGrid(
            profile: profile,
            onEditVideo: profile.canEdit
                ? () => _onEditCriticalField(
                    context,
                    fieldName: 'видео-визитку',
                    onContinue: () => _pickVideo(context),
                  )
                : null,
          ),
        ),

        // === CAR BLOCK ===
        const SliverToBoxAdapter(child: SizedBox(height: AppDimens.space24)),
        SliverToBoxAdapter(
          child: GuideCarBlock(
            onboarding: profile.toOnboarding(),
            isEditable: profile.canEdit,
            onEdit: () => _onEditCriticalField(
              context,
              fieldName: 'машину',
              onContinue: () => _showEditCarSheet(context),
            ),
          ),
        ),

        // === EXPERIENCE & LANGUAGES ===
        const SliverToBoxAdapter(child: SizedBox(height: AppDimens.space16)),
        SliverToBoxAdapter(
          child: GuideExperienceBlock(
            onboarding: profile.toOnboarding(),
            isEditable: profile.canEdit,
            onEdit: () => _showEditExperienceSheet(context),
          ),
        ),

        // === ACTION BUTTONS ===
        const SliverToBoxAdapter(child: SizedBox(height: AppDimens.space24)),
        SliverToBoxAdapter(
          child: GuideActionButtons(
            profile: profile,
            isLoading: false,
            onLogout: () => context
                .read<GuideProfileCubit>()
                .logout(), // ← здесь получаем Cubit
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppDimens.space32)),
      ],
    );
  }

  void _onEditCriticalField(
    BuildContext context, {
    required String fieldName,
    required VoidCallback onContinue,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModerationWarningSheet(
        fieldName: fieldName,
        onContinue: () {
          Navigator.of(context).pop();
          onContinue();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _onAvatarTap(BuildContext context) async {
    final bytes = await ImagePickerUtils().showImagePickerDialog(context);
    if (bytes != null && context.mounted) {
      context.read<GuideProfileCubit>().updateAvatar(bytes);
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 2),
    );

    if (pickedFile != null && context.mounted) {
      final bytes = await File(pickedFile.path).readAsBytes();
      context.read<GuideProfileCubit>().updatePresentationVideo(bytes);
    }
  }

  void _showEditCarSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditCarSheet(
        carModel: profile.carModel ?? '',
        carNumber: profile.carNumber ?? '',
        onSave: (model, number) {
          context.read<GuideProfileCubit>().updateCar(model, number);
        },
      ),
    );
  }

  void _showEditExperienceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditExperienceSheet(
        experienceYears: profile.experienceYears,
        languages: profile.languages,
        onSave: (years, languages) {
          context.read<GuideProfileCubit>().updateExperience(years, languages);
        },
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════════
// HELPER WIDGETS (без изменений)
// ═══════════════════════════════════════════════════════════════

class _EmptyToursState extends StatelessWidget {
  final VoidCallback? onCreateTour;

  const _EmptyToursState({this.onCreateTour});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space32),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(
          color: AppColors.borderDark,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.map_outlined,
            size: 40,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppDimens.space12),
          Text(
            'Пока нет туров',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: AppDimens.space4),
          Text(
            'Создайте первый тур, чтобы туристы вас нашли',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onCreateTour != null) ...[
            const SizedBox(height: AppDimens.space16),
            _CreateTourMiniButton(onPressed: onCreateTour),
          ],
        ],
      ),
    );
  }
}

class _CreateTourMiniButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _CreateTourMiniButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space10,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 16),
            const SizedBox(width: AppDimens.space6),
            Text(
              'Создать тур',
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToursCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mockTours = [
      _TourMini('Поход к озеру Ала-Куль', 'от 4 500 сом'),
      _TourMini('Джеты-Огуз — Сказка', 'от 3 200 сом'),
      _TourMini('Бурана + Конь', 'от 2 800 сом'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < mockTours.length; i++) ...[
            _TourMiniCard(tour: mockTours[i]),
            if (i < mockTours.length - 1)
              const SizedBox(width: AppDimens.space12),
          ],
        ],
      ),
    );
  }
}

class _TourMini {
  final String title;
  final String price;

  const _TourMini(this.title, this.price);
}

class _TourMiniCard extends StatelessWidget {
  final _TourMini tour;

  const _TourMiniCard({required this.tour});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusL),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                color: AppColors.bgElevated,
                child: Center(
                  child: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.space10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tour.title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimens.space4),
                Text(
                  tour.price,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
