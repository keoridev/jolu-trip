import 'dart:ui';
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

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.bgDark.withOpacity(0.8),
            border: const Border(
              top: BorderSide(color: AppColors.borderDark, width: 0.5),
            ),
          ),
          padding: EdgeInsets.only(
            top: AppDimens.spaceS,
            bottom: bottomPadding > 0 ? bottomPadding : AppDimens.spaceS,
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
    return AnimatedScale(
      scale: isSelected ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: isSelected
                ? const EdgeInsets.all(AppDimens.spaceXS)
                : EdgeInsets.zero,
            decoration: isSelected
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.1),
                  )
                : null,
            child: Icon(
              isSelected ? tab.iconFilled : tab.iconOutline,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: isSelected ? 26 : 24,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              letterSpacing: -0.2,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            child: Text(tab.label),
          ),
        ],
      ),
    );
  }
}
