import '../../data/models/gps_coordinates.dart';

abstract class SafetyRepository {
  Future<GpsCoordinates?> getCurrentLocation();
  Future<bool> hasLocationPermission();
  Future<void> requestLocationPermission();
}
