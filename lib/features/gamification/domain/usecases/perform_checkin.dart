import 'package:jolutrip_app/features/gamification/domain/entities/entities.dart';
import 'package:jolutrip_app/features/gamification/domain/repositories/repositories.dart';

class PerformCheckinParams {
  final String locationId;
  final String locationName;
  final double locationLat;
  final double locationLng;
  final double accuracy;
  final List<String> locationTags;
  final bool hasGuideBooking;

  const PerformCheckinParams({
    required this.locationId,
    required this.locationName,
    required this.locationLat,
    required this.locationLng,
    required this.accuracy,
    required this.locationTags,
    this.hasGuideBooking = false,
  });
}

sealed class CheckinResult {
  const CheckinResult();
}

class CheckinSuccess extends CheckinResult {
  final VisitRecord visit;
  final List<Stamp> newStamps;
  final bool isFirstVisit;

  const CheckinSuccess({
    required this.visit,
    required this.newStamps,
    this.isFirstVisit = false,
  });
}

class CheckinFailure extends CheckinResult {
  final String message;
  const CheckinFailure(this.message);
}

class PerformCheckin {
  final JournalRepository journalRepo;
  final StampRepository stampRepo;

  const PerformCheckin(this.journalRepo, this.stampRepo);

  Future<CheckinResult> call(PerformCheckinParams params) async {
    // 1. Проверка accuracy
    if (params.accuracy > 100) {
      return const CheckinFailure(
        'Точность GPS низкая. Подойдите ближе к локации.',
      );
    }

    // 2. Проверка расстояния
    // NOTE: Реальная геолокация берется в Cubit, здесь только бизнес-логика
    // Расстояние передается в params или вычисляется здесь

    // 3. Проверка, не посещали ли уже сегодня
    final history = await journalRepo.getAllVisits();
    final alreadyVisited = history.any(
      (v) =>
          v.locationId == params.locationId &&
          v.visitedAt.day == DateTime.now().day &&
          v.visitedAt.month == DateTime.now().month &&
          v.visitedAt.year == DateTime.now().year,
    );

    if (alreadyVisited) {
      return const CheckinFailure('Вы уже отмечались здесь сегодня');
    }

    // 4. Создаем запись
    final visit = VisitRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      locationId: params.locationId,
      visitedAt: DateTime.now(),
      note: null,
      isSynced: false,
      syncId: '',
    );

    // 5. Сохраняем
    await journalRepo.saveVisit(visit);

    // 6. Оцениваем печати
    final newStamps = await stampRepo.evaluateNewStamps(
      locationId: params.locationId,
      locationTags: params.locationTags,
      hasGuideBooking: params.hasGuideBooking,
      visitHistory: history,
    );

    // 7. Сохраняем печати
    for (final stamp in newStamps) {
      await stampRepo.saveStamp(stamp);
    }

    return CheckinSuccess(
      visit: visit,
      newStamps: newStamps,
      isFirstVisit: history.isEmpty,
    );
  }
}
