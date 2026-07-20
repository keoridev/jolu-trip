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
import 'package:jolutrip_app/features/guide_tours/data/datasource/guide_tours_remote_datasource.dart';
import 'package:jolutrip_app/features/guide_tours/data/repositories/guide_tours_repository_impl.dart';
import 'package:jolutrip_app/features/guide_tours/domain/repositories/guide_tours_repository.dart';
import 'package:jolutrip_app/features/guide_tours/domain/usecases/create_tour_usecase.dart';
import 'package:jolutrip_app/features/guide_tours/domain/usecases/upload_promo_video_usecase.dart';
import 'package:jolutrip_app/features/guide_tours/view/bloc/guide_tours_cubit.dart';

import 'package:jolutrip_app/features/location-detail/view/bloc/location_detail_cubit.dart';
import 'package:jolutrip_app/features/location-detail/data/datasources/location_detail_remote_datasource.dart';
import 'package:jolutrip_app/features/location-detail/data/repositories/location_detail_repository_impl.dart';
import 'package:jolutrip_app/features/location-detail/domain/repositories/location_detail_repository.dart';
import 'package:jolutrip_app/features/locations/data/datasources/locations_remote_datasource.dart';
import 'package:jolutrip_app/features/locations/data/repositories/locations_repository_impl.dart';
import 'package:jolutrip_app/features/locations/domain/repositories/locations_repository.dart';
import 'package:jolutrip_app/features/locations/domain/usecases/get_locations.dart';
import 'package:jolutrip_app/features/locations/view/bloc/locations_cubit.dart';
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

  // ─── Reels ─────────────────────────────────────
  sl.registerLazySingleton<ReelsRemoteDataSource>(
    () => ReelsRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<ReelsRepository>(
    () => ReelsRepositoryImpl(remote: sl()),
  );
  sl.registerFactory(() => ReelsCubit(sl<ReelsRepository>()));

  // ─── Auth Tourist ──────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl()),
  );
  sl.registerFactory(() => AuthCubit(authRepository: sl()));

  // ─── Guide Auth ────────────────────────────────
  sl.registerLazySingleton<GuideAuthRemoteDataSource>(
    () => GuideAuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<GuideAuthRepository>(
    () => GuideAuthRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GuideAuthCubit(sl<GuideAuthRepository>()));

  // ─── Guide Onboarding ──────────────────────────
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

  // ─── Guide Tours ───────────────────────────────
  sl.registerLazySingleton<GuideToursRemoteDataSource>(
    () => GuideToursRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<GuideToursRepository>(
    () => GuideToursRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => CreateTourUseCase(repository: sl()));
  sl.registerLazySingleton(() => UploadPromoVideoUseCase(repository: sl()));
  sl.registerFactory(
    () =>
        GuideToursCubit(createTourUseCase: sl(), uploadPromoVideoUseCase: sl()),
  );

  // ─── Safety ────────────────────────────────────
  sl.registerLazySingleton<SafetyRepository>(() => SafetyRepositoryImpl());
  sl.registerFactory(() => SafetyCubit(repository: sl()));

  sl.registerLazySingleton<LocationsRemoteDataSource>(
    () => LocationsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<LocationsRepository>(
    () => LocationsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetLocationsUseCase(repository: sl()));
  sl.registerFactory(() => LocationsCubit(getLocationsUseCase: sl()));
}
