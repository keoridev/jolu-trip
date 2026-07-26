// lib/features/gamification/view/widgets/stamps_carousel.dart
//
// Карусель печатей для профиля: 3D-лента, центральная печать «живая»
// (вращается кольцо + блик), боковые уменьшены и отвёрнуты.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/stamp.dart';
import 'stamp_detail_sheet.dart';
import 'stamp_medallion.dart';
import 'stamp_visuals.dart';

class StampsCarousel extends StatefulWidget {
  /// Полученные печати.
  final List<Stamp> stamps;

  /// Id ещё не полученных печатей — показываем в хвосте как тизер.
  final List<String> lockedIds;

  final double height;

  const StampsCarousel({
    super.key,
    required this.stamps,
    this.lockedIds = const [],
    this.height = 208,
  });

  @override
  State<StampsCarousel> createState() => _StampsCarouselState();
}

class _StampsCarouselState extends State<StampsCarousel> {
  static const double _viewport = 0.46;

  late final PageController _controller = PageController(
    viewportFraction: _viewport,
  );

  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    final page = _controller.page;
    if (page == null) return;
    if ((page - _page).abs() < 0.001) return;
    setState(() => _page = page);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  List<_CarouselItem> get _items => [
    ...widget.stamps.map((s) => _CarouselItem(id: s.id, stamp: s)),
    ...widget.lockedIds.take(3).map((id) => _CarouselItem(id: id)),
  ];

  void _onItemTap(int index, _CarouselItem item) {
    final isCentered = (_page - index).abs() < 0.5;
    if (!isCentered) {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    showStampDetailSheet(context, stamp: item.stamp, stampId: item.id);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty) return const _EmptyCarousel();

    final current = items[_page.round().clamp(0, items.length - 1)];

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final delta = (_page - index).clamp(-1.6, 1.6);
              final distance = delta.abs();
              final scale = 1 - (distance * 0.22).clamp(0.0, 0.44);

              final matrix = Matrix4.identity()
                ..setEntry(3, 2, 0.0016)
                ..rotateY(delta * 0.42)
                ..scaleByDouble(scale, scale, 1, 1);

              return Transform(
                alignment: Alignment.center,
                transform: matrix,
                child: Opacity(
                  opacity: (1 - distance * 0.45).clamp(0.35, 1.0),
                  child: _CarouselCard(
                    item: items[index],
                    focused: distance < 0.35,
                    onTap: () => _onItemTap(index, items[index]),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: AppDimens.space14),

        // Подпись активной печати
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Column(
            key: ValueKey(current.id),
            children: [
              Text(
                current.isLocked ? '???' : current.stamp!.title,
                style: AppTextStyles.title.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                current.isLocked
                    ? stampInfoFor(current.id).hint
                    : rarityStyle(current.stamp!.rarity).label,
                style: AppTextStyles.subtext.copyWith(
                  fontSize: 12,
                  color: current.isLocked
                      ? AppColors.textMuted
                      : rarityStyle(current.stamp!.rarity).accent,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimens.space12),

        _Dots(count: items.length, page: _page),
      ],
    );
  }
}

class _CarouselItem {
  final String id;
  final Stamp? stamp;

  const _CarouselItem({required this.id, this.stamp});

  bool get isLocked => stamp == null;
}

class _CarouselCard extends StatelessWidget {
  final _CarouselItem item;
  final bool focused;
  final VoidCallback onTap;

  const _CarouselCard({
    required this.item,
    required this.focused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locked = item.isLocked;
    final info = stampInfoFor(item.id);
    final rarity = item.stamp?.rarity ?? info.rarity;
    final style = rarityStyle(rarity);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          gradient: locked
              ? const LinearGradient(
                  colors: [Color(0xFF17181B), Color(0xFF121212)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : style.cardGradient,
          borderRadius: BorderRadius.circular(AppDimens.radius20),
          border: Border.all(
            color: locked
                ? AppColors.borderDark
                : style.accent.withValues(alpha: focused ? 0.45 : 0.22),
            width: focused && !locked ? 1.5 : 1,
          ),
          boxShadow: focused && !locked
              ? [
                  BoxShadow(
                    color: style.glow(0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StampMedallion(
              stampId: item.id,
              rarity: rarity,
              imageAsset: item.stamp?.imageAsset,
              size: 92,
              locked: locked,
              animate: focused,
            ),
            const SizedBox(height: AppDimens.space12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                locked ? 'Не открыта' : item.stamp!.title,
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: locked ? AppColors.textMuted : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final double page;

  const _Dots({required this.count, required this.page});

  @override
  Widget build(BuildContext context) {
    // Больше 8 точек превращаются в кашу — сжимаем в компактную полоску.
    if (count > 8) {
      final progress = count > 1 ? (page / (count - 1)).clamp(0.0, 1.0) : 0.0;
      return SizedBox(
        width: 96,
        height: 4,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(AppDimens.radiusRound),
              ),
            ),
            Align(
              alignment: Alignment(progress * 2 - 1, 0),
              child: Container(
                width: 28,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppDimens.radiusRound),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final distance = (page - index).abs().clamp(0.0, 1.0);
        final width = 6 + (1 - distance) * 12;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: width,
          height: 6,
          decoration: BoxDecoration(
            color: Color.lerp(
              AppColors.accent,
              AppColors.borderDark,
              math.min(distance, 1),
            ),
            borderRadius: BorderRadius.circular(AppDimens.radiusRound),
          ),
        );
      }),
    );
  }
}

class _EmptyCarousel extends StatelessWidget {
  const _EmptyCarousel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 36,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppDimens.space12),
          Text(
            'Пока нет печатей',
            style: AppTextStyles.title.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppDimens.space4),
          Text(
            'Сделайте чекин в локации — печать появится здесь',
            style: AppTextStyles.subtext.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
