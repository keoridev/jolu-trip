class Collection {
  final String id;
  final String title;
  final String description;
  final List<String> stampIds;
  final List<String> earnedStampIds;
  final bool isSeasonal;
  final DateTime? validUntil;
  final bool isArchived;

  const Collection({
    required this.id,
    required this.title,
    required this.description,
    required this.stampIds,
    this.earnedStampIds = const [],
    this.isSeasonal = false,
    this.validUntil,
    this.isArchived = false,
  });

  bool get isCompleted =>
      stampIds.isNotEmpty && earnedStampIds.length == stampIds.length;

  double get progress =>
      stampIds.isEmpty ? 0.0 : earnedStampIds.length / stampIds.length;

  int get remaining => stampIds.length - earnedStampIds.length;

  Collection copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? stampIds,
    List<String>? earnedStampIds,
    bool? isSeasonal,
    DateTime? validUntil,
    bool? isArchived,
  }) {
    return Collection(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      stampIds: stampIds ?? this.stampIds,
      earnedStampIds: earnedStampIds ?? this.earnedStampIds,
      isSeasonal: isSeasonal ?? this.isSeasonal,
      validUntil: validUntil ?? this.validUntil,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
