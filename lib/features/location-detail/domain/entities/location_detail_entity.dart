
import 'package:equatable/equatable.dart';
import 'roadside_place_entity.dart';

class LocationDetailEntity extends Equatable {
  final String id;
  final String name;
  final String shortDescription;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final String category;
  final bool hasInternet;
  final String carRequirement;
  final int travelDays;
  final int travelHours;
  final int travelMinutes;
  final double priceStartsFrom;
  final double? entryFee;
  final double latitude;
  final double longitude;
  final List<String> roadFeatures;
  final List<String> gearList;
  final List<RoadsidePlaceEntity> roadsidePlaces;

  const LocationDetailEntity({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.category,
    required this.hasInternet,
    required this.carRequirement,
    required this.travelDays,
    required this.travelHours,
    required this.travelMinutes,
    required this.priceStartsFrom,
    this.entryFee,
    required this.latitude,
    required this.longitude,
    required this.roadFeatures,
    required this.gearList,
    required this.roadsidePlaces,
  });

  String get formattedDuration {
    final parts = <String>[];
    if (travelDays > 0) parts.add('$travelDays д');
    if (travelHours > 0) parts.add('$travelHours ч');
    if (travelMinutes > 0) parts.add('$travelMinutes мин');
    return parts.isEmpty ? '—' : parts.join(' ');
  }

  String get formattedCoordinates {
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    shortDescription,
    description,
    videoUrl,
    thumbnailUrl,
    category,
    hasInternet,
    carRequirement,
    travelDays,
    travelHours,
    travelMinutes,
    priceStartsFrom,
    entryFee,
    latitude,
    longitude,
    roadFeatures,
    gearList,
    roadsidePlaces,
  ];
}
