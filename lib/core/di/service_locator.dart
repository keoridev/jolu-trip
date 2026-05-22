import 'package:get_it/get_it.dart';
import 'package:jolutrip_app/features/reels/cubit/reels_cubit.dart';
import 'package:jolutrip_app/features/reels/data/data.dart';
import 'package:jolutrip_app/features/reels/domain/domain.dart';

final sl = GetIt.instance;

void setupDependencies() {
  sl.registerLazySingleton<ReelsRepository>(() => ReelsRepositoryImpl());

  sl.registerFactory(() => ReelsCubit(sl<ReelsRepository>()));
}
