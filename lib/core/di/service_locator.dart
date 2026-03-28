import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
import '../../Bloc/Store/store_cubit.dart';
import '../../Repos/store_repo.dart';
import '../../Web/store_web.dart';
import '../../Services/account_manager_service.dart';


final sl = GetIt.instance;



Future<void> initializeDependencies() async {
  
  
  
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  
  
  
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

  
  
  
  sl.registerLazySingleton<AuthServices>(() => AuthServices(sl<Dio>()));
  sl.registerLazySingleton<AdsWebServices>(() => AdsWebServices(sl<Dio>()));
  sl.registerLazySingleton<AuthorityWebServices>(
      () => AuthorityWebServices(sl<Dio>()));
  sl.registerLazySingleton<ChatWebServices>(() => ChatWebServices(sl<Dio>()));

  
  
  
  sl.registerLazySingleton<AuthRepo>(() => AuthRepo(sl<AuthServices>()));
  sl.registerLazySingleton<AdsRepo>(() => AdsRepo(sl<AdsWebServices>()));
  sl.registerLazySingleton<AuthorityRepo>(
      () => AuthorityRepo(sl<AuthorityWebServices>()));
  sl.registerLazySingleton<ChatRepo>(() => ChatRepo(sl<ChatWebServices>()));

  
  
  
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      AuthInitial(),
      sl<SharedPreferences>(),
      sl<AuthRepo>(),
      sl<AccountManagerService>(),
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

  
  
  
  sl.registerLazySingleton<StoreServices>(() => StoreServices(sl<Dio>()));
  sl.registerLazySingleton<StoreRepo>(() => StoreRepo(sl<StoreServices>()));
  sl.registerFactory<StoreCubit>(() => StoreCubit(sl<StoreRepo>()));

  
  
  
  sl.registerLazySingleton<AccountManagerService>(
    () => AccountManagerService(
      sl<SharedPreferences>(),
      sl<FlutterSecureStorage>(),
    ),
  );
}


Future<void> resetDependencies() async {
  await sl.reset();
}

