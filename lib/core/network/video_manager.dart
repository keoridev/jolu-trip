
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';

class VideoManager extends ChangeNotifier {
  static final VideoManager _instance = VideoManager._();
  factory VideoManager() => _instance;
  VideoManager._();

  VideoPlayerController? _currentController;
  bool _isPlaying = false;

  void registerController(VideoPlayerController controller) {
    if (_currentController != null && _currentController != controller) {
      _pauseCurrent();
    }
    _currentController = controller;
    _isPlaying = controller.value.isPlaying;
    notifyListeners();
  }

  void pauseAll() {
    if (_currentController != null && _currentController!.value.isPlaying) {
      _pauseCurrent();
    }
  }

  void _pauseCurrent() {
    _currentController?.pause();
    _isPlaying = false;
    notifyListeners();
    debugPrint('🎬 Видео поставлено на глобальную паузу');
  }

  void resume() {
    if (_currentController != null && !_currentController!.value.isPlaying) {
      _currentController!.play();
      _isPlaying = true;
      notifyListeners();
      debugPrint('▶️ Видео возобновлено глобально');
    }
  }

  void clear() {
    _currentController = null;
    _isPlaying = false;
  }

  bool get isPlaying => _isPlaying;
}
