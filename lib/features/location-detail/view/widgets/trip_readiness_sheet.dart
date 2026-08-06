import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';

class TripReadinessSheet extends StatefulWidget {
  final LocationDetailEntity location;
  final VoidCallback onReady;

  const TripReadinessSheet({
    super.key,
    required this.location,
    required this.onReady,
  });

  @override
  State<TripReadinessSheet> createState() => _TripReadinessSheetState();
}

class _TripReadinessSheetState extends State<TripReadinessSheet> {
  final Set<String> _checkedItems = {};

  // Формируем умный список: специфичные вещи локации + базовые правила выживания
  List<_ChecklistItem> get _items {
    final baseItems = [
      _ChecklistItem(
        id: 'cash',
        text: 'Наличные сомы (в горах карты не работают)',
        icon: Icons.payments_outlined,
      ),
      _ChecklistItem(
        id: 'powerbank',
        text: 'Пауэрбанк заряжен на 100%',
        icon: Icons.battery_charging_full_outlined,
      ),
      _ChecklistItem(
        id: 'offline_maps',
        text: 'Офлайн-карты скачаны заранее',
        icon: Icons.map_outlined,
      ),
    ];

    final specificItems = widget.location.gearList.take(2).map((gear) {
      return _ChecklistItem(
        id: 'gear_$gear',
        text: gear,
        icon: Icons.checkroom_outlined,
      );
    }).toList();

    return [...specificItems, ...baseItems];
  }

  int get _checkedCount => _checkedItems.length;
  bool get _isAllChecked => _checkedCount == _items.length;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppDimens.space12,
        left: AppDimens.space24,
        right: AppDimens.space24,
        bottom: MediaQuery.of(context).padding.bottom + AppDimens.space24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ручка шторки
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.space24),

          // Заголовок
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
                child: const Icon(
                  Icons.backpack_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimens.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Готовность к поездке',
                      style: AppTextStyles.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Отметь, что взял с собой',
                      style: AppTextStyles.subtext.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Счетчик
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _isAllChecked
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.cardDark,
                  borderRadius: BorderRadius.circular(AppDimens.radiusRound),
                  border: Border.all(
                    color: _isAllChecked
                        ? AppColors.success
                        : AppColors.borderDark,
                  ),
                ),
                child: Text(
                  '$_checkedCount/${_items.length}',
                  style: AppTextStyles.badge.copyWith(
                    color: _isAllChecked
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space24),

          // Список чекбоксов
          ..._items.map((item) {
            final isChecked = _checkedItems.contains(item.id);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: AppDimens.space12),
              padding: const EdgeInsets.all(AppDimens.space16),
              decoration: BoxDecoration(
                color: isChecked
                    ? AppColors.cardDark.withOpacity(0.5)
                    : AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                border: Border.all(
                  color: isChecked
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.borderDark,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color: isChecked
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: AppDimens.space16),
                  Expanded(
                    child: Text(
                      item.text,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w500,
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : null,
                        color: isChecked
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (value == true) {
                            _checkedItems.add(item.id);
                          } else {
                            _checkedItems.remove(item.id);
                          }
                        });
                      },
                      activeColor: AppColors.primary,
                      checkColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: BorderSide(color: AppColors.borderDark, width: 1.5),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: AppDimens.space24),

          // Кнопка действия
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context); // Закрываем шторку
                widget.onReady(); // Запускаем навигатор
              },
              icon: const Icon(
                Icons.navigation_rounded,
                color: Colors.black,
                size: 20,
              ),
              label: Text(
                _isAllChecked
                    ? 'Всё готово, поехали! 🚗'
                    : 'Всё равно открыть карту',
                style: AppTextStyles.button.copyWith(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAllChecked
                    ? AppColors.success
                    : AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.space12),
        ],
      ),
    );
  }
}

class _ChecklistItem {
  final String id;
  final String text;
  final IconData icon;

  _ChecklistItem({required this.id, required this.text, required this.icon});
}
