import 'package:jolutrip_app/features/reels/data/models/model.dart';
import 'package:jolutrip_app/features/reels/data/reels_mock.dart';
import 'package:jolutrip_app/features/reels/domain/repositories/reels_repository.dart';

class ReelsRepositoryImpl implements ReelsRepository {
  @override
  Future<List<ReelModel>> getReels() async {
    await Future.delayed(const Duration(microseconds: 800));
    return mockReelsJson.map((json) => ReelModel.fromJson(json)).toList();
  }
}
