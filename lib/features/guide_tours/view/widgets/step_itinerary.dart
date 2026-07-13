import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/guide_tours/domain/entities/itinerary_day_entity.dart';
import 'package:jolutrip_app/features/guide_tours/view/create_tour_contrloller.dart';

class StepItinerary extends StatelessWidget {
  final CreateTourController controller;

  const StepItinerary({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppDimens.screenPadding,
      children: [
        _SectionHeader(
          title: 'Маршрут по дням',
          subtitle: 'Опишите, что будет каждый день',
        ),
        const SizedBox(height: AppDimens.space24),

        // Timeline
        ...controller.itinerary.asMap().entries.map((entry) {
          return _DayTimeline(
            day: entry.value,
            isLast: entry.key == controller.itinerary.length - 1,
          );
        }),

        // Добавить день
        _AddDayButton(
          dayNumber: controller.currentDayNumber,
          onTap: () => _showAddDaySheet(context),
        ),
        const SizedBox(height: AppDimens.space32),

        // Превью
        if (controller.itinerary.isNotEmpty)
          _TourPreview(controller: controller),
      ],
    );
  }

  void _showAddDaySheet(BuildContext context) {
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddDaySheet(
        dayNumber: controller.currentDayNumber,
        controller: descController,
        onAdd: (desc) {
          controller.addDay(desc);
          Navigator.pop(context);
        },
      ),
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

class _DayTimeline extends StatelessWidget {
  final ItineraryDayEntity day;
  final bool isLast;

  const _DayTimeline({required this.day, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppDimens.space16),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppDimens.space16),
              padding: const EdgeInsets.all(AppDimens.space16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'День ${day.day}',
                    style: AppTextStyles.subtitle.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.description,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
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

class _AddDayButton extends StatelessWidget {
  final int dayNumber;
  final VoidCallback onTap;

  const _AddDayButton({required this.dayNumber, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: AppDimens.space16),
            Text(
              'Добавить день $dayNumber',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddDaySheet extends StatelessWidget {
  final int dayNumber;
  final TextEditingController controller;
  final ValueChanged<String> onAdd;

  const _AddDaySheet({
    required this.dayNumber,
    required this.controller,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: AppDimens.screenPadding,
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
            const SizedBox(height: AppDimens.space20),
            Text('День $dayNumber', style: AppTextStyles.title),
            const SizedBox(height: AppDimens.space16),
            TextField(
              controller: controller,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Опишите, что будет в этот день...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.space16),
            JoluButton(
              text: 'Добавить',
              onPressed: () {
                final desc = controller.text.trim();
                if (desc.isNotEmpty) onAdd(desc);
              },
            ),
            const SizedBox(height: AppDimens.space16),
          ],
        ),
      ),
    );
  }
}

class _TourPreview extends StatelessWidget {
  final CreateTourController controller;

  const _TourPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Проверьте тур перед созданием',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space16),
          _PreviewRow(
            label: 'Название',
            value: controller.titleController.text,
          ),
          _PreviewRow(
            label: 'Локация',
            value: controller.selectedLocationName ?? '-',
          ),
          _PreviewRow(
            label: 'Дата',
            value: controller.departureDate != null
                ? DateFormat(
                    'dd.MM.yyyy HH:mm',
                  ).format(controller.departureDate!)
                : '-',
          ),
          _PreviewRow(
            label: 'Длительность',
            value:
                '${controller.durationDays} ${_pluralDays(controller.durationDays)}',
          ),
          _PreviewRow(
            label: 'Цена',
            value: '${controller.priceController.text} сом',
          ),
          _PreviewRow(
            label: 'Мест',
            value:
                '${controller.totalSeatsController.text} (мин. ${controller.minSeatsController.text})',
          ),
          if (controller.includedServices.isNotEmpty)
            _PreviewRow(
              label: 'Услуги',
              value: controller.includedServices.join(', '),
            ),
          if (controller.gearRequirements.isNotEmpty)
            _PreviewRow(
              label: 'Снаряжение',
              value: controller.gearRequirements.join(', '),
            ),
        ],
      ),
    );
  }

  String _pluralDays(int days) {
    final last = days % 10;
    final lastTwo = days % 100;
    if (lastTwo >= 11 && lastTwo <= 14) return 'дней';
    if (last == 1) return 'день';
    if (last >= 2 && last <= 4) return 'дня';
    return 'дней';
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
