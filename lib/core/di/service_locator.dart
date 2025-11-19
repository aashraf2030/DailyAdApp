import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Bloc/Ad/ad_cubit.dart';
import '../../Bloc/Auth/auth_cubit.dart';
import '../../Bloc/Authority/authority_cubit.dart';
import '../../Bloc/Home/home_cubit.dart';
import '../../Bloc/Operational/operational_cubit.dart';
import '../../Bloc/chat/chat_cubit.dart';
import '../../Repos/ad_repo.dart';
import '../../Repos/auth_repo.dart';
import '../../Repos/authority_repo.dart';
import '../../Repos/chat_repo.dart';
import '../../Web/ad_web.dart';
import '../../Web/auth_web.dart';
import '../../Web/authority_web.dart';
import '../../Web/chat_web.dart';
import '../../network/interceptors.dart' show AuthInterceptor, LoggerInterceptor;
import '../constants/app_constants.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
/// This should be called once in main() before runApp()
Future<void> initializeDependencies() async {
  // ============================================
  // External Dependencies
  // ============================================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // ============================================
  // Dio Configuration
  // ============================================
  sl.registerLazySingleton<Dio>(() {
    final options = BaseOptions(
      connectTimeout: Duration(seconds: AppConstants.connectionTimeout),
      receiveTimeout: Duration(seconds: AppConstants.receiveTimeout),
      receiveDataWhenStatusError: true,
    );

    final dio = Dio(options);
    dio.interceptors.addAll([
      AuthInterceptor(sl<SharedPreferences>()),
      LoggerInterceptor(),
    ]);

    return dio;
  });

  // ============================================
  // Web Services (Data Sources)
  // ============================================
  sl.registerLazySingleton<AuthServices>(() => AuthServices(sl<Dio>()));
  sl.registerLazySingleton<AdsWebServices>(() => AdsWebServices(sl<Dio>()));
  sl.registerLazySingleton<AuthorityWebServices>(
      () => AuthorityWebServices(sl<Dio>()));
  sl.registerLazySingleton<ChatWebServices>(() => ChatWebServices(sl<Dio>()));

  // ============================================
  // Repositories
  // ============================================
  sl.registerLazySingleton<AuthRepo>(() => AuthRepo(sl<AuthServices>()));
  sl.registerLazySingleton<AdsRepo>(() => AdsRepo(sl<AdsWebServices>()));
  sl.registerLazySingleton<AuthorityRepo>(
      () => AuthorityRepo(sl<AuthorityWebServices>()));
  sl.registerLazySingleton<ChatRepo>(() => ChatRepo(sl<ChatWebServices>()));

  // ============================================
  // Blocs/Cubits (Factories for new instances)
  // ============================================
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      AuthInitial(),
      sl<SharedPreferences>(),
      sl<AuthRepo>(),
    ),
  );

  sl.registerFactory<HomeCubit>(
    () => HomeCubit(
      HomeInitialState(),
      sl<SharedPreferences>(),
      sl<AdsRepo>(),
    ),
  );

  sl.registerFactory<OperationalCubit>(
    () => OperationalCubit(
      InitialOperational(),
      sl<SharedPreferences>(),
      sl<AdsRepo>(),
    ),
  );

  sl.registerFactory<AdCubit>(
    () => AdCubit(
      AdInitialState(),
      sl<SharedPreferences>(),
      sl<AdsRepo>(),
    ),
  );

  sl.registerFactory<AuthorityCubit>(
    () => AuthorityCubit(
      AuthorityInitial(),
      sl<SharedPreferences>(),
      sl<AuthorityRepo>(),
    ),
  );

  sl.registerFactory<ChatCubit>(
    () => ChatCubit(
      sl<ChatRepo>(),
      sl<SharedPreferences>(),
    ),
  );
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}

