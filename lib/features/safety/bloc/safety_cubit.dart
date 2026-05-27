import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/features/safety/domain/repositories/safety_repository.dart';
import 'safety_state.dart';

class SafetyCubit extends Cubit<SafetyState> {
  final SafetyRepository _repository;
  SafetyCubit({required SafetyRepository safetyRepository})
    : _repository = safetyRepository,
      super(SafetyInitial());

  Future<void> loadLocation() async {
    emit(SafetyLocationLoaded(isLoading: true));
    try {
      final coordinates = await _repository.getCurrentLocation();
      emit(SafetyLocationLoaded(coordinates: coordinates));
    } catch (e) {
      emit(SafetyError(e.toString()));
    }
  }

  Future<void> refreshLocation() async {
    await loadLocation();
  }
}
