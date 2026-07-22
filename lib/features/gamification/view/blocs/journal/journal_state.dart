import 'package:equatable/equatable.dart';
import '../../../domain/entities/visit_record.dart';

sealed class JournalState extends Equatable {
  const JournalState();

  @override
  List<Object?> get props => [];
}

class JournalInitial extends JournalState {
  const JournalInitial();
}

class JournalLoading extends JournalState {
  const JournalLoading();
}

class JournalLoaded extends JournalState {
  final List<VisitRecord> visits;
  final bool hasMore;

  const JournalLoaded({required this.visits, this.hasMore = false});

  @override
  List<Object?> get props => [visits, hasMore];
}

class JournalError extends JournalState {
  final String message;

  const JournalError(this.message);

  @override
  List<Object?> get props => [message];
}
