import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/features/tourist_health_card/domain/entities/health_card_entity.dart';
import 'package:jolutrip_app/features/tourist_health_card/domain/repositories/health_card_repository.dart';
import 'health_card_state.dart';

class HealthCardCubit extends Cubit<HealthCardState> {
  final HealthCardRepository _repository;

  HealthCardCubit(this._repository) : super(HealthCardInitial());

  void _safeEmit(HealthCardState state) {
    if (!isClosed) emit(state);
  }

  Future<void> load() async {
    _safeEmit(HealthCardLoading());
    final result = await _repository.getHealthCard();
    if (isClosed) return;

    result.fold(
      (failure) => _safeEmit(HealthCardError(failure.message)),
      (card) => _safeEmit(HealthCardLoaded(card)),
    );
  }

  Future<void> save(HealthCardEntity card) async {
    _safeEmit(HealthCardSaving(card));
    final result = await _repository.saveHealthCard(card);
    if (isClosed) return;

    result.fold(
      (failure) => _safeEmit(HealthCardError(failure.message)),
      (saved) => _safeEmit(HealthCardSaved(saved)),
    );
  }
}
