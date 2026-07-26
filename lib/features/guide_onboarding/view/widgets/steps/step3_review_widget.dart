import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/info_note_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/onboarding_options.dart';

class Step3ReviewWidget extends StatelessWidget {
  final String experience;
  final String? carCategory;
  final String carModel;
  final String carNumber;
  final List<String> languages;
  final bool hasPassportMain;
  final bool hasPassportRegistration;
  final bool hasLicenseFront;
  final bool hasLicenseBack;
  final int carPhotosCount;
  final bool hasVideo;

  /// Переход к нужному шагу для правки прямо из сводки.
  final void Function(int step) onEditStep;

  const Step3ReviewWidget({
    super.key,
    required this.experience,
    required this.carCategory,
    required this.carModel,
    required this.carNumber,
    required this.languages,
    required this.hasPassportMain,
    required this.hasPassportRegistration,
    required this.hasLicenseFront,
    required this.hasLicenseBack,
    required this.carPhotosCount,
    required this.hasVideo,
    required this.onEditStep,
  });

  int get _documentsDone =>
      (hasPassportMain ? 1 : 0) +
      (hasPassportRegistration ? 1 : 0) +
      (hasLicenseFront ? 1 : 0) +
      (hasLicenseBack ? 1 : 0) +
      carPhotosCount +
      (hasVideo ? 1 : 0);

  bool get _isEverythingReady => _documentsDone >= 9;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        0,
        AppDimens.space16,
        AppDimens.space32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReadyBanner(isReady: _isEverythingReady),

          const SizedBox(height: AppDimens.space24),

          _ReviewCard(
            icon: Icons.person_outline_rounded,
            title: 'Анкета',
            onEdit: () => onEditStep(0),
            children: [
              _ReviewRow(
                label: 'Стаж',
                value: experience.isEmpty ? '—' : '$experience лет',
              ),
              _ReviewRow(
                label: 'Категория',
                value: carCategoryLabel(carCategory),
              ),
              _ReviewRow(
                label: 'Автомобиль',
                value: carModel.isEmpty ? '—' : carModel,
              ),
              _ReviewRow(
                label: 'Гос. номер',
                value: carNumber.isEmpty ? '—' : carNumber.toUpperCase(),
              ),
              _ReviewRow(
                label: 'Языки',
                value: languages.isEmpty
                    ? '—'
                    : languages.map(languageLabel).join(', '),
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: AppDimens.space16),

          _ReviewCard(
            icon: Icons.folder_outlined,
            title: 'Документы',
            trailing: Text(
              '$_documentsDone/9',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: _isEverythingReady
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ),
            onEdit: () => onEditStep(1),
            children: [
              _ChecklistRow(
                label: 'Паспорт — главная',
                isDone: hasPassportMain,
              ),
              _ChecklistRow(
                label: 'Паспорт — прописка',
                isDone: hasPassportRegistration,
              ),
              _ChecklistRow(
                label: 'Права — лицевая',
                isDone: hasLicenseFront,
              ),
              _ChecklistRow(
                label: 'Права — оборот',
                isDone: hasLicenseBack,
              ),
              _ChecklistRow(
                label: 'Видео-визитка',
                isDone: hasVideo,
              ),
              _ChecklistRow(
                label: 'Фото автомобиля',
                isDone: carPhotosCount >= carPhotoSlots.length,
                value: '$carPhotosCount из ${carPhotoSlots.length}',
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: AppDimens.space24),

          const InfoNoteWidget(
            message:
                'После отправки данные нельзя менять до окончания проверки. '
                'Обычно она занимает до 24 часов.',
            tone: InfoNoteTone.warning,
          ),
        ],
      ),
    );
  }
}

// ─── Баннер готовности ─────────────────────────────────────────────────
class _ReadyBanner extends StatelessWidget {
  final bool isReady;

  const _ReadyBanner({required this.isReady});

  @override
  Widget build(BuildContext context) {
    final tint = isReady ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tint.withValues(alpha: 0.16),
            tint.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radius20),
        border: Border.all(color: tint.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isReady
                  ? Icons.rocket_launch_rounded
                  : Icons.pending_actions_rounded,
              color: tint,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isReady ? 'Всё готово к отправке' : 'Чего-то не хватает',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 4),
                Text(
                  isReady
                      ? 'Проверьте данные и отправляйте анкету на модерацию.'
                      : 'Вернитесь на предыдущий шаг и добавьте недостающие файлы.',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    height: 1.35,
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

// ─── Карточка группы ───────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  final VoidCallback onEdit;
  final Widget? trailing;

  const _ReviewCard({
    required this.icon,
    required this.title,
    required this.children,
    required this.onEdit,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.space16,
              AppDimens.space12,
              AppDimens.space8,
              AppDimens.space12,
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.accent),
                const SizedBox(width: AppDimens.space10),
                Expanded(child: Text(title, style: AppTextStyles.title)),
                if (trailing != null) ...[
                  trailing!,
                  const SizedBox(width: AppDimens.space8),
                ],
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  label: const Text('Изменить'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.space8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDark),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.space16,
              AppDimens.space12,
              AppDimens.space16,
              AppDimens.space12,
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _ReviewRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppDimens.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: AppTextStyles.subtext.copyWith(fontSize: 13)),
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final String label;
  final bool isDone;
  final String? value;
  final bool isLast;

  const _ChecklistRow({
    required this.label,
    required this.isDone,
    this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final tint = isDone ? AppColors.success : AppColors.warning;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppDimens.space12),
      child: Row(
        children: [
          Icon(
            isDone
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 17,
            color: tint,
          ),
          const SizedBox(width: AppDimens.space10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value ?? (isDone ? 'Готово' : 'Нет файла'),
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: tint,
            ),
          ),
        ],
      ),
    );
  }
}
