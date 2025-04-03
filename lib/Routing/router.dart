import 'package:ads_app/Bloc/Ad/ad_cubit.dart';
import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:ads_app/Bloc/Authority/authority_cubit.dart';
import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Models/ad_models.dart';
import 'package:ads_app/Models/category_model.dart';
import 'package:ads_app/Pages/Ads/edit_ad_page.dart';
import 'package:ads_app/Pages/Home/category_page.dart';
import 'package:ads_app/Pages/Home/home_page.dart';
import 'package:ads_app/Pages/Login/change_pass_page.dart';
import 'package:ads_app/Pages/Login/email_verification_page.dart';
import 'package:ads_app/Pages/Login/login_page.dart';
import 'package:ads_app/Pages/Login/pass_reset_page.dart';
import 'package:ads_app/Pages/Login/pass_reset_request_page.dart';
import 'package:ads_app/Pages/Login/register_page.dart';
import 'package:ads_app/Pages/Ads/create_ad_page.dart';
import 'package:ads_app/Pages/Other/ad_view.dart';
import 'package:ads_app/Pages/Other/my_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Bloc/Home/home_cubit.dart';

class RouteGenerator {

  final AuthCubit auth;
  final HomeCubit home;
  final OperationalCubit operational;
  final AdCubit ad;
  final AuthorityCubit authority;

  RouteGenerator(this.auth, this.home, this.operational, this.ad, this.authority);

  Route<dynamic> generateRoute(RouteSettings settings)
  {
    switch(settings.name)
    {
      case "/home":

        home.changeRoute(0);

        return animateThis(FutureBuilder<bool>(future: auth.isLoggedIn(),
            builder: (context, res) {
              if (res.hasData)
                {
                  if ((res.data)!)
                    {
                      return FutureBuilder<bool>(future: auth.verifyCheck(),
                          builder: (context, res) {
                            if (res.hasData)
                            {
                              if ((res.data)!)
                              {
                                return MultiBlocProvider(providers: [BlocProvider.value(value: home),
                                  BlocProvider.value(value: ad),
                                  BlocProvider.value(value: auth),
                                  BlocProvider.value(value: operational),
                                  BlocProvider.value(value: authority),
                                ]
                                  , child: HomePage(),);
                              }
                              else
                              {
                                return BlocProvider.value(value: auth, child: EmailVerificationPage(),);
                              }
                            }
                            else if (res.hasError)
                            {
                              return ErrorRoute();
                            }
                            else
                            {
                              return Center(child: SizedBox(width: 30,
                                height: 30, child: CircularProgressIndicator(),));
                            }
                          }
                      );

                    }
                  else
                    {
                      return BlocProvider.value(value: auth, child: LoginPage(),);
                    }
                }
              else if (res.hasError)
                {
                  return ErrorRoute();
                }
              else
                {
                  return Scaffold(
                    body: Center(child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(),)),
                  );
                }
            }
        ));

      case "/login":
        return animateThis(FutureBuilder<bool>(future: auth.isLoggedIn(),
            builder: (context, res) {
              if (res.hasData)
              {
                if ((res.data)!)
                {
                  return FutureBuilder<bool>(future: auth.verifyCheck(),
                      builder: (context, res) {
                        if (res.hasData)
                        {
                          if ((res.data)!)
                          {
                            return MultiBlocProvider(providers: [BlocProvider.value(value: home),
                              BlocProvider.value(value: ad),
                              BlocProvider.value(value: auth),
                              BlocProvider.value(value: operational),
                              BlocProvider.value(value: authority),
                            ]
                              , child: HomePage(),);
                          }
                          else
                          {
                            return BlocProvider.value(value: auth, child: EmailVerificationPage(),);
                          }
                        }
                        else if (res.hasError)
                        {
                          return ErrorRoute();
                        }
                        else
                        {
                          return Center(child: SizedBox(width: 30, height: 30,
                            child: CircularProgressIndicator(),));
                        }
                      }
                  );
                }
                else
                {
                  return BlocProvider.value(value: auth, child: LoginPage(),);
                }
              }
              else if (res.hasError)
              {
                return ErrorRoute();
              }
              else
              {
                return Scaffold(
                  body: Center(child: SizedBox(width: 30, height: 30,
                    child: CircularProgressIndicator(),)),
                );
              }
            }
        ));

      case "/register":
        return animateThis(BlocProvider.value(value: auth, child: RegisterPage()));

      case "/verify":
        return animateThis(BlocProvider.value(value: auth, child: EmailVerificationPage(),));

      case "/pass_reset_request":
        return animateThis(
            BlocProvider.value(value: auth, child: PassResetRequestPage(),));

      case "/pass_reset":
          return animateThis(
              BlocProvider.value(value: auth, child: PassResetPage(),));

      case "/change_pass":
          return animateThis(
              BlocProvider.value(value: auth, child: ChangePassPage(),));

      case "/create_ad":
          return animateThis(
              BlocProvider.value(value: operational, child: CreateAdPage(),));

      case "/edit_ad":

        final AdData ad = settings.arguments as AdData;

        return animateThis(
            BlocProvider.value(value: operational, child: EditAdPage(ad: ad),));

      case "/view":
        return animateThis(AdView(ad: settings.arguments as AdData));

      case "/my_request":
        return animateThis(BlocProvider.value(value: authority,
          child: MyRequestPage(),));

      case "/show_cat":

        final cat = settings.arguments as Category;

        return animateThis(MultiBlocProvider(providers: [
          BlocProvider.value(value: ad), BlocProvider.value(value: operational)
        ], child: CategoryPage(category: cat),));

      default:
        return animateThis(ErrorRoute());
    }
  }

  PageRouteBuilder<dynamic> animateThis(Widget x)
  {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => PopScope(
          canPop: false,
          onPopInvokedWithResult: (_, __) {return;},
          child: x),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const start = Offset(1, 0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: start, end: end);
        final curvedAnim = CurvedAnimation(parent: animation, curve: curve);

        return SlideTransition(position: tween.animate(curvedAnim), child: child);
      }
    );
  }
}

class ErrorRoute extends StatelessWidget{
  const ErrorRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("خطأ"),),
      body: Center(
        child: Column(
          children: [
            Text("خطأ", style: TextStyle(color: Colors.red),),
            OutlinedButton(onPressed: () {Navigator.pushNamed(context, "/login");}
                , child: Text("العودة"))
          ],
        ),
      ),
    );
  }
}