import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:jolutrip_app/core/di/dio_client.dart';
import '../../features/auth/bloc/auth_cubit.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/reels/cubit/reels_cubit.dart';
import '../../features/reels/data/data.dart';
import '../../features/reels/domain/domain.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // ─── Core ──────────────────────────────────────
  sl.registerLazySingleton<Dio>(() => DioClient().dio);

  // ─── Reels ───────────────────────────────────────
  sl.registerLazySingleton<ReelsRepository>(() => ReelsRepositoryImpl());
  sl.registerFactory(() => ReelsCubit(sl<ReelsRepository>()));

  // ─── Auth ────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl()),
  );
  sl.registerFactory(() => AuthCubit(authRepository: sl()));
}
