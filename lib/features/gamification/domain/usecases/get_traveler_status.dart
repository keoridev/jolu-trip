class TravelerStatus {
  final String title;
  final String iconName;
  final int minStamps;
  final String description;

  const TravelerStatus({
    required this.title,
    required this.iconName,
    required this.minStamps,
    required this.description,
  });
}

class GetTravelerStatus {
  static const List<TravelerStatus> _statuses = [
    TravelerStatus(
      title: 'Турист',
      iconName: 'person',
      minStamps: 0,
      description: 'Начало пути',
    ),
    TravelerStatus(
      title: 'Следопыт',
      iconName: 'footprints',
      minStamps: 1,
      description: 'Первые открытия',
    ),
    TravelerStatus(
      title: 'Странник',
      iconName: 'hiking',
      minStamps: 5,
      description: 'Исследуете мир',
    ),
    TravelerStatus(
      title: 'Картограф',
      iconName: 'explore',
      minStamps: 10,
      description: 'Знаете каждый уголок',
    ),
    TravelerStatus(
      title: 'Местный эксперт',
      iconName: 'star',
      minStamps: 20,
      description: 'Живая энциклопедия',
    ),
  ];

  TravelerStatus call(int stampCount) {
    for (int i = _statuses.length - 1; i >= 0; i--) {
      if (stampCount >= _statuses[i].minStamps) {
        return _statuses[i];
      }
    }
    return _statuses.first;
  }
}
