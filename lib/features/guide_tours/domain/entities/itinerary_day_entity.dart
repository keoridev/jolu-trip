import 'package:equatable/equatable.dart';

class ItineraryDayEntity extends Equatable {
  final int day;
  final String description;

  const ItineraryDayEntity({required this.day, required this.description});

  @override
  List<Object?> get props => [day, description];
}
