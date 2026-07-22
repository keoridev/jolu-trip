import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/features/gamification/domain/entities/entities.dart';
import 'package:jolutrip_app/features/gamification/domain/repositories/repositories.dart';
import 'package:jolutrip_app/features/gamification/domain/usecases/usecases.dart';

import 'stamps_state.dart';

class StampsCubit extends Cubit<StampsState> {
  final StampRepository _repository;
  final GetTravelerStatus _getStatus;

  StampsCubit(this._repository, this._getStatus) : super(const StampsInitial());

  Future<void> loadStamps() async {
    emit(const StampsLoading());
    try {
      final stamps = await _repository.getEarnedStamps();
      final collections = await _repository.getCollections();
      final status = _getStatus(stamps.length);

      emit(
        StampsLoaded(
          stamps: stamps,
          collections: collections,
          travelerStatus: status.title,
          totalStamps: stamps.length,
        ),
      );
    } catch (e) {
      emit(StampsError('Не удалось загрузить печати: $e'));
    }
  }

  Future<void> onCheckinCompleted(List<Stamp> newStamps) async {
    if (newStamps.isEmpty) return;

    final currentState = state;
    if (currentState is! StampsLoaded) return;

    // Сохраняем новые печати
    for (final stamp in newStamps) {
      await _repository.saveStamp(stamp);
    }

    // Обновляем коллекции
    for (final stamp in newStamps) {
      for (final collection in currentState.collections) {
        if (collection.stampIds.contains(stamp.id)) {
          await _repository.saveCollectionProgress(collection.id, stamp.id);
        }
      }
    }

    // Перезагружаем
    final stamps = await _repository.getEarnedStamps();
    final collections = await _repository.getCollections();
    final status = _getStatus(stamps.length);

    emit(
      currentState.copyWith(
        stamps: stamps,
        collections: collections,
        lastEarnedStamps: newStamps,
        showAnimation: true,
        travelerStatus: status.title,
        totalStamps: stamps.length,
      ),
    );
  }

  void animationShown() {
    final currentState = state;
    if (currentState is! StampsLoaded) return;

    emit(currentState.copyWith(showAnimation: false, lastEarnedStamps: []));
  }
}
