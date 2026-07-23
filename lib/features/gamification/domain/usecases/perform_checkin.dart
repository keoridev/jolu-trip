// lib/features/gamification/domain/usecases/perform_checkin.dart

import 'dart:math';
import '../entities/visit_record.dart';
import '../entities/stamp.dart';
import '../repositories/journal_repository.dart';
import '../repositories/stamp_repository.dart';

class PerformCheckinParams {
  final String locationId;
  final String locationName;
  final double locationLat;
  final double locationLng;
  final double userLat;
  final double userLng;
  final double accuracy;
  final List<String> locationTags;
  final bool hasGuideBooking;

  const PerformCheckinParams({
    required this.locationId,
    required this.locationName,
    required this.locationLat,
    required this.locationLng,
    required this.userLat,
    required this.userLng,
    required this.accuracy,
    required this.locationTags,
    this.hasGuideBooking = false,
  });
}

sealed class PerformCheckinResult {
  const PerformCheckinResult();
}

class PerformCheckinSuccess extends PerformCheckinResult {
  final VisitRecord visit;
  final List<Stamp> newStamps;
  final bool isFirstVisit;

  const PerformCheckinSuccess({
    required this.visit,
    required this.newStamps,
    this.isFirstVisit = false,
  });
}

class PerformCheckinFailure extends PerformCheckinResult {
  final String message;
  const PerformCheckinFailure(this.message);
}

class PerformCheckin {
  final JournalRepository journalRepo;
  final StampRepository stampRepo;

  const PerformCheckin(this.journalRepo, this.stampRepo);

  Future<PerformCheckinResult> call(PerformCheckinParams params) async {
    // 1. Проверка accuracy
    if (params.accuracy > 100) {
      return const PerformCheckinFailure(
        'Точность GPS низкая. Подойдите ближе к локации.',
      );
    }

    // 2. Проверка расстояния
    final distance = _calculateDistance(
      params.userLat,
      params.userLng,
      params.locationLat,
      params.locationLng,
    );

    if (distance > 300) {
      return PerformCheckinFailure(
        'Вы слишком далеко от локации. Расстояние: ${distance.toInt()} м. Подойдите ближе.',
      );
    }

    // 3. Проверка, не посещали ли уже сегодня
    final history = await journalRepo.getAllVisits();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final alreadyVisited = history.any((v) {
      final visitDate = DateTime(v.visitedAt.year, v.visitedAt.month, v.visitedAt.day);
      return v.locationId == params.locationId && visitDate == today;
    });

    if (alreadyVisited) {
      return const PerformCheckinFailure('Вы уже отмечались здесь сегодня');
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

    return PerformCheckinSuccess(
      visit: visit,
      newStamps: newStamps,
      isFirstVisit: history.isEmpty,
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000;
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final deltaPhi = (lat2 - lat1) * pi / 180;
    final deltaLambda = (lon2 - lon1) * pi / 180;

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }
}