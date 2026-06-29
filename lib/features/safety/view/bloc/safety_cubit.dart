import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/features/safety/domain/repositories/safety_repository.dart';

import 'safety_state.dart';

class SafetyCubit extends Cubit<SafetyState> {
  final SafetyRepository _repository;

  SafetyCubit({required SafetyRepository repository})
    : _repository = repository,
      super(SafetyInitial());

  Future<void> loadLocation() async {
    emit(const SafetyLocationLoading());
    await _fetchLocation();
  }

  Future<void> refreshLocation() async {
    final current = state;
    if (current is SafetyLocationLoaded && current.coordinates != null) {
      emit(SafetyLocationLoading(previousCoords: current.coordinates));
    } else {
      emit(const SafetyLocationLoading());
    }
    await _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final hasPermission = await _repository.hasLocationPermission();
      if (!hasPermission) {
        await _repository.requestLocationPermission();
      }

      final coords = await _repository.getCurrentLocation();
      emit(SafetyLocationLoaded(coordinates: coords));
    } catch (e) {
      emit(SafetyError('Не удалось получить координаты: $e'));
    }
  }
}
