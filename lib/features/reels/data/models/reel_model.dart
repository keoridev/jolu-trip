import 'package:equatable/equatable.dart';

class ReelModel extends Equatable {
  const ReelModel({
    required this.id,
    required this.name,
    required this.category,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.priceStartsFrom,
    required this.carRequirement,
    required this.hasInternet,
    required this.travelTimeFromCity,
    required this.shortDescription,
  });
  final int id;
  final String name;

  final String category;
  final String videoUrl;
  final String thumbnailUrl;
  final int priceStartsFrom;
  final String carRequirement;
  final bool hasInternet;
  final String travelTimeFromCity;
  final String shortDescription;

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      videoUrl: json['video_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      priceStartsFrom: json['price_starts_from'] as int,
      carRequirement: json['car_requirement'] as String,
      hasInternet: json['has_internet'] as bool,
      travelTimeFromCity: json['travel_time_from_city'] as String,
      shortDescription: json['short_description'] as String,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    videoUrl,
    thumbnailUrl,
    priceStartsFrom,
    carRequirement,
    hasInternet,
    travelTimeFromCity,
    shortDescription,
  ];
}
