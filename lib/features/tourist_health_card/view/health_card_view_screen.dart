import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/buttons/jolu_back_button.dart';
import 'package:jolutrip_app/core/ui/buttons/jolu_button.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/tourist_health_card/domain/entities/health_card_entity.dart';

import 'bloc/health_card_cubit.dart';
import 'bloc/health_card_state.dart';

class HealthCardViewScreen extends StatefulWidget {
  const HealthCardViewScreen({super.key});

  @override
  State<HealthCardViewScreen> createState() => _HealthCardViewScreenState();
}

class _HealthCardViewScreenState extends State<HealthCardViewScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HealthCardCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: BlocConsumer<HealthCardCubit, HealthCardState>(
          listener: (context, state) {
            if (state is HealthCardError) {
              JoluSnackbar.show(
                context: context,
                message: state.message,
                type: JoluSnackbarType.error,
              );
            }
          },
          builder: (context, state) {
            if (state is HealthCardLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            HealthCardEntity? card;
            if (state is HealthCardLoaded) card = state.card;
            if (state is HealthCardSaved) card = state.card;

            final hasCard = card != null && card.isFilled;

            return CustomScrollView(
              slivers: [
                // ─── Header ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.space16,
                      AppDimens.space12,
                      AppDimens.space16,
                      AppDimens.space8,
                    ),
                    child: Row(
                      children: [
                        AppBackButton(
                          onPressed: () => context.pop(),
                          style: BackButtonStyle.icon,
                        ),
                        const SizedBox(width: AppDimens.space12),
                        Expanded(
                          child: Text(
                            'Карточка здоровья',
                            style: AppTextStyles.headlineSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(AppDimens.space16),
                  sliver: SliverMainAxisGroup(
                    slivers: [
                      // ─── Hero-баннер ─────────────────────────────
                      SliverToBoxAdapter(child: _buildHeroBanner(card)),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppDimens.space24),
                      ),

                      if (hasCard) ...[
                        // ─── Группа крови (главный акцент) ──────────
                        if (card!.bloodType.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _BloodTypeHero(bloodType: card.bloodType),
                          ),
                        if (card.bloodType.isNotEmpty)
                          const SliverToBoxAdapter(
                            child: SizedBox(height: AppDimens.space20),
                          ),

                        // ─── Аллергии ─────────────────────────────
                        if (card.allergies.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _InfoSection(
                              icon: Icons.warning_amber_rounded,
                              title: 'Аллергии',
                              value: card.allergies,
                              accentColor: AppColors.warning,
                            ),
                          ),
                        if (card.allergies.isNotEmpty)
                          const SliverToBoxAdapter(
                            child: SizedBox(height: AppDimens.space12),
                          ),

                        // ─── Хронические ──────────────────────────
                        if (card.chronicDiseases.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _InfoSection(
                              icon: Icons.favorite_border_rounded,
                              title: 'Хронические заболевания',
                              value: card.chronicDiseases,
                              accentColor: AppColors.error,
                            ),
                          ),
                        if (card.chronicDiseases.isNotEmpty)
                          const SliverToBoxAdapter(
                            child: SizedBox(height: AppDimens.space12),
                          ),

                        // ─── Экстренный контакт ───────────────────
                        if (card.emergencyContact.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _EmergencyContactCard(
                              contact: card.emergencyContact,
                            ),
                          ),
                        if (card.emergencyContact.isNotEmpty)
                          const SliverToBoxAdapter(
                            child: SizedBox(height: AppDimens.space12),
                          ),

                        // ─── Дополнительная инфа ──────────────────
                        if (card.additionalInfo.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _InfoSection(
                              icon: Icons.notes_rounded,
                              title: 'Дополнительно',
                              value: card.additionalInfo,
                              accentColor: AppColors.accent,
                            ),
                          ),
                      ],

                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppDimens.space32),
                      ),

                      // ─── CTA кнопка ─────────────────────────────
                      SliverToBoxAdapter(
                        child: JoluButton(
                          text: hasCard
                              ? 'Редактировать'
                              : 'Заполнить карточку',
                          variant: JoluButtonVariant.primary,
                          size: JoluButtonSize.large,
                          isFullWidth: true,
                          leadingIcon: hasCard
                              ? Icons.edit_outlined
                              : Icons.add_rounded,
                          onPressed: () async {
                            final result = await context.push<bool>(
                              '/tourist/health-card/edit',
                            );
                            if (result == true && mounted) {
                              context.read<HealthCardCubit>().load();
                            }
                          },
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppDimens.space32),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroBanner(HealthCardEntity? card) {
    final isFilled = card != null && card.isFilled;
    return Container(
      padding: const EdgeInsets.all(AppDimens.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFilled
              ? [
                  AppColors.success.withValues(alpha: 0.18),
                  AppColors.accent.withValues(alpha: 0.08),
                ]
              : [
                  AppColors.warning.withValues(alpha: 0.16),
                  AppColors.warning.withValues(alpha: 0.04),
                ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radius20),
        border: Border.all(
          color: (isFilled ? AppColors.success : AppColors.warning).withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isFilled ? AppColors.success : AppColors.warning)
                      .withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFilled
                      ? Icons.verified_user_rounded
                      : Icons.medical_information_rounded,
                  color: isFilled ? AppColors.success : AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFilled ? 'Карточка заполнена' : 'Карточка пуста',
                      style: AppTextStyles.subtitle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isFilled
                          ? 'Эти данные увидит гид при бронировании'
                          : 'Заполните для безопасности в поездках',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Группа крови — большой hero-элемент
// ═══════════════════════════════════════════════════════════════
class _BloodTypeHero extends StatelessWidget {
  final String bloodType;
  const _BloodTypeHero({required this.bloodType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.error.withValues(alpha: 0.3),
                  AppColors.error.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                bloodType,
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.error,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ГРУППА КРОВИ',
                  style: AppTextStyles.accentBadge.copyWith(
                    color: AppColors.error,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _bloodTypeDescription(bloodType),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _bloodTypeDescription(String type) {
    switch (type) {
      case 'O+':
        return 'Первая положительная (I Rh+)';
      case 'O-':
        return 'Первая отрицательная (I Rh-)';
      case 'A+':
        return 'Вторая положительная (II Rh+)';
      case 'A-':
        return 'Вторая отрицательная (II Rh-)';
      case 'B+':
        return 'Третья положительная (III Rh+)';
      case 'B-':
        return 'Третья отрицательная (III Rh-)';
      case 'AB+':
        return 'Четвёртая положительная (IV Rh+)';
      case 'AB-':
        return 'Четвёртая отрицательная (IV Rh-)';
      default:
        return 'Информация о группе крови';
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// Информационная секция
// ═══════════════════════════════════════════════════════════════
class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accentColor;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: AppDimens.space12),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppTextStyles.accentBadge.copyWith(
                    color: accentColor,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space12),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Экстренный контакт — особая карточка
// ═══════════════════════════════════════════════════════════════
class _EmergencyContactCard extends StatelessWidget {
  final EmergencyContact contact;
  const _EmergencyContactCard({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                ),
                child: const Icon(
                  Icons.contact_phone_rounded,
                  color: AppColors.error,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppDimens.space12),
              Expanded(
                child: Text(
                  'ЭКСТРЕННЫЙ КОНТАКТ',
                  style: AppTextStyles.accentBadge.copyWith(
                    color: AppColors.error,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space12),
          Text(
            contact.name,
            style: AppTextStyles.subtitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            contact.phone,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimens.space12),
          // Кнопка быстрого звонка
          InkWell(
            onTap: () async {
              // TODO: использовать url_launcher для звонка
              await Clipboard.setData(ClipboardData(text: contact.phone));
              if (context.mounted) {
                JoluSnackbar.show(
                  context: context,
                  message: 'Номер скопирован',
                  type: JoluSnackbarType.success,
                );
              }
            },
            borderRadius: BorderRadius.circular(AppDimens.radius8),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space12,
                vertical: AppDimens.space8,
              ),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimens.radius8),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.call_rounded, color: AppColors.error, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Позвонить',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
