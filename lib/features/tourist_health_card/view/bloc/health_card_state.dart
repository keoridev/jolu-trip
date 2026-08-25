import 'package:equatable/equatable.dart';
import 'package:jolutrip_app/features/tourist_health_card/domain/entities/health_card_entity.dart';

sealed class HealthCardState extends Equatable {
  const HealthCardState();
  @override
  List<Object?> get props => [];
}

class HealthCardInitial extends HealthCardState {}

class HealthCardLoading extends HealthCardState {}

/// Карточка загружена с сервера (может быть null = ещё не создана)
class HealthCardLoaded extends HealthCardState {
  final HealthCardEntity? card;
  const HealthCardLoaded(this.card);
  @override
  List<Object?> get props => [card];
}

class HealthCardSaving extends HealthCardState {
  /// Текущее состояние формы, чтобы UI не терял данные при лоадинге
  final HealthCardEntity draft;
  const HealthCardSaving(this.draft);
  @override
  List<Object?> get props => [draft];
}

class HealthCardSaved extends HealthCardState {
  final HealthCardEntity card;
  const HealthCardSaved(this.card);
  @override
  List<Object?> get props => [card];
}

class HealthCardError extends HealthCardState {
  final String message;
  const HealthCardError(this.message);
  @override
  List<Object?> get props => [message];
}
