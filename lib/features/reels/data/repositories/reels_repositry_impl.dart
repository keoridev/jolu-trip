import 'package:jolutrip_app/core/errors/exceptions.dart';
import 'package:jolutrip_app/features/reels/data/data.dart';
import 'package:jolutrip_app/features/reels/data/datasources/reels_remote_datasource.dart';
import 'package:jolutrip_app/features/reels/domain/domain.dart';

class ReelsRepositoryImpl implements ReelsRepository {
  final ReelsRemoteDataSource _remote;

  List<ReelModel>? _cachedReels;
  DateTime? _lastFetch;

  ReelsRepositoryImpl({required ReelsRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<List<ReelModel>> getReels() async {
    try {
      final reels = await _remote.getReels();

      _cachedReels = reels;
      _lastFetch = DateTime.now();

      return reels;
    } on NetworkException catch (_) {
      if (_cachedReels != null && _cachedReels!.isNotEmpty) {
        return _cachedReels!;
      }
      rethrow;
    }
  }

  @override
  Future<List<ReelModel>> refreshReels() async {
    _cachedReels = null;
    return getReels();
  }

  bool get hasCache => _cachedReels != null && _cachedReels!.isNotEmpty;
}
