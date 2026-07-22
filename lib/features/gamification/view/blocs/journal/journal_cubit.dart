import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/features/gamification/domain/entities/entities.dart';
import '../../../domain/repositories/journal_repository.dart';
import 'journal_state.dart';

class JournalCubit extends Cubit<JournalState> {
  final JournalRepository _repository;

  JournalCubit(this._repository) : super(const JournalInitial());

  Future<void> loadJournal() async {
    emit(const JournalLoading());
    try {
      final visits = await _repository.getAllVisits();
      // Сортируем по дате, новые сверху
      visits.sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
      emit(JournalLoaded(visits: visits));
    } catch (e) {
      emit(JournalError('Не удалось загрузить журнал: $e'));
    }
  }

  Future<void> addVisit(VisitRecord visit) async {
    try {
      await _repository.saveVisit(visit);
      await loadJournal();
    } catch (e) {
      emit(JournalError('Не удалось сохранить посещение: $e'));
    }
  }

  Future<void> deleteVisit(String id) async {
    try {
      await _repository.deleteVisit(id);
      await loadJournal();
    } catch (e) {
      emit(JournalError('Не удалось удалить запись: $e'));
    }
  }
}
