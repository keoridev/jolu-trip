class PersonalRecord {
  final int regionsVisited;
  final int totalLocations;
  final double? farthestFromHomeKm;
  final String? mostVisitedCategory;
  final DateTime updatedAt;

  const PersonalRecord({
    this.regionsVisited = 0,
    this.totalLocations = 0,
    this.farthestFromHomeKm,
    this.mostVisitedCategory,
    required this.updatedAt,
  });
}
