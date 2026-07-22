import 'package:jolutrip_app/features/gamification/data/datasources/datasources.dart';
import 'package:jolutrip_app/features/gamification/domain/entities/entities.dart';
import 'package:jolutrip_app/features/gamification/domain/repositories/repositories.dart';

class StampRepositoryImpl implements StampRepository {
  final StampLocalDatasource _datasource;

  const StampRepositoryImpl(this._datasource);

  @override
  Future<List<Stamp>> getEarnedStamps() async {
    return _datasource.getEarnedStamps();
  }

  @override
  Future<List<Stamp>> getAvailableStamps() async {
    // Хардкод доступных печатей для MVP
    return [
      const Stamp(
        id: 'first_step',
        title: 'Первый шаг',
        description: 'Начало путешествия по Кыргызстану',
        imageAsset: 'assets/stamps/first_step.png',
        rarity: StampRarity.common,
      ),
      const Stamp(
        id: 'first_canyon',
        title: 'Исследователь каньонов',
        description: 'Первый каньон открыт',
        imageAsset: 'assets/stamps/canyon.png',
        rarity: StampRarity.silver,
      ),
      const Stamp(
        id: 'issyk_kul',
        title: 'Иссык-Куль',
        description: 'Жемчужина Кыргызстана',
        imageAsset: 'assets/stamps/issyk_kul.png',
        rarity: StampRarity.common,
      ),
      const Stamp(
        id: 'ala_archa',
        title: 'Ала-Арча',
        description: 'Горный запасник',
        imageAsset: 'assets/stamps/ala_archa.png',
        rarity: StampRarity.common,
      ),
      const Stamp(
        id: 'guided_tour',
        title: 'С гидом — надёжнее',
        description: 'Маршрут с сертифицированным гидом',
        imageAsset: 'assets/stamps/guided.png',
        rarity: StampRarity.gold,
      ),
      const Stamp(
        id: 'son_kul',
        title: 'Сон-Куль',
        description: 'Высокогорное озеро',
        imageAsset: 'assets/stamps/son_kul.png',
        rarity: StampRarity.silver,
      ),
    ];
  }

  @override
  Future<List<Collection>> getCollections() async {
    return _datasource.getCollections();
  }

  @override
  Future<List<Stamp>> evaluateNewStamps({
    required String locationId,
    required List<String> locationTags,
    required bool hasGuideBooking,
    required List<VisitRecord> visitHistory,
  }) async {
    final earned = await getEarnedStamps();
    final earnedIds = earned.map((s) => s.id).toSet();
    final newStamps = <Stamp>[];

    // Правило 1: Первая локация
    if (visitHistory.isEmpty && !earnedIds.contains('first_step')) {
      newStamps.add(
        const Stamp(
          id: 'first_step',
          title: 'Первый шаг',
          description: 'Вы начали своё путешествие по Кыргызстану',
          imageAsset: 'assets/stamps/first_step.png',
          rarity: StampRarity.common,
        ),
      );
    }

    // Правило 2: Каньоны
    if (locationTags.contains('каньон') &&
        !earnedIds.contains('first_canyon')) {
      newStamps.add(
        const Stamp(
          id: 'first_canyon',
          title: 'Исследователь каньонов',
          description: 'Первый каньон открыт',
          imageAsset: 'assets/stamps/canyon.png',
          rarity: StampRarity.silver,
        ),
      );
    }

    // Правило 3: Иссык-Куль
    if (locationId == 'issyk_kul' && !earnedIds.contains('issyk_kul')) {
      newStamps.add(
        const Stamp(
          id: 'issyk_kul',
          title: 'Иссык-Куль',
          description: 'Жемчужина Кыргызстана',
          imageAsset: 'assets/stamps/issyk_kul.png',
          rarity: StampRarity.common,
        ),
      );
    }

    // Правило 4: Ала-Арча
    if (locationId == 'ala_archa' && !earnedIds.contains('ala_archa')) {
      newStamps.add(
        const Stamp(
          id: 'ala_archa',
          title: 'Ала-Арча',
          description: 'Горный запасник',
          imageAsset: 'assets/stamps/ala_archa.png',
          rarity: StampRarity.common,
        ),
      );
    }

    // Правило 5: С гидом
    if (hasGuideBooking && !earnedIds.contains('guided_tour')) {
      newStamps.add(
        const Stamp(
          id: 'guided_tour',
          title: 'С гидом — надёжнее',
          description: 'Маршрут с сертифицированным гидом',
          imageAsset: 'assets/stamps/guided.png',
          rarity: StampRarity.gold,
        ),
      );
    }

    // Добавляем earnedAt
    final now = DateTime.now();
    return newStamps.map((s) => s.copyWith(earnedAt: now)).toList();
  }

  @override
  Future<void> saveStamp(Stamp stamp) async {
    await _datasource.saveStamp(stamp);
  }

  @override
  Future<void> saveCollectionProgress(
    String collectionId,
    String stampId,
  ) async {
    await _datasource.updateCollectionProgress(collectionId, stampId);
  }
}
