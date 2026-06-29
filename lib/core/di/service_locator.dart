import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:jolutrip_app/core/di/dio_client.dart';
import 'package:jolutrip_app/features/auth/view/bloc/auth_cubit.dart';
import 'package:jolutrip_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:jolutrip_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:jolutrip_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:jolutrip_app/features/guide-profile/data/data.dart';
import 'package:jolutrip_app/features/guide-profile/data/datasources/datasources.dart';
import 'package:jolutrip_app/features/guide-profile/domain/repositories/guide_profile_repository.dart';
import 'package:jolutrip_app/features/guide-profile/view/bloc/guide_profile_cubit.dart';
import 'package:jolutrip_app/features/guide_auth/view/bloc/guide_auth_cubit.dart';
import 'package:jolutrip_app/features/guide_auth/data/datasources/guide_auth_remote_datasource.dart';
import 'package:jolutrip_app/features/guide_auth/data/repositories/guide_auth_repository_impl.dart';
import 'package:jolutrip_app/features/guide_auth/domain/repositories/guide_auth_repository.dart';

// 🔥 Импорты для онбординга
import 'package:jolutrip_app/features/guide_onboarding/view/bloc/guide_onboarding_cubit.dart';
import 'package:jolutrip_app/features/guide_onboarding/data/datasources/guide_onboarding_remote_datasource.dart';
import 'package:jolutrip_app/features/guide_onboarding/data/repositories/guide_onboarding_repository_impl.dart';
import 'package:jolutrip_app/features/guide_onboarding/domain/repositories/guide_onboarding_repository.dart';

import 'package:jolutrip_app/features/location-detail/view/bloc/location_detail_cubit.dart';
import 'package:jolutrip_app/features/location-detail/data/datasources/location_detail_remote_datasource.dart';
import 'package:jolutrip_app/features/location-detail/data/repositories/location_detail_repository_impl.dart';
import 'package:jolutrip_app/features/location-detail/domain/repositories/location_detail_repository.dart';
import 'package:jolutrip_app/features/reels/view/bloc/reels_cubit.dart';
import 'package:jolutrip_app/features/reels/data/data.dart';
import 'package:jolutrip_app/features/reels/data/datasources/reels_remote_datasource.dart';
import 'package:jolutrip_app/features/reels/domain/repositories/reels_repository.dart';
import 'package:jolutrip_app/features/safety/view/bloc/safety_cubit.dart';
import 'package:jolutrip_app/features/safety/data/repositories/safety_repository_impl.dart';
import 'package:jolutrip_app/features/safety/domain/repositories/safety_repository.dart';

final sl = GetIt.instance;

void setupDependencies() {
  sl.registerLazySingleton<Dio>(() => DioClient().dio);

  sl.registerLazySingleton<ReelsRemoteDataSource>(
    () => ReelsRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<ReelsRepository>(
    () => ReelsRepositoryImpl(remote: sl()),
  );
  sl.registerFactory(() => ReelsCubit(sl<ReelsRepository>()));

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
  sl.registerLazySingleton(() => GuideAuthCubit(sl<GuideAuthRepository>()));

  // ═══════════════════════════════════════════════════
  // 🔥 GUIDE ONBOARDING — РЕГИСТРИРУЕМ!
  // ═══════════════════════════════════════════════════
  sl.registerLazySingleton<GuideOnboardingRemoteDataSource>(
    () => GuideOnboardingRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<GuideOnboardingRepository>(
    () => GuideOnboardingRepositoryImpl(sl<GuideOnboardingRemoteDataSource>()),
  );

  sl.registerFactory<GuideOnboardingCubit>(
    () => GuideOnboardingCubit(sl<GuideOnboardingRepository>()),
  );

    // ─── Guide Profile ─────────────────────────────
  sl.registerLazySingleton<GuideProfileRemoteDataSource>(
    () => GuideProfileRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<GuideProfileRepository>(
    () => GuideProfileRepositoryImpl(sl<GuideProfileRemoteDataSource>()),
  );
  sl.registerFactory(() => GuideProfileCubit(sl<GuideProfileRepository>()));
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
