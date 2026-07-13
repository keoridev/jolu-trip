import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/guide_tours/view/create_tour_contrloller.dart';

class StepDetails extends StatelessWidget {
  final CreateTourController controller;

  const StepDetails({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppDimens.screenPadding,
      children: [
        _SectionHeader(
          title: 'Детали тура',
          subtitle: 'Укажите цену и что включено',
        ),
        const SizedBox(height: AppDimens.space24),

        // Цена
        _PriceField(controller: controller),
        const SizedBox(height: AppDimens.space16),

        // Места
        _SeatsRow(controller: controller),
        const SizedBox(height: AppDimens.space24),

        // Видео
        _VideoUploader(controller: controller),
        const SizedBox(height: AppDimens.space24),

        // Услуги
        _ChipsSection(
          title: 'Включённые услуги',
          icon: Icons.check_circle_outline,
          items: controller.includedServices,
          controller: controller.serviceController,
          hint: 'Например: трансфер, питание',
          onAdd: controller.addService,
          onRemove: controller.removeService,
        ),
        const SizedBox(height: AppDimens.space24),

        // Снаряжение
        _ChipsSection(
          title: 'Необходимое снаряжение',
          icon: Icons.hiking,
          items: controller.gearRequirements,
          controller: controller.gearController,
          hint: 'Например: треккинговые ботинки',
          onAdd: controller.addGear,
          onRemove: controller.removeGear,
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.title.copyWith(fontSize: 22)),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _PriceField extends StatelessWidget {
  final CreateTourController controller;

  const _PriceField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _AppTextField(
      controller: controller.priceController,
      label: 'Цена за место',
      hint: '0',
      icon: Icons.payments_outlined,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      suffix: const Text(
        'сом',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      onChanged: (_) => controller.notifyListeners(),
    );
  }
}

class _SeatsRow extends StatelessWidget {
  final CreateTourController controller;

  const _SeatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AppTextField(
            controller: controller.totalSeatsController,
            label: 'Всего мест',
            hint: '8',
            icon: Icons.people_outline,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => controller.notifyListeners(),
          ),
        ),
        const SizedBox(width: AppDimens.space16),
        Expanded(
          child: _AppTextField(
            controller: controller.minSeatsController,
            label: 'Мин. для старта',
            hint: '1',
            icon: Icons.person_outline,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ],
    );
  }
}

class _VideoUploader extends StatelessWidget {
  final CreateTourController controller;

  const _VideoUploader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasVideo = controller.selectedVideo != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Промо-видео',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimens.space12),
        GestureDetector(
          onTap: () => _pickVideo(context),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(AppDimens.radiusL),
              border: Border.all(
                color: hasVideo
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.2),
                width: hasVideo ? 2 : 1,
              ),
            ),
            child: Center(
              child: hasVideo
                  ? _VideoUploaded(name: controller.selectedVideo!.name)
                  : _VideoPlaceholder(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickVideo(BuildContext context) async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 2),
    );
    if (video == null) return;

    controller.setVideo(video);
  }
}

class _VideoUploaded extends StatelessWidget {
  final String name;

  const _VideoUploaded({required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.videocam, color: AppColors.primary, size: 40),
        const SizedBox(height: 8),
        Text(
          'Видео загружено',
          style: AppTextStyles.body.copyWith(color: AppColors.primary),
        ),
        Text(
          name,
          style: AppTextStyles.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_circle_outline,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          size: 40,
        ),
        const SizedBox(height: 8),
        Text(
          'Добавить видео',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ChipsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onAdd;
  final ValueChanged<int> onRemove;

  const _ChipsSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.controller,
    required this.hint,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.bodySmall),
          ],
        ),
        const SizedBox(height: AppDimens.space12),
        if (items.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.asMap().entries.map((entry) {
              return _Chip(
                label: entry.value,
                onDelete: () => onRemove(entry.key),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimens.space12),
        ],
        _ChipInput(
          controller: controller,
          hint: hint,
          onSubmit: (v) {
            onAdd(v);
            controller.clear();
          },
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;

  const _Chip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space12,
        vertical: AppDimens.space8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusRound),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.close,
              color: AppColors.primary.withValues(alpha: 0.7),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onSubmit;

  const _ChipInput({
    required this.controller,
    required this.hint,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.cardDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
                vertical: AppDimens.space12,
              ),
            ),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) onSubmit(v.trim());
            },
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            final v = controller.text.trim();
            if (v.isNotEmpty) {
              onSubmit(v);
              controller.clear();
            }
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  const _AppTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: AppColors.cardDark,
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.textSecondary, size: 20)
            : null,
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: AppDimens.space16),
                child: suffix,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
