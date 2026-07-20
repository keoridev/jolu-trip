import 'package:equatable/equatable.dart';

class TourEntity extends Equatable {
  final String id;
  final String title;
  final String? promoVideoUrl;
  final String departureAt;
  final int durationDays;
  final int totalSeats;
  final int minSeats;
  final int pricePerSeat;
  final String status;
  final List<int> bookedSeats;

  const TourEntity({
    required this.id,
    required this.title,
    this.promoVideoUrl,
    required this.departureAt,
    required this.durationDays,
    required this.totalSeats,
    required this.minSeats,
    required this.pricePerSeat,
    required this.status,
    this.bookedSeats = const [],
  });

  @override
  List<Object?> get props => [
    id,
    title,
    promoVideoUrl,
    departureAt,
    durationDays,
    totalSeats,
    minSeats,
    pricePerSeat,
    status,
    bookedSeats,
  ];
}
