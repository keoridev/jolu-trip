import 'package:equatable/equatable.dart';

class PromoVideoResponseModel extends Equatable {
  final String key;
  final String url;

  const PromoVideoResponseModel({required this.key, required this.url});

  factory PromoVideoResponseModel.fromJson(Map<String, dynamic> json) {
    return PromoVideoResponseModel(
      key: json['key'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'url': url,
  };

  @override
  List<Object?> get props => [key, url];
}