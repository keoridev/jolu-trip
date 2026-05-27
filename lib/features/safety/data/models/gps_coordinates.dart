class GpsCoordinates {
  GpsCoordinates({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  String get decimal => '$latitude, $longitude';

  String get dms {
    return '${_toDms(latitude)} N, ${_toDms(longitude)} E';
  }

  String _toDms(double decimal) {
    final degrees = decimal.abs().floor();
    final minutesFull = (decimal.abs() - degrees) * 60;
    final minutes = minutesFull.floor();
    final seconds = ((minutesFull - minutes) * 60).toStringAsFixed(1);
    return '$degrees° $minutes\' $seconds"';
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
  };

  factory GpsCoordinates.fromJson(Map<String, dynamic> json) => GpsCoordinates(
    latitude: json['latitude'] as double,
    longitude: json['longitude'] as double,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
