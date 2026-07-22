enum StampRarity { common, silver, gold, legendary }

class Stamp {
  final String id;
  final String title;
  final String description;
  final String imageAsset;
  final StampRarity rarity;
  final DateTime? earnedAt;

  const Stamp({
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
    this.rarity = StampRarity.common,
    this.earnedAt,
  });

  Stamp copyWith({
    String? id,
    String? title,
    String? description,
    String? imageAsset,
    StampRarity? rarity,
    DateTime? earnedAt,
  }) {
    return Stamp(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageAsset: imageAsset ?? this.imageAsset,
      rarity: rarity ?? this.rarity,
      earnedAt: earnedAt ?? this.earnedAt,
    );
  }
}
