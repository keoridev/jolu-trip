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
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
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

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(const CheckinFailure('Включите GPS на устройстве'));
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      final result = await _performCheckin(
        usecase.PerformCheckinParams(
          locationId: locationId,
          locationName: locationName,
          locationLat: locationLat,
          locationLng: locationLng,
          userLat: position.latitude,
          userLng: position.longitude,
          accuracy: position.accuracy,
          locationTags: locationTags,
          hasGuideBooking: hasGuideBooking,
        ),
      );

      if (result is usecase.PerformCheckinSuccess) {
        emit(
          CheckinSuccess(
            visit: result.visit,
            newStamps: result.newStamps,
            locationName: locationName,
            isFirstVisit: result.isFirstVisit,
          ),
        );
      } else if (result is usecase.PerformCheckinFailure) {
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