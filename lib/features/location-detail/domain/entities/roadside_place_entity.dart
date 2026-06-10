import 'package:equatable/equatable.dart';

enum PlaceCategory {
  ethnoResort,
  cafe,
  shop,
  gasStation,
  viewpoint,
  camping,
  other,
}

class RoadsidePlaceEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final PlaceCategory category;
  final List<String> amenities;
  final double? averageCheck;
  final List<String> photos;
  final String? createdAt;
  final String? updatedAt;

  const RoadsidePlaceEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.amenities,
    this.averageCheck,
    required this.photos,
    this.createdAt,
    this.updatedAt,
  });

  String get categoryLabel => switch (category) {
    PlaceCategory.ethnoResort => 'Этно-отель',
    PlaceCategory.cafe => 'Кафе',
    PlaceCategory.shop => 'Магазин',
    PlaceCategory.gasStation => 'АЗС',
    PlaceCategory.viewpoint => 'Смотровая',
    PlaceCategory.camping => 'Кемпинг',
    PlaceCategory.other => 'Другое',
  };

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    category,
    amenities,
    averageCheck,
    photos,
    createdAt,
    updatedAt,
  ];
}
