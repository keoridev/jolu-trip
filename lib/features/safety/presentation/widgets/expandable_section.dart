
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

class ExpandableSection extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> items;

  const ExpandableSection({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(AppDimens.radiusL),
              bottom: Radius.circular(_isExpanded ? 0 : AppDimens.radiusL),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.spaceM),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    ),
                    child: Icon(
                      widget.icon,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppDimens.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: AppTextStyles.title),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: AppTextStyles.subtext.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(children: widget.items),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

class ExpandableItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final Widget content;

  const ExpandableItem({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  State<ExpandableItem> createState() => _ExpandableItemState();
}

class _ExpandableItemState extends State<ExpandableItem> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          color: AppColors.borderDark,
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        InkWell(
          onTap: () => setState(() => _isOpen = !_isOpen),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spaceM,
              vertical: AppDimens.spaceS,
            ),
            child: Row(
              children: [
                Icon(widget.icon, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isOpen ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: _isOpen
              ? Padding(
                  padding: const EdgeInsets.only(
                    left: AppDimens.spaceM,
                    right: AppDimens.spaceM,
                    bottom: AppDimens.spaceM,
                  ),
                  child: widget.content,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
