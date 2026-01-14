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
import 'package:ads_app/Pages/Login/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Bloc/chat/chat_cubit.dart';
import '../Pages/chat/chat_page.dart';
import '../core/di/service_locator.dart';
import '../Bloc/Home/home_cubit.dart';

class RouteGenerator {
  final AuthCubit auth;
  final HomeCubit home;
  final OperationalCubit operational;
  final AdCubit ad;
  final AuthorityCubit authority;

  RouteGenerator(
      this.auth, this.home, this.operational, this.ad, this.authority);

  Route<dynamic> generateRoute(RouteSettings settings) {
    print("🔷 [ROUTER] generateRoute called with: ${settings.name}");
    switch (settings.name) {
      case "/splash":
        return animateThis(
            BlocProvider.value(value: auth, child: SplashPage()));

      case "/home":
        print("🟢 [ROUTER] /home route called");
        home.changeRoute(0);

        return animateThis(FutureBuilder<bool>(
            future: auth.isLoggedIn(),
            builder: (context, res) {
              print("🟢 [ROUTER] isLoggedIn FutureBuilder - hasData: ${res.hasData}, hasError: ${res.hasError}, data: ${res.data}");
              if (res.hasData) {
                print("🟢 [ROUTER] isLoggedIn returned: ${res.data}");
                if ((res.data)!) {
                  return FutureBuilder<bool>(
                      future: auth.verifyCheck(),
                      builder: (context, res) {
                        if (res.hasData) {
                          if ((res.data)!) {
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider.value(value: home),
                                BlocProvider.value(value: ad),
                                BlocProvider.value(value: auth),
                                BlocProvider.value(value: operational),
                                BlocProvider.value(value: authority),
                                BlocProvider(create: (_) => sl<ChatCubit>()),
                              ],
                              child: HomePage(),
                            );
                          } else {
                            return BlocProvider.value(
                              value: auth,
                              child: EmailVerificationPage(),
                            );
                          }
                        } else if (res.hasError) {
                          print("🔴 [ROUTER] verifyCheck ERROR: ${res.error}");
                          // If verification check fails, stay in app (allow guest browsing)
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider.value(value: home),
                              BlocProvider.value(value: ad),
                              BlocProvider.value(value: auth),
                              BlocProvider.value(value: operational),
                              BlocProvider.value(value: authority),
                              BlocProvider(create: (_) => sl<ChatCubit>()),
                            ],
                            child: HomePage(),
                          );
                        } else {
                          return Center(
                              child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(),
                          ));
                        }
                      });
                } else {
                  // User not logged in - allow guest browsing (go to HomePage)
                  print("🟢 [ROUTER] User not logged in - showing HomePage for guest browsing");
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: home),
                      BlocProvider.value(value: ad),
                      BlocProvider.value(value: auth),
                      BlocProvider.value(value: operational),
                      BlocProvider.value(value: authority),
                      BlocProvider(create: (_) => sl<ChatCubit>()),
                    ],
                    child: HomePage(),
                  );
                }
              } else if (res.hasError) {
                print("🔴 [ROUTER] isLoggedIn ERROR: ${res.error}");
                // If login check fails, stay in app (allow guest browsing)
                return MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: home),
                    BlocProvider.value(value: ad),
                    BlocProvider.value(value: auth),
                    BlocProvider.value(value: operational),
                    BlocProvider.value(value: authority),
                    BlocProvider(create: (_) => sl<ChatCubit>()),
                  ],
                  child: HomePage(),
                );
              } else {
                return Scaffold(
                  body: Center(
                      child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(),
                  )),
                );
              }
            }));

      case "/login":
        return animateThis(BlocProvider.value(value: auth, child: LoginPage()));

      case "/register":
        return animateThis(
            BlocProvider.value(value: auth, child: RegisterPage()));

      case "/verify":
        return animateThis(BlocProvider.value(
          value: auth,
          child: EmailVerificationPage(),
        ));

      case "/pass_reset_request":
        return animateThis(BlocProvider.value(
          value: auth,
          child: PassResetRequestPage(),
        ));

      case "/pass_reset":
        return animateThis(BlocProvider.value(
          value: auth,
          child: PassResetPage(),
        ));

      case "/change_pass":
        return animateThis(BlocProvider.value(
          value: auth,
          child: ChangePassPage(),
        ));

      case "/create_ad":
        return animateThis(MultiBlocProvider(providers: [
          BlocProvider.value(value: operational),
          BlocProvider.value(value: auth)
        ], child: CreateAdPage()));

      case "/edit_ad":
        final AdData ad = settings.arguments as AdData;

        return animateThis(MultiBlocProvider(
          providers: [
            BlocProvider.value(value: operational),
            BlocProvider.value(value: auth)
          ],
          child: EditAdPage(ad: ad),
        ));

      case "/view":
        return animateThis(AdView(ad: settings.arguments as AdData));

      case "/my_request":
        return animateThis(FutureBuilder<bool>(
          future: auth.isLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            // فحص لو المستخدم مسجل دخول ومش في وضع الزائر
            final isGuest = operational.prefs.getBool("guest") ?? false;
            
            if (snapshot.hasData && snapshot.data == true && !isGuest) {
              return BlocProvider.value(
                value: authority,
                child: MyRequestPage(),
              );
            } else {
              return _buildLoginRequiredPage(context);
            }
          },
        ));

      case "/show_cat":
        final cat = settings.arguments as Category;

        return animateThis(MultiBlocProvider(
          providers: [
            BlocProvider.value(value: ad),
            BlocProvider.value(value: operational),
            BlocProvider.value(value: home)
          ],
          child: CategoryPage(category: cat),
        ));

      case "/chat":
        return animateThis(
          BlocProvider(
            create: (_) => sl<ChatCubit>(),
            child: const ChatPage(),
          ),
        );

      default:
        return animateThis(ErrorRoute());
    }
  }

  PageRouteBuilder<dynamic> animateThis(Widget x) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PopScope(
            canPop: false,
            onPopInvokedWithResult: (_, __) {
              return;
            },
            child: x),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const start = Offset(1, 0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          final tween = Tween(begin: start, end: end);
          final curvedAnim = CurvedAnimation(parent: animation, curve: curve);

          return SlideTransition(
              position: tween.animate(curvedAnim), child: child);
        });
  }

  static Widget _buildLoginRequiredPage(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2596FA), Color(0xFF364A62)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // أيقونة القفل
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // العنوان
                  const Text(
                    'تسجيل الدخول مطلوب',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // الرسالة
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'برجاء تسجيل الدخول أولاً\nحتى تتمكن من رؤية طلباتك',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // زر تسجيل الدخول
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2596FA),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.login, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // زر العودة
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'العودة للخلف',
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorRoute extends StatelessWidget {
  const ErrorRoute({super.key});

  @override
  Widget build(BuildContext context) {
    print("🔴🔴🔴 [ERROR ROUTE] ErrorRoute is being displayed!");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "خطأ",
          textDirection: TextDirection.rtl,
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              "خطأ",
              style: TextStyle(color: Colors.red),
            ),
            OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/login");
                },
                child: Text("العودة"))
          ],
        ),
      ),
    );
  }
}
