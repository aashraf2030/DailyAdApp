import 'dart:io';

import 'package:ads_app/Bloc/Ad/ad_cubit.dart';
import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:ads_app/Bloc/Authority/authority_cubit.dart';
import 'package:ads_app/Bloc/Home/home_cubit.dart';
import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Routing/router.dart';
import 'package:ads_app/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main () async
{
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await initializeDependencies();

  runApp(MyApp(RouteGenerator(
    sl<AuthCubit>(),
    sl<HomeCubit>(),
    sl<OperationalCubit>(),
    sl<AdCubit>(),
    sl<AuthorityCubit>(),
  )));
}

class MyApp extends StatelessWidget{

  late final RouteGenerator router;


  MyApp(this.router, {super.key});

  @override
  Widget build(BuildContext context)
  {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/splash",
      onGenerateRoute: router.generateRoute,
    );
  }
}