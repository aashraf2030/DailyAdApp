import 'dart:io';

import 'package:ads_app/Bloc/Ad/ad_cubit.dart';
import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:ads_app/Bloc/Authority/authority_cubit.dart';
import 'package:ads_app/Bloc/Home/home_cubit.dart';
import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Routing/router.dart';
import 'package:ads_app/core/di/service_locator.dart';
import 'package:ads_app/core/widgets/safe_fallback_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();

  // 1. Lock Orientation Early
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 2. Setup Global Error Handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint("🔴 [FLUTTER ERROR] ${details.exception}");
  };

  ErrorWidget.builder = (details) {
    return SafeFallbackUI(
      errorMessage: "خطأ في عرض الواجهة: ${details.exception.toString().split('\n').first}",
      isFullPage: false,
    );
  };

  try {
    // 3. Initialize dependency injection
    await initializeDependencies();

    runApp(MyApp(RouteGenerator(
      sl<AuthCubit>(),
      sl<HomeCubit>(),
      sl<OperationalCubit>(),
      sl<AdCubit>(),
      sl<AuthorityCubit>(),
    )));
  } catch (e) {
    debugPrint("🔴 [INIT ERROR] Failed to initialize app: $e");
    // Run app with error UI if initialization fails
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeFallbackUI(
        errorMessage: "فشل تهيئة التطبيق: $e",
        onRetry: () => main(),
      ),
    ));
  }
}

class MyApp extends StatelessWidget{

  late final RouteGenerator router;


  MyApp(this.router, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/splash",
      onGenerateRoute: router.generateRoute,
    );
  }
}