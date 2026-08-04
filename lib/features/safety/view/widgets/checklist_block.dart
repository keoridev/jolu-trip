import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/safety/data/datasources/safety_local_datasource.dart';
import 'package:jolutrip_app/features/safety/data/models/safety_models.dart';
import 'package:jolutrip_app/features/safety/view/widgets/shared/block_title.dart';

class ChecklistBlock extends StatefulWidget {
  const ChecklistBlock({super.key});

  @override
  State<ChecklistBlock> createState() => _ChecklistBlockState();
}

class _ChecklistBlockState extends State<ChecklistBlock> {
  final Set<String> _checkedItems = {};

  int get _totalItems => SafetyLocalDataSource.preTripChecklist.length;
  int get _checkedCount => _checkedItems.length;
  double get _progress => _totalItems == 0 ? 0 : _checkedCount / _totalItems;

  @override
  Widget build(BuildContext context) {
    final isComplete = _checkedCount == _totalItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlockTitle(
          icon: Icons.task_alt_rounded,
          title: 'Чек-лист перед выездом',
          color: isComplete ? AppColors.success : AppColors.accent,
        ),
        const SizedBox(height: AppDimens.space8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusRound),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 6,
            backgroundColor: AppColors.cardDark,
            valueColor: AlwaysStoppedAnimation<Color>(
              isComplete ? AppColors.success : AppColors.accent,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.space16),
        ...SafetyLocalDataSource.preTripChecklist.map((item) {
          final isChecked = _checkedItems.contains(item.id);
          return _ChecklistTile(
            item: item,
            isChecked: isChecked,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _checkedItems.add(item.id);
                } else {
                  _checkedItems.remove(item.id);
                }
              });
            },
          );
        }),
      ],
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  final ChecklistItem item;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const _ChecklistTile({
    required this.item,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.borderDark,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: AppDimens.space16),
          Expanded(
            child: Text(
              item.title,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                decoration: isChecked ? TextDecoration.lineThrough : null,
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
              onChanged: onChanged,
              activeColor: AppColors.success,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: BorderSide(color: AppColors.borderDark, width: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
