import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/cards/add_photo_button_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/cards/document_card_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/cards/photo_preview_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/view/widgets/cards/video_preview_widget.dart';

class Step2DocumentsWidget extends StatelessWidget {
  final Uint8List? passportMainPhotoBytes;
  final Uint8List? passportRegistrationPhotoBytes;
  final Uint8List? licensePhotoFrontBytes;
  final Uint8List? licensePhotoBackBytes;
  final List<Uint8List> carPhotosBytes;
  final Uint8List? presentationVideoBytes;

  final Function(Uint8List) onPickPassportMain;
  final Function(Uint8List) onPickPassportRegistration;
  final Function(Uint8List) onPickLicenseFront;
  final Function(Uint8List) onPickLicenseBack;
  final Function(Uint8List) onAddCarPhoto;
  final Function(int) onRemoveCarPhoto;
  final Future<void> Function(Function(Uint8List)) onPickImage;
  final VoidCallback onPickVideo;
  final VoidCallback onRemoveVideo;

  const Step2DocumentsWidget({
    super.key,
    required this.passportMainPhotoBytes,
    required this.passportRegistrationPhotoBytes,
    required this.licensePhotoFrontBytes,
    required this.licensePhotoBackBytes,
    required this.carPhotosBytes,
    required this.presentationVideoBytes,
    required this.onPickPassportMain,
    required this.onPickPassportRegistration,
    required this.onPickLicenseFront,
    required this.onPickLicenseBack,
    required this.onAddCarPhoto,
    required this.onRemoveCarPhoto,
    required this.onPickImage,
    required this.onPickVideo,
    required this.onRemoveVideo,
  });

  int get _uploadedCount {
    int count = 0;
    if (passportMainPhotoBytes != null) count++;
    if (passportRegistrationPhotoBytes != null) count++;
    if (licensePhotoFrontBytes != null) count++;
    if (licensePhotoBackBytes != null) count++;
    count += carPhotosBytes.length;
    if (presentationVideoBytes != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimens.space32),

          Row(
            children: [
              Expanded(child: Text('Документы', style: AppTextStyles.headline)),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_uploadedCount/9',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space12),
          Text(
            'Загрузите документы и видео-визитку для верификации.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.space32 * 1.5),

          // Паспорт: главная страница
          DocumentCardWidget(
            title: 'Паспорт: главная страница',
            subtitle: 'Страница с фото',
            icon: Icons.credit_card_outlined,
            imageBytes: passportMainPhotoBytes,
            onTap: () => onPickImage((bytes) => onPickPassportMain(bytes)),
            hint: 'Чёткое фото главного разворота',
          ),
          const SizedBox(height: AppDimens.space16),

          // Паспорт: прописка
          DocumentCardWidget(
            title: 'Паспорт: прописка',
            subtitle: 'Страница с регистрацией',
            icon: Icons.home_outlined,
            imageBytes: passportRegistrationPhotoBytes,
            onTap: () => onPickImage((bytes) => onPickPassportRegistration(bytes)),
            hint: 'Страница с адресом регистрации',
          ),
          const SizedBox(height: AppDimens.space24),

          // Права: лицевая сторона
          DocumentCardWidget(
            title: 'Права: лицевая сторона',
            subtitle: 'Фото с вашим изображением',
            icon: Icons.badge_outlined,
            imageBytes: licensePhotoFrontBytes,
            onTap: () => onPickImage((bytes) => onPickLicenseFront(bytes)),
            hint: 'Сфотографируйте лицевую сторону',
          ),
          const SizedBox(height: AppDimens.space16),

          // Права: оборотная сторона
          DocumentCardWidget(
            title: 'Права: оборотная сторона',
            subtitle: 'Обратная сторона прав',
            icon: Icons.flip_camera_android_outlined,
            imageBytes: licensePhotoBackBytes,
            onTap: () => onPickImage((bytes) => onPickLicenseBack(bytes)),
            hint: 'Сфотографируйте оборотную сторону',
          ),
          const SizedBox(height: AppDimens.space24),

          // Видео-визитка
          VideoPreviewWidget(
            videoBytes: presentationVideoBytes,
            onTap: onPickVideo,
            onRemove: onRemoveVideo,
          ),
          const SizedBox(height: AppDimens.space24),

          // Фото автомобиля
          Text('Фото автомобиля', style: AppTextStyles.title),
          const SizedBox(height: AppDimens.space16),
          Text(
            'Ровно 4 фото: спереди, сзади, салон, багажник',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.space16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: carPhotosBytes.length < 4 ? carPhotosBytes.length + 1 : 4,
            itemBuilder: (context, index) {
              if (index == carPhotosBytes.length && carPhotosBytes.length < 4) {
                return AddPhotoButtonWidget(
                  onTap: () => onPickImage((bytes) => onAddCarPhoto(bytes)),
                );
              }
              return PhotoPreviewWidget(
                bytes: carPhotosBytes[index],
                index: index,
                onRemove: () => onRemoveCarPhoto(index),
              );
            },
          ),

          const SizedBox(height: AppDimens.space32),

          // Security note
          Container(
            padding: const EdgeInsets.all(AppDimens.space16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ваши данные в безопасности. Все документы проверяются в зашифрованном виде.',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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