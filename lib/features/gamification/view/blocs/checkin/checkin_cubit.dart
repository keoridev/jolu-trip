// lib/features/gamification/presentation/blocs/checkin/checkin_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../domain/usecases/perform_checkin.dart' as usecase;
import 'checkin_state.dart';

class CheckinCubit extends Cubit<CheckinState> {
  final usecase.PerformCheckin _performCheckin;

  CheckinCubit(this._performCheckin) : super(const CheckinIdle());

  Future<void> checkin({
    required String locationId,
    required String locationName,
    required double locationLat,
    required double locationLng,
    required List<String> locationTags,
    bool hasGuideBooking = false,
  }) async {
    emit(const CheckinValidating());

    try {
      // 1. Проверяем и запрашиваем разрешение
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          emit(const CheckinFailure('Разрешение на геолокацию отклонено'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(
          const CheckinFailure(
            'Геолокация отключена в настройках. Включите её и попробуйте снова.',
          ),
        );
        return;
      }

      // 2. Проверяем включён ли GPS
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(const CheckinFailure('Включите GPS на устройстве'));
        return;
      }

      // 3. Получаем позицию
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      // 4. Вызываем use case
      final result = await _performCheckin(
        usecase.PerformCheckinParams(
          locationId: locationId,
          locationName: locationName,
          locationLat: locationLat,
          locationLng: locationLng,
          accuracy: position.accuracy,
          locationTags: locationTags,
          hasGuideBooking: hasGuideBooking,
        ),
      );

      if (result is usecase.CheckinSuccess) {
        emit(
          CheckinSuccess(
            visit: result.visit,
            newStamps: result.newStamps,
            locationName: locationName,
            isFirstVisit: result.isFirstVisit,
          ),
        );
      } else if (result is usecase.CheckinFailure) {
        emit(CheckinFailure(result.message));
      }
    } catch (e) {
      emit(CheckinFailure('Ошибка: $e'));
    }
  }

  void reset() {
    emit(const CheckinIdle());
  }
}
