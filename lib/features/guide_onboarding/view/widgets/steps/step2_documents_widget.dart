import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/cards/add_photo_button_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/cards/document_card_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/cards/photo_preview_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/cards/video_preview_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/info_note_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/onboarding_options.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/shared/section_header_widget.dart';

class Step2DocumentsWidget extends StatelessWidget {
  final Uint8List? passportMainPhotoBytes;
  final Uint8List? passportRegistrationPhotoBytes;
  final Uint8List? licensePhotoFrontBytes;
  final Uint8List? licensePhotoBackBytes;

  /// Ровно [carPhotoSlots].length слотов; null — слот ещё не заполнен.
  final List<Uint8List?> carPhotos;
  final Uint8List? presentationVideoBytes;

  final void Function(Uint8List?) onPassportMainChanged;
  final void Function(Uint8List?) onPassportRegistrationChanged;
  final void Function(Uint8List?) onLicenseFrontChanged;
  final void Function(Uint8List?) onLicenseBackChanged;
  final void Function(int slotIndex, Uint8List? bytes) onCarPhotoChanged;

  final Future<void> Function(void Function(Uint8List)) onPickImage;
  final VoidCallback onPickVideo;
  final VoidCallback onRemoveVideo;

  const Step2DocumentsWidget({
    super.key,
    required this.passportMainPhotoBytes,
    required this.passportRegistrationPhotoBytes,
    required this.licensePhotoFrontBytes,
    required this.licensePhotoBackBytes,
    required this.carPhotos,
    required this.presentationVideoBytes,
    required this.onPassportMainChanged,
    required this.onPassportRegistrationChanged,
    required this.onLicenseFrontChanged,
    required this.onLicenseBackChanged,
    required this.onCarPhotoChanged,
    required this.onPickImage,
    required this.onPickVideo,
    required this.onRemoveVideo,
  });

  int get _passportDone =>
      (passportMainPhotoBytes != null ? 1 : 0) +
      (passportRegistrationPhotoBytes != null ? 1 : 0);

  int get _licenseDone =>
      (licensePhotoFrontBytes != null ? 1 : 0) +
      (licensePhotoBackBytes != null ? 1 : 0);

  int get _carPhotosDone => carPhotos.where((e) => e != null).length;

  int get _totalDone =>
      _passportDone +
      _licenseDone +
      _carPhotosDone +
      (presentationVideoBytes != null ? 1 : 0);

  static const int _totalRequired = 9;

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
          _UploadProgressCard(done: _totalDone, total: _totalRequired),

          const SizedBox(height: AppDimens.space32),

          // ─── Паспорт ────────────────────────────────────────────
          SectionHeaderWidget(
            icon: Icons.credit_card_outlined,
            title: 'Паспорт',
            subtitle: 'Две страницы',
            trailing: SectionCounterBadge(done: _passportDone, total: 2),
          ),
          const SizedBox(height: AppDimens.space16),
          DocumentCardWidget(
            title: 'Главная страница',
            subtitle: 'Страница с фотографией',
            icon: Icons.contact_page_outlined,
            imageBytes: passportMainPhotoBytes,
            hint: 'Все четыре угла в кадре, без бликов',
            onTap: () => onPickImage(onPassportMainChanged),
            onRemove: () => onPassportMainChanged(null),
          ),
          const SizedBox(height: AppDimens.space12),
          DocumentCardWidget(
            title: 'Прописка',
            subtitle: 'Страница с регистрацией',
            icon: Icons.home_outlined,
            imageBytes: passportRegistrationPhotoBytes,
            hint: 'Адрес должен читаться',
            onTap: () => onPickImage(onPassportRegistrationChanged),
            onRemove: () => onPassportRegistrationChanged(null),
          ),

          const SizedBox(height: AppDimens.space32),

          // ─── Права ──────────────────────────────────────────────
          SectionHeaderWidget(
            icon: Icons.badge_outlined,
            title: 'Водительское удостоверение',
            subtitle: 'Обе стороны',
            trailing: SectionCounterBadge(done: _licenseDone, total: 2),
          ),
          const SizedBox(height: AppDimens.space16),
          DocumentCardWidget(
            title: 'Лицевая сторона',
            subtitle: 'Сторона с фотографией',
            icon: Icons.credit_card_outlined,
            imageBytes: licensePhotoFrontBytes,
            hint: 'Проверьте, что видно срок действия',
            onTap: () => onPickImage(onLicenseFrontChanged),
            onRemove: () => onLicenseFrontChanged(null),
          ),
          const SizedBox(height: AppDimens.space12),
          DocumentCardWidget(
            title: 'Оборотная сторона',
            subtitle: 'Сторона с категориями',
            icon: Icons.flip_camera_android_outlined,
            imageBytes: licensePhotoBackBytes,
            hint: 'Категории должны читаться',
            onTap: () => onPickImage(onLicenseBackChanged),
            onRemove: () => onLicenseBackChanged(null),
          ),

          const SizedBox(height: AppDimens.space32),

          // ─── Видео-визитка ──────────────────────────────────────
          SectionHeaderWidget(
            icon: Icons.videocam_outlined,
            title: 'Видео-визитка',
            subtitle: 'Знакомство с гостями',
            trailing: SectionCounterBadge(
              done: presentationVideoBytes != null ? 1 : 0,
              total: 1,
            ),
          ),
          const SizedBox(height: AppDimens.space16),
          VideoPreviewWidget(
            videoBytes: presentationVideoBytes,
            onTap: onPickVideo,
            onRemove: onRemoveVideo,
          ),

          const SizedBox(height: AppDimens.space32),

          // ─── Фото автомобиля ────────────────────────────────────
          SectionHeaderWidget(
            icon: Icons.photo_camera_outlined,
            title: 'Фото автомобиля',
            subtitle: 'Четыре ракурса',
            trailing: SectionCounterBadge(
              done: _carPhotosDone,
              total: carPhotoSlots.length,
            ),
          ),
          const SizedBox(height: AppDimens.space16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimens.space12,
              mainAxisSpacing: AppDimens.space12,
              childAspectRatio: 1.15,
            ),
            itemCount: carPhotoSlots.length,
            itemBuilder: (context, index) {
              final slot = carPhotoSlots[index];
              final bytes = carPhotos[index];

              if (bytes == null) {
                return AddPhotoButtonWidget(
                  label: slot.label,
                  hint: slot.hint,
                  icon: slot.icon,
                  onTap: () => onPickImage(
                    (picked) => onCarPhotoChanged(index, picked),
                  ),
                );
              }

              return PhotoPreviewWidget(
                bytes: bytes,
                label: slot.label,
                onTap: () => onPickImage(
                  (picked) => onCarPhotoChanged(index, picked),
                ),
                onRemove: () => onCarPhotoChanged(index, null),
              );
            },
          ),

          const SizedBox(height: AppDimens.space32),

          const InfoNoteWidget(
            message:
                'Документы передаются по защищённому каналу и видны только '
                'модераторам JoluTrip.',
            tone: InfoNoteTone.success,
            icon: Icons.shield_outlined,
          ),
        ],
      ),
    );
  }
}

/// Общий прогресс загрузки — показывает, сколько ещё осталось,
/// без необходимости листать весь шаг.
class _UploadProgressCard extends StatelessWidget {
  final int done;
  final int total;

  const _UploadProgressCard({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    final isComplete = done >= total;
    final tint = isComplete ? AppColors.success : AppColors.accent;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isComplete ? 'Всё загружено' : 'Загружено файлов',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$done из $total',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tint,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusRound),
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Container(height: 6, color: AppColors.borderDark),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOut,
                    height: 6,
                    width: constraints.maxWidth * ratio,
                    color: tint,
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
