// lib/features/guide_auth/presentation/widgets/document_upload_card.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';

enum DocumentType {
  passportMain, // Паспорт: главная страница с фото
  passportRegistration, // Паспорт: прописка
  licenseFront, // Права: лицевая сторона
  licenseBack, // Права: обратная сторона
  carFront, // Авто: спереди
  carBack, // Авто: сзади
  carInterior, // Авто: салон
  carTrunk, // Авто: багажник
}

class DocumentUploadCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Uint8List? imageBytes;
  final VoidCallback onTap;
  final String? sideHint; // "Лицевая сторона", "Оборотная сторона"
  final String? exampleImagePath; // Путь к примеру-референсу

  const DocumentUploadCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.imageBytes,
    required this.onTap,
    this.sideHint,
    this.exampleImagePath,
  });

  @override
  State<DocumentUploadCard> createState() => _DocumentUploadCardState();
}

class _DocumentUploadCardState extends State<DocumentUploadCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showExample = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppDimens.radiusL),
            border: Border.all(
              color: widget.imageBytes != null
                  ? AppColors.success.withValues(alpha: 0.5)
                  : AppColors.borderDark,
              width: widget.imageBytes != null ? 2 : 1,
            ),
            boxShadow: widget.imageBytes != null
                ? [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(AppDimens.spaceL),
                child: Row(
                  children: [
                    // Icon with status badge
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.imageBytes != null
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.borderDark,
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusM,
                            ),
                          ),
                          child: Icon(
                            widget.imageBytes != null
                                ? Icons.check_circle
                                : widget.icon,
                            color: widget.imageBytes != null
                                ? AppColors.success
                                : AppColors.textMuted,
                            size: 28,
                          ),
                        ),
                        if (widget.sideHint != null &&
                            widget.imageBytes == null)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '!',
                                style: AppTextStyles.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: AppDimens.spaceM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: AppTextStyles.subtitle,
                                ),
                              ),
                              if (widget.sideHint != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    widget.sideHint!,
                                    style: AppTextStyles.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.imageBytes != null
                                ? 'Файл загружен ✓'
                                : widget.subtitle,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: widget.imageBytes != null
                                  ? AppColors.success
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Expandable example section (как пример, как правильно фотографировать)
              if (widget.exampleImagePath != null || widget.sideHint != null)
                _buildExampleSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceM),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimens.radiusL),
          bottomRight: Radius.circular(AppDimens.radiusL),
        ),
        border: Border(top: BorderSide(color: AppColors.borderDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info row with example hint
          Row(
            children: [
              Icon(
                Icons.photo_camera_outlined,
                color: AppColors.textMuted,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Как правильно сфотографировать:',
                  style: AppTextStyles.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _showFullExampleDialog(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 30),
                ),
                child: Text(
                  'Пример',
                  style: AppTextStyles.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tips list
          _buildTip(
            Icons.center_focus_strong,
            'Разместите документ в центре кадра',
          ),
          const SizedBox(height: 4),
          _buildTip(Icons.flash_on, 'Обеспечьте хорошее освещение'),
          const SizedBox(height: 4),
          _buildTip(Icons.crop_free, 'Весь документ должен помещаться в кадр'),
          if (widget.sideHint != null) ...[
            const SizedBox(height: 4),
            _buildTip(
              Icons.sync_alt,
              'Сфотографируйте ${widget.sideHint == 'Лицевая сторона' ? 'оборотную' : 'лицевую'} сторону',
              isImportant: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTip(IconData icon, String text, {bool isImportant = false}) {
    return Row(
      children: [
        Icon(
          icon,
          color: isImportant ? AppColors.warning : AppColors.textMuted,
          size: 14,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.copyWith(
              fontWeight: FontWeight.w600,
              color: isImportant ? AppColors.warning : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  void _showFullExampleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.spaceL),
              child: Column(
                children: [
                  Text(
                    'Как правильно сфотографировать',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: AppDimens.spaceM),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.bgDark,
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_camera,
                            size: 48,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Пример фото документа',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.spaceL),
                  ..._getDetailedTips(),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppDimens.spaceL),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderDark)),
              ),
              child: JoluButton(
                text: 'Понятно',
                variant: JoluButtonVariant.primary,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getDetailedTips() {
    return [
      _buildDetailedTip('📸 Качество', 'Фото должно быть четким, без размытия'),
      const SizedBox(height: 8),
      _buildDetailedTip(
        '💡 Освещение',
        'Снимайте при дневном свете или с хорошей вспышкой',
      ),
      const SizedBox(height: 8),
      _buildDetailedTip(
        '📄 Рамки',
        'Документ должен полностью помещаться в кадр',
      ),
      const SizedBox(height: 8),
      _buildDetailedTip(
        '🪪 Читаемость',
        'Все данные и фото должны быть четко видны',
      ),
    ];
  }

  Widget _buildDetailedTip(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.bodySmall),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: AppTextStyles.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
