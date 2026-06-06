import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:jolutrip_app/core/di/dio_client.dart';
import 'package:jolutrip_app/features/auth/bloc/auth_cubit.dart';
import 'package:jolutrip_app/features/auth/data/data.dart';
import 'package:jolutrip_app/features/auth/domain/repositories/repositories.dart';
import 'package:jolutrip_app/features/reels/cubit/reels_cubit.dart';
import 'package:jolutrip_app/features/reels/data/data.dart';
import 'package:jolutrip_app/features/reels/data/datasources/reels_remote_datasource.dart';
import 'package:jolutrip_app/features/reels/domain/domain.dart';
import 'package:jolutrip_app/features/safety/bloc/safety_cubit.dart';
import 'package:jolutrip_app/features/safety/data/repositories/safety_repository_impl.dart';
import 'package:jolutrip_app/features/safety/domain/repositories/safety_repository.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // ─── Core ──────────────────────────────────────
  sl.registerLazySingleton<Dio>(() => DioClient().dio);

  // ─── Reels ─────────────────────────────────────
  sl.registerLazySingleton<ReelsRemoteDataSource>(
    () => ReelsRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<ReelsRepository>(
    () => ReelsRepositoryImpl(remote: sl()),
  );
  sl.registerFactory(() => ReelsCubit(sl<ReelsRepository>()));

  // ─── Auth ──────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl()),
  );
  sl.registerFactory(() => AuthCubit(authRepository: sl()));

  sl.registerLazySingleton<SafetyRepository>(() => SafetyRepositoryImpl());
  sl.registerFactory(() => SafetyCubit(repository: sl()));
}
