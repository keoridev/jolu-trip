// lib/features/guide_onboarding/presentation/widgets/steps/step2_documents_widget.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide_onboarding/screens/widgets/cards/add_photo_button_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/screens/widgets/cards/document_card_widget.dart';
import 'package:jolutrip_app/features/guide_onboarding/screens/widgets/cards/photo_preview_widget.dart';

class Step2DocumentsWidget extends StatelessWidget {
  final Uint8List? passportScanBytes;
  final Uint8List? licensePhotoBytes;
  final List<Uint8List> carPhotosBytes;
  final Function(Uint8List) onPickPassport;
  final Function(Uint8List) onPickLicense;
  final Function(Uint8List) onAddCarPhoto;
  final Function(int) onRemoveCarPhoto;
  final Future<void> Function(Function(Uint8List)) onPickImage;

  const Step2DocumentsWidget({
    super.key,
    required this.passportScanBytes,
    required this.licensePhotoBytes,
    required this.carPhotosBytes,
    required this.onPickPassport,
    required this.onPickLicense,
    required this.onAddCarPhoto,
    required this.onRemoveCarPhoto,
    required this.onPickImage,
  });

  int get _uploadedCount {
    int count = 0;
    if (passportScanBytes != null) count++;
    if (licensePhotoBytes != null) count++;
    count += carPhotosBytes.length;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppDimens.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimens.spaceXL),

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
                  '$_uploadedCount/6',
                  style: AppTextStyles.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceS),
          Text(
            'Загрузите документы для верификации. Это займёт не больше минуты.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.spaceXL * 1.5),

          DocumentCardWidget(
            title: 'Паспорт',
            subtitle: 'Главная страница с фото',
            icon: Icons.credit_card_outlined,
            imageBytes: passportScanBytes,
            onTap: () => onPickImage((bytes) => onPickPassport(bytes)),
            hint: 'Чёткое фото главного разворота',
          ),
          const SizedBox(height: AppDimens.spaceL),

          DocumentCardWidget(
            title: 'Водительские права',
            subtitle: 'Фото прав (обе стороны)',
            icon: Icons.badge_outlined,
            imageBytes: licensePhotoBytes,
            onTap: () => onPickImage((bytes) => onPickLicense(bytes)),
            hint: 'Сфотографируйте обе стороны или сделайте коллаж',
          ),
          const SizedBox(height: AppDimens.spaceL),

          Text('Фото автомобиля', style: AppTextStyles.title),
          const SizedBox(height: AppDimens.spaceM),
          Text(
            'Сделайте 4 фото: спереди, сзади, салон, багажник',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppDimens.spaceM),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: carPhotosBytes.length + 1,
            itemBuilder: (context, index) {
              if (index == carPhotosBytes.length) {
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

          const SizedBox(height: AppDimens.spaceXL),

          // Security note
          Container(
            padding: const EdgeInsets.all(AppDimens.spaceM),
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
                    style: AppTextStyles.copyWith(
                      color: AppColors.textSecondary,
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
