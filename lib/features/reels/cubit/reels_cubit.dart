import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/features/reels/cubit/reels_state.dart';
import 'package:jolutrip_app/features/reels/domain/domain.dart';

class ReelsCubit extends Cubit<ReelsState> {
  final ReelsRepository _repository;

  ReelsCubit(this._repository) : super(ReelsInitial());

  Future<void> loadReels() async {
    emit(ReelsLoading());
    try {
      final reels = await _repository.getReels();
      emit(ReelsLoaded(reels));
    } catch (e) {
      emit(ReelsError('Не удалось загрузить экспедиции: ${e.toString()}'));
    }
  }
}
