import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/visit_record.dart';
import '../blocs/journal/journal_cubit.dart';
import '../blocs/journal/journal_state.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Журнал путешествий',
          style: AppTextStyles.headline.copyWith(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<JournalCubit, JournalState>(
        builder: (context, state) {
          if (state is JournalInitial || state is JournalLoading) {
            return const _LoadingView();
          }
          if (state is JournalError) {
            return _ErrorView(message: state.message);
          }
          if (state is JournalLoaded) {
            if (state.visits.isEmpty) {
              return const _EmptyView();
            }
            return _JournalList(visits: state.visits);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// СОСТОЯНИЯ
// ═══════════════════════════════════════════════════

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 2,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.subtext,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.book_outlined,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Журнал пока пуст',
            style: AppTextStyles.headline.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Посещайте локации, и они появятся здесь с фото и воспоминаниями',
              style: AppTextStyles.subtext,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push('/locations'),
            icon: const Icon(Icons.explore_outlined),
            label: const Text('Начать исследовать'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// СПИСОК ПОСЕЩЕНИЙ
// ═══════════════════════════════════════════════════

class _JournalList extends StatelessWidget {
  final List<VisitRecord> visits;

  const _JournalList({required this.visits});

  @override
  Widget build(BuildContext context) {
    // Группируем по месяцам
    final grouped = _groupByMonth(visits);

    return CustomScrollView(
      slivers: [
        // Статистика сверху
        SliverToBoxAdapter(child: _JournalStats(visits: visits)),

        // Список по месяцам
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final month = grouped.keys.elementAt(index);
            final monthVisits = grouped[month]!;
            return _MonthSection(month: month, visits: monthVisits);
          }, childCount: grouped.length),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    );
  }

  Map<String, List<VisitRecord>> _groupByMonth(List<VisitRecord> visits) {
    final result = <String, List<VisitRecord>>{};
    for (final visit in visits) {
      final key = DateFormat('MMMM yyyy', 'ru').format(visit.visitedAt);
      result.putIfAbsent(key, () => []).add(visit);
    }
    return result;
  }
}

// ═══════════════════════════════════════════════════
// СТАТИСТИКА
// ═══════════════════════════════════════════════════

class _JournalStats extends StatelessWidget {
  final List<VisitRecord> visits;

  const _JournalStats({required this.visits});

  @override
  Widget build(BuildContext context) {
    final uniqueLocations = visits.map((v) => v.locationId).toSet().length;
    final thisMonth = visits.where((v) {
      final now = DateTime.now();
      return v.visitedAt.year == now.year && v.visitedAt.month == now.month;
    }).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          _StatItem(
            value: visits.length.toString(),
            label: 'Всего',
            icon: Icons.place_outlined,
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 40, color: AppColors.borderDark),
          const SizedBox(width: 16),
          _StatItem(
            value: uniqueLocations.toString(),
            label: 'Локаций',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 40, color: AppColors.borderDark),
          const SizedBox(width: 16),
          _StatItem(
            value: thisMonth.toString(),
            label: 'В этом месяце',
            icon: Icons.calendar_today_outlined,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(value, style: AppTextStyles.headline.copyWith(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.subtext.copyWith(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// СЕКЦИЯ МЕСЯЦА
// ═══════════════════════════════════════════════════

class _MonthSection extends StatelessWidget {
  final String month;
  final List<VisitRecord> visits;

  const _MonthSection({required this.month, required this.visits});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок месяца
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _capitalize(month),
                style: AppTextStyles.title.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${visits.length} ${visits.length == 1
                    ? 'посещение'
                    : visits.length < 5
                    ? 'посещения'
                    : 'посещений'}',
                style: AppTextStyles.subtext.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),

        // Карточки посещений
        ...visits.map((visit) => _VisitCard(visit: visit)),
      ],
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

// ═══════════════════════════════════════════════════
// КАРТОЧКА ПОСЕЩЕНИЯ
// ═══════════════════════════════════════════════════

class _VisitCard extends StatelessWidget {
  final VisitRecord visit;

  const _VisitCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    final hasPhotos = visit.photos.isNotEmpty;
    final dateStr = DateFormat('d MMMM', 'ru').format(visit.visitedAt);
    final timeStr = DateFormat('HH:mm').format(visit.visitedAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Фото (если есть)
          if (hasPhotos)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimens.radiusM - 1),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.file(
                  File(visit.photos.first.localPath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.bgDark,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Контент
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Дата-круг
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        visit.visitedAt.day.toString(),
                        style: AppTextStyles.title.copyWith(
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        _shortMonth(visit.visitedAt.month),
                        style: AppTextStyles.subtext.copyWith(
                          fontSize: 10,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Инфо
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Локация #${visit.locationId}', // TODO: заменить на реальное имя
                        style: AppTextStyles.title.copyWith(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$dateStr в $timeStr',
                            style: AppTextStyles.subtext.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                      if (visit.note != null && visit.note!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          visit.note!,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Иконка стрелки
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _shortMonth(int month) {
    const months = [
      '',
      'янв',
      'фев',
      'мар',
      'апр',
      'май',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек',
    ];
    return months[month];
  }
}
