import 'package:jolutrip_app/features/reels/data/models/model.dart';

abstract class ReelsRepository {
  Future<List<ReelModel>> getReels();
}
