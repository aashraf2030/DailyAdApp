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
      case "/":
        print("🟢 [ROUTER] / (root) route - redirecting to home");
        
        home.changeRoute(0);
        return generateRoute(RouteSettings(name: "/home"));
        
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
        if (auth.isGuestMode()) {
          return animateThis(
            _buildLoginRequiredPage(
              message: "لإنشاء إعلان جديد، يرجى تسجيل الدخول أولاً.",
            ),
          );
        }
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
            
            
            final isGuest = operational.prefs.getBool("guest") ?? false;
            
            if (snapshot.hasData && snapshot.data == true && !isGuest) {
              return BlocProvider.value(
                value: authority,
                child: MyRequestPage(),
              );
            } else {
              return _buildLoginRequiredPage();
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
        print("🔴 [ROUTER] Unknown route requested: ${settings.name}");
        return animateThis(ErrorRoute(
          errorMessage: "الصفحة المطلوبة غير موجودة",
          error: "Route not found: ${settings.name}",
        ));
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

  static Widget _buildLoginRequiredPage({String? message}) {
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
                    child: Text(
                      message ?? 'برجاء تسجيل الدخول أولاً\nحتى تتمكن من رؤية طلباتك',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  
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
                  
                  
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'العودة للرئيسية',
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
  final String? errorMessage;
  final Object? error;
  final StackTrace? stackTrace;
  
  const ErrorRoute({
    super.key, 
    this.errorMessage,
    this.error,
    this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    print("🔴🔴🔴 [ERROR ROUTE] ErrorRoute is being displayed!");
    print("Error: $error");
    print("Message: $errorMessage");
    print("Stack: $stackTrace");
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "خطأ",
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              "حدث خطأ",
              style: TextStyle(
                color: Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            
            
            if (errorMessage != null) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "رسالة الخطأ:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
            
            
            if (error != null) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "تفاصيل الخطأ:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
            
            
            if (stackTrace != null) ...[
              ExpansionTile(
                title: Text("Stack Trace (للمطورين)"),
                backgroundColor: Colors.grey.shade100,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    color: Colors.black87,
                    child: Text(
                      stackTrace.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
            
            
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
              },
              icon: Icon(Icons.home),
              label: Text("العودة للرئيسية"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, "/login");
              },
              icon: Icon(Icons.login),
              label: Text("تسجيل الدخول"),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
