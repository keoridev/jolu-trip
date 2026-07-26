import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/di/service_locator.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/feedback/jolu_snackbar.dart';
import 'package:jolutrip_app/features/gamification/view/blocs/checkin/checkin_cubit.dart';
import 'package:jolutrip_app/features/gamification/view/blocs/checkin/checkin_state.dart';
import 'package:jolutrip_app/features/gamification/view/blocs/stamps/stamps_cubit.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';

/// Чекин на месте.
///
/// Раньше это была третья по счёту зелёная кнопка на всю ширину — рядом с
/// двумя такими же в нижней панели, и было непонятно, какая из них главная.
/// Теперь это карточка с собственным контекстом: понятно, зачем нажимать.
class LocationCheckinCard extends StatelessWidget {
  final LocationDetailEntity location;

  const LocationCheckinCard({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CheckinCubit>(),
      child: _CheckinBody(location: location),
    );
  }
}

class _CheckinBody extends StatelessWidget {
  final LocationDetailEntity location;

  const _CheckinBody({required this.location});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckinCubit, CheckinState>(
      listener: (context, state) {
        if (state is CheckinSuccess) {
          HapticFeedback.mediumImpact();
          context.read<StampsCubit>().onCheckinCompleted(state.newStamps);

          JoluSnackbar.show(
            context: context,
            message: 'Вы отметились в «${state.locationName}»',
            type: JoluSnackbarType.success,
            duration: const Duration(seconds: 2),
          );

          if (state.newStamps.isNotEmpty) {
            // Роутер берём заранее: через 500ms этот context может быть уже
            // отмонтирован, и поиск по дереву упал бы с исключением.
            final router = GoRouter.of(context);
            Future.delayed(
              const Duration(milliseconds: 600),
              () => router.push('/stamps'),
            );
          }
        } else if (state is CheckinFailure) {
          HapticFeedback.heavyImpact();
          JoluSnackbar.show(
            context: context,
            message: state.message,
            type: JoluSnackbarType.error,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is CheckinValidating;
        final isDone = state is CheckinSuccess;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppDimens.space16),
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            border: Border.all(
              color: isDone
                  ? AppColors.success.withValues(alpha: 0.4)
                  : AppColors.borderDark,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: AppDimens.avatar48,
                    height: AppDimens.avatar48,
                    decoration: BoxDecoration(
                      color: (isDone ? AppColors.success : AppColors.accent)
                          .withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppDimens.radius14),
                    ),
                    child: Icon(
                      isDone
                          ? Icons.verified_rounded
                          : Icons.workspace_premium_outlined,
                      color: isDone ? AppColors.success : AppColors.accent,
                      size: AppDimens.icon24,
                    ),
                  ),
                  const SizedBox(width: AppDimens.space14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDone ? 'Локация отмечена' : 'Уже на месте?',
                          style: AppTextStyles.subtitle,
                        ),
                        const SizedBox(height: AppDimens.space4),
                        Text(
                          isDone
                              ? 'Штамп добавлен в вашу коллекцию'
                              : 'Отметьтесь и получите штамп в коллекцию',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isDone) ...[
                const SizedBox(height: AppDimens.space16),
                SizedBox(
                  width: double.infinity,
                  height: AppDimens.buttonMinHeight,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () => _checkin(context),
                    icon: isLoading
                        ? const SizedBox(
                            width: AppDimens.icon20,
                            height: AppDimens.icon20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : const Icon(
                            Icons.where_to_vote_outlined,
                            size: AppDimens.icon20,
                          ),
                    label: Text(
                      isLoading ? 'Проверяем геопозицию…' : 'Я здесь',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.4,
                      ),
                      disabledForegroundColor: AppColors.textSecondary,
                      textStyle: AppTextStyles.button.copyWith(fontSize: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusM),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _checkin(BuildContext context) {
    HapticFeedback.selectionClick();
    context.read<CheckinCubit>().checkin(
      locationId: location.id,
      locationName: location.name,
      locationLat: location.latitude,
      locationLng: location.longitude,
      locationTags: location.roadFeatures,
    );
  }
}
