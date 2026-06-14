import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:jolutrip_app/core/di/dio_client.dart';
import 'package:jolutrip_app/features/auth/bloc/auth_cubit.dart';
import 'package:jolutrip_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:jolutrip_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:jolutrip_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:jolutrip_app/features/guide_auth/bloc/guide_auth_cubit.dart';
import 'package:jolutrip_app/features/guide_auth/data/datasources/guide_auth_remote_datasource.dart';
import 'package:jolutrip_app/features/guide_auth/data/repositories/guide_auth_repository_impl.dart';
import 'package:jolutrip_app/features/guide_auth/domain/repositories/guide_auth_repository.dart';
import 'package:jolutrip_app/features/location-detail/bloc/location_detail_cubit.dart';
import 'package:jolutrip_app/features/location-detail/data/datasources/location_detail_remote_datasource.dart';
import 'package:jolutrip_app/features/location-detail/data/repositories/location_detail_repository_impl.dart';
import 'package:jolutrip_app/features/location-detail/domain/repositories/location_detail_repository.dart';
import 'package:jolutrip_app/features/reels/cubit/reels_cubit.dart';
import 'package:jolutrip_app/features/reels/data/data.dart';
import 'package:jolutrip_app/features/reels/data/datasources/reels_remote_datasource.dart';
import 'package:jolutrip_app/features/reels/domain/repositories/reels_repository.dart';
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

  // ─── Auth (Tourist) ──────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl()),
  );
  sl.registerFactory(() => AuthCubit(authRepository: sl()));

  // ─── Guide Auth ──────────────────────────────
  sl.registerLazySingleton<GuideAuthRemoteDataSource>(
    () => GuideAuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<GuideAuthRepository>(
    () => GuideAuthRepositoryImpl(remote: sl()),
  );
  // 🔥 Только LazySingleton — shared между AuthScreen и OnboardingScreen
  sl.registerLazySingleton(() => GuideAuthCubit(sl<GuideAuthRepository>()));

  // ─── Location Detail ───────────────────────────
  sl.registerLazySingleton<LocationDetailRemoteDataSource>(
    () => LocationDetailRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<LocationDetailRepository>(
    () => LocationDetailRepositoryImpl(remote: sl()),
  );
  sl.registerFactory(() => LocationDetailCubit(sl<LocationDetailRepository>()));

  // ─── Safety ────────────────────────────────────
  sl.registerLazySingleton<SafetyRepository>(() => SafetyRepositoryImpl());
  sl.registerFactory(() => SafetyCubit(repository: sl()));
}
