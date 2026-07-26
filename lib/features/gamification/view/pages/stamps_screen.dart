// lib/features/gamification/view/pages/stamps_screen.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/stamp.dart';
import '../../domain/usecases/get_traveler_status.dart';
import '../blocs/stamps/stamps_cubit.dart';
import '../blocs/stamps/stamps_state.dart';
import '../widgets/collection_progress.dart';
import '../widgets/stamp_card.dart';
import '../widgets/stamp_unlock_overlay.dart';
import '../widgets/stamp_visuals.dart';
import '../widgets/stamps_carousel.dart';

class StampsScreen extends StatelessWidget {
  const StampsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: BlocConsumer<StampsCubit, StampsState>(
        listener: (context, state) {
          if (state is StampsLoaded &&
              state.showAnimation &&
              state.lastEarnedStamps.isNotEmpty) {
            _showUnlockAnimation(context, state.lastEarnedStamps);
          }
        },
        builder: (context, state) {
          if (state is StampsInitial || state is StampsLoading) {
            return const _LoadingView();
          }
          if (state is StampsError) {
            return _ErrorView(message: state.message);
          }
          if (state is StampsLoaded) {
            return _StampsView(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showUnlockAnimation(BuildContext context, List<Stamp> stamps) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StampUnlockOverlay(
        stamps: stamps,
        onComplete: () {
          Navigator.of(context).pop();
          context.read<StampsCubit>().animationShown();
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppDimens.space16),
            Text(
              message,
              style: AppTextStyles.subtext,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// ОСНОВНОЙ ЭКРАН
// ═══════════════════════════════════════════════════

enum _StampFilter { all, legendary, gold, silver, common, locked }

extension on _StampFilter {
  String get label => switch (this) {
    _StampFilter.all => 'Все',
    _StampFilter.legendary => 'Легендарные',
    _StampFilter.gold => 'Золотые',
    _StampFilter.silver => 'Серебряные',
    _StampFilter.common => 'Обычные',
    _StampFilter.locked => 'Закрытые',
  };

  StampRarity? get rarity => switch (this) {
    _StampFilter.legendary => StampRarity.legendary,
    _StampFilter.gold => StampRarity.gold,
    _StampFilter.silver => StampRarity.silver,
    _StampFilter.common => StampRarity.common,
    _ => null,
  };
}

class _GridEntry {
  final String id;
  final Stamp? stamp;

  const _GridEntry({required this.id, this.stamp});

  bool get isLocked => stamp == null;
}

class _StampsView extends StatefulWidget {
  final StampsLoaded state;
  const _StampsView({required this.state});

  @override
  State<_StampsView> createState() => _StampsViewState();
}

class _StampsViewState extends State<_StampsView> {
  _StampFilter _filter = _StampFilter.all;

  StampsLoaded get _state => widget.state;

  /// Полученные печати + всё, что встречается в коллекциях, но ещё закрыто.
  List<_GridEntry> get _allEntries {
    final earned = [..._state.stamps]..sort((a, b) {
      final byRarity = rarityWeight(b.rarity).compareTo(rarityWeight(a.rarity));
      if (byRarity != 0) return byRarity;
      final aDate = a.earnedAt;
      final bDate = b.earnedAt;
      if (aDate == null || bDate == null) return 0;
      return bDate.compareTo(aDate);
    });

    final earnedIds = earned.map((s) => s.id).toSet();
    final lockedIds = <String>{
      for (final collection in _state.collections) ...collection.stampIds,
    }..removeAll(earnedIds);

    return [
      for (final stamp in earned) _GridEntry(id: stamp.id, stamp: stamp),
      for (final id in lockedIds) _GridEntry(id: id),
    ];
  }

  List<_GridEntry> _applyFilter(List<_GridEntry> entries) {
    return switch (_filter) {
      _StampFilter.all => entries,
      _StampFilter.locked => entries.where((e) => e.isLocked).toList(),
      _ => entries
            .where((e) => !e.isLocked && e.stamp!.rarity == _filter.rarity)
            .toList(),
    };
  }

  Map<StampRarity, int> get _rarityCounts {
    final counts = <StampRarity, int>{};
    for (final stamp in _state.stamps) {
      counts[stamp.rarity] = (counts[stamp.rarity] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _allEntries;
    final visible = _applyFilter(entries);
    final lockedIds = entries.where((e) => e.isLocked).map((e) => e.id).toList();

    final recent = [..._state.stamps]..sort(
      (a, b) => (b.earnedAt ?? DateTime(2000)).compareTo(
        a.earnedAt ?? DateTime(2000),
      ),
    );

    final completed = _state.collections.where((c) => c.isCompleted).length;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          pinned: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Мои печати',
            style: AppTextStyles.headline.copyWith(fontSize: 18),
          ),
          centerTitle: true,
        ),

        // Статус путешественника + прогресс до следующего
        SliverToBoxAdapter(
          child: _TravelerHero(
            status: _state.travelerStatus ?? 'Турист',
            totalStamps: _state.totalStamps,
            rarityCounts: _rarityCounts,
          ),
        ),

        // Витрина — карусель последних печатей
        if (recent.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: _SectionTitle(
              title: 'Витрина',
              subtitle: 'Листайте, чтобы рассмотреть',
            ),
          ),
          SliverToBoxAdapter(
            child: StampsCarousel(
              stamps: recent.take(8).toList(),
              lockedIds: lockedIds,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppDimens.space8)),
        ],

        // Коллекции
        if (_state.collections.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _SectionTitle(
              title: 'Коллекции',
              trailing: '$completed / ${_state.collections.length}',
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  CollectionProgress(collection: _state.collections[index]),
              childCount: _state.collections.length,
            ),
          ),
        ],

        // Альбом
        SliverToBoxAdapter(
          child: _SectionTitle(
            title: 'Альбом',
            trailing: '${_state.stamps.length} из ${entries.length}',
          ),
        ),

        SliverToBoxAdapter(
          child: _FilterBar(
            current: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
        ),

        if (visible.isEmpty)
          const SliverToBoxAdapter(child: _EmptyStampsView())
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space16,
              vertical: AppDimens.space12,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final entry = visible[index];
                return _AppearAnimation(
                  key: ValueKey('${_filter.name}-${entry.id}'),
                  index: index,
                  child: entry.isLocked
                      ? LockedStampCard(stampId: entry.id)
                      : StampCard(stamp: entry.stamp!),
                );
              }, childCount: visible.length),
            ),
          ),

        const SliverPadding(padding: EdgeInsets.only(bottom: AppDimens.space40)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// ШАПКА: СТАТУС + ПРОГРЕСС
// ═══════════════════════════════════════════════════

class _TravelerHero extends StatelessWidget {
  final String status;
  final int totalStamps;
  final Map<StampRarity, int> rarityCounts;

  const _TravelerHero({
    required this.status,
    required this.totalStamps,
    required this.rarityCounts,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = GetTravelerStatus();
    final current = statuses(totalStamps);
    final next = statuses.next(totalStamps);

    final span = next == null
        ? 1
        : math.max(1, next.minStamps - current.minStamps);
    final done = next == null ? 1 : totalStamps - current.minStamps;
    final progress = (done / span).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: AppDimens.space8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radius24),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.22)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16241F), Color(0xFF141517)],
        ),
      ),
      child: Stack(
        children: [
          // Мягкое свечение в углу
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppDimens.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _ProgressRing(progress: progress, total: totalStamps),
                    const SizedBox(width: AppDimens.space20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'СТАТУС',
                            style: AppTextStyles.badge.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(height: AppDimens.space6),
                          Text(
                            status,
                            style: AppTextStyles.headline.copyWith(fontSize: 22),
                          ),
                          const SizedBox(height: AppDimens.space6),
                          Text(
                            next == null
                                ? 'Максимальный уровень достигнут'
                                : 'До «${next.title}» — '
                                      '${next.minStamps - totalStamps} '
                                      '${_stampsWord(next.minStamps - totalStamps)}',
                            style: AppTextStyles.subtext.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimens.space20),
                const Divider(color: AppColors.borderDark, height: 1),
                const SizedBox(height: AppDimens.space16),

                Row(
                  children: StampRarity.values.reversed
                      .map(
                        (rarity) => Expanded(
                          child: _RarityStat(
                            rarity: rarity,
                            count: rarityCounts[rarity] ?? 0,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stampsWord(int count) {
    final mod100 = count % 100;
    if (mod100 >= 11 && mod100 <= 14) return 'печатей';
    return switch (count % 10) {
      1 => 'печать',
      2 || 3 || 4 => 'печати',
      _ => 'печатей',
    };
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  final int total;

  const _ProgressRing({required this.progress, required this.total});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: 86,
          height: 86,
          child: CustomPaint(painter: _RingPainter(value), child: child),
        );
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$total', style: AppTextStyles.headline.copyWith(fontSize: 26)),
            Text(
              'печатей',
              style: AppTextStyles.badge.copyWith(
                fontSize: 9,
                color: AppColors.textSecondary,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  const _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 5;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = Colors.white.withValues(alpha: 0.07),
    );

    if (progress <= 0) return;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: math.pi * 1.5,
          colors: [AppColors.success, AppColors.accent, AppColors.success],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

class _RarityStat extends StatelessWidget {
  final StampRarity rarity;
  final int count;

  const _RarityStat({required this.rarity, required this.count});

  @override
  Widget build(BuildContext context) {
    final style = rarityStyle(rarity);
    final active = count > 0;

    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? style.accent : style.accent.withValues(alpha: 0.18),
            boxShadow: active
                ? [BoxShadow(color: style.glow(0.5), blurRadius: 10)]
                : null,
          ),
        ),
        const SizedBox(height: AppDimens.space8),
        Text(
          '$count',
          style: AppTextStyles.title.copyWith(
            fontSize: 15,
            color: active ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          style.label,
          style: AppTextStyles.subtext.copyWith(fontSize: 10),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// ФИЛЬТРЫ
// ═══════════════════════════════════════════════════

class _FilterBar extends StatelessWidget {
  final _StampFilter current;
  final ValueChanged<_StampFilter> onChanged;

  const _FilterBar({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16),
        itemCount: _StampFilter.values.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppDimens.space8),
        itemBuilder: (context, index) {
          final filter = _StampFilter.values[index];
          final selected = filter == current;
          final rarity = filter.rarity;
          final accent = rarity == null
              ? AppColors.accent
              : rarityStyle(rarity).accent;

          return GestureDetector(
            onTap: () => onChanged(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? accent.withValues(alpha: 0.16)
                    : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(AppDimens.radiusRound),
                border: Border.all(
                  color: selected
                      ? accent.withValues(alpha: 0.55)
                      : AppColors.borderDark,
                ),
              ),
              child: Center(
                child: Text(
                  filter.label,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    color: selected ? accent : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// МЕЛОЧИ
// ═══════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailing;

  const _SectionTitle({required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space24,
        AppDimens.space16,
        AppDimens.space12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.subtext.copyWith(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: AppTextStyles.subtext.copyWith(fontSize: 12),
            ),
        ],
      ),
    );
  }
}

/// Появление карточки: всплывает снизу с лёгким увеличением.
/// Задержка «зашита» в длительность — карточки догоняют друг друга.
class _AppearAnimation extends StatelessWidget {
  final int index;
  final Widget child;

  const _AppearAnimation({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + math.min(index, 12) * 45),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: Transform.scale(scale: 0.94 + value * 0.06, child: child),
          ),
        );
      },
      child: child,
    );
  }
}

class _EmptyStampsView extends StatelessWidget {
  const _EmptyStampsView();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: AppDimens.space24,
      ),
      padding: const EdgeInsets.all(AppDimens.space32),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppDimens.space16),
          Text(
            'Здесь пока пусто',
            style: AppTextStyles.title.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppDimens.space8),
          Text(
            'Посещайте локации и делайте чекин, чтобы получать печати',
            style: AppTextStyles.subtext,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
