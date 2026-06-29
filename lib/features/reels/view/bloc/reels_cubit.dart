import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/features/reels/view/bloc/reels_state.dart';
import 'package:jolutrip_app/features/reels/domain/domain.dart';

class ReelsCubit extends Cubit<ReelsState> {
  final ReelsRepository _repository;

  ReelsCubit(this._repository) : super(ReelsInitial());

  Future<void> loadReels() async {
    if (state is ReelsLoading) return;

    emit(ReelsLoading());
    try {
      final reels = await _repository.getReels();
      emit(ReelsLoaded(reels: reels, currentIndex: 0));
    } catch (e) {
      emit(ReelsError('Не удалось загрузить экспедиции: ${e.toString()}'));
    }
  }

  /// 🔥 Pull-to-refresh — сбрасывает индекс и перезагружает
  Future<void> refreshReels() async {
    emit(ReelsLoading());
    try {
      final reels = await _repository.getReels();
      emit(ReelsLoaded(reels: reels, currentIndex: 0));
    } catch (e) {
      emit(ReelsError('Не удалось обновить: ${e.toString()}'));
    }
  }

  void setCurrentIndex(int index) {
    final currentState = state;
    if (currentState is ReelsLoaded && currentState.currentIndex != index) {
      emit(currentState.copyWith(currentIndex: index));
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
