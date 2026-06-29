import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';

class JoluTabItem {
  final IconData iconOutline;
  final IconData iconFilled;
  final String label;

  const JoluTabItem({
    required this.iconOutline,
    required this.iconFilled,
    required this.label,
  });
}

class JoluBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const JoluBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<JoluTabItem> _tabs = [
    JoluTabItem(
      iconOutline: Icons.play_circle_outline,
      iconFilled: Icons.play_circle_rounded,
      label: "Reels",
    ),
    JoluTabItem(
      iconOutline: Icons.explore_outlined,
      iconFilled: Icons.explore_rounded,
      label: "Локации",
    ),
    JoluTabItem(
      iconOutline: Icons.directions_car_outlined,
      iconFilled: Icons.directions_car_rounded,
      label: "Поездки",
    ),
    JoluTabItem(
      iconOutline: Icons.person_outline_rounded,
      iconFilled: Icons.person_rounded,
      label: "Профиль",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        border: const Border(
          top: BorderSide(color: AppColors.borderDark, width: 0.3),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: AppDimens.space12,
            bottom: bottomPadding > 0 ? bottomPadding : AppDimens.space12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (index) {
              final isSelected = currentIndex == index;
              final tab = _tabs[index];

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: _JoluTabCell(tab: tab, isSelected: isSelected),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _JoluTabCell extends StatelessWidget {
  final JoluTabItem tab;
  final bool isSelected;

  const _JoluTabCell({required this.tab, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Индикатор сверху (только для активного)
        if (isSelected)
          Container(
            width: 24,
            height: 3,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(1.5),
            ),
          )
        else
          const SizedBox(height: 11),

        // Иконка
        Icon(
          isSelected ? tab.iconFilled : tab.iconOutline,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: isSelected ? 24 : 22,
        ),

        const SizedBox(height: 4),

        // Текст
        Text(
          tab.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            letterSpacing: -0.2,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
