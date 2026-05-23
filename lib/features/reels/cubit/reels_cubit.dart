
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/features/reels/cubit/reels_state.dart';
import 'package:jolutrip_app/features/reels/domain/domain.dart';

class ReelsCubit extends Cubit<ReelsState> {
  final ReelsRepository _repository;

  final Map<int, dynamic> _videoControllers = {};

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

  void registerVideoController(int index, dynamic controller) {
    _videoControllers[index] = controller;

    final currentState = state;
    if (currentState is ReelsLoaded &&
        currentState.currentIndex == index &&
        currentState.isPlaying) {
      controller.play();
    }
  }

  void pauseCurrentVideo() {
    final currentState = state;
    if (currentState is ReelsLoaded && currentState.isPlaying) {
      final controller = _videoControllers[currentState.currentIndex];
      if (controller != null) {
        controller.pause();
        emit(currentState.copyWith(isPlaying: false));
      }
    }
  }

  // Возобновление текущего видео
  void resumeCurrentVideo() {
    final currentState = state;
    if (currentState is ReelsLoaded && !currentState.isPlaying) {
      final controller = _videoControllers[currentState.currentIndex];
      if (controller != null) {
        controller.play();
        emit(currentState.copyWith(isPlaying: true));
      }
    }
  }

  // Смена текущего видео
  void setCurrentIndex(int index) {
    final currentState = state;
    if (currentState is ReelsLoaded && currentState.currentIndex != index) {
      // Пауза старого видео
      final oldController = _videoControllers[currentState.currentIndex];
      if (oldController != null) {
        oldController.pause();
        oldController.seekTo(Duration.zero);
      }

      // Запуск нового видео
      final newController = _videoControllers[index];
      if (newController != null && currentState.isPlaying) {
        newController.play();
      }

      emit(currentState.copyWith(currentIndex: index));
    }
  }

  // Очистка контроллеров при закрытии
  void disposeControllers() {
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
  }

  @override
  Future<void> close() {
    disposeControllers();
    return super.close();
  }
}
