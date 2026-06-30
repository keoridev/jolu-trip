import 'package:equatable/equatable.dart';

class TourModel extends Equatable {
  final String id;
  final String title;
  final String? promoVideoUrl;
  final String departureAt;
  final int durationDays;
  final int totalSeats;
  final int minSeats;
  final double pricePerSeat;
  final String status;
  final List<int> bookedSeats;

  const TourModel({
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

  factory TourModel.fromJson(Map<String, dynamic> json) {
    return TourModel(
      id: json['id'] as String,           // ✅ Явный cast
      title: json['title'] as String,
      promoVideoUrl: json['promo_video_url'] as String?,
      departureAt: json['departure_at'] as String,
      durationDays: json['duration_days'] as int,
      totalSeats: json['total_seats'] as int,
      minSeats: json['min_seats'] as int,
      pricePerSeat: (json['price_per_seat'] as num).toDouble(),
      status: json['status'] as String,
      bookedSeats: (json['booked_seats'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    final String tourId = id;             // ✅ Локальная переменная с явным типом
    return {
      'id': tourId,                        // ✅ Используем локальную переменную
      'title': title,
      'promo_video_url': promoVideoUrl,
      'departure_at': departureAt,
      'duration_days': durationDays,
      'total_seats': totalSeats,
      'min_seats': minSeats,
      'price_per_seat': pricePerSeat,
      'status': status,
      'booked_seats': bookedSeats,
    };
  }

  @override
  List<Object?> get props => [
    id, title, promoVideoUrl, departureAt, durationDays,
    totalSeats, minSeats, pricePerSeat, status, bookedSeats,
  ];
}