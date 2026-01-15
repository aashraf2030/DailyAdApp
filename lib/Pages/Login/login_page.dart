import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Widgets/login_background.dart';
import 'package:ads_app/Widgets/login_textbox.dart';
import 'package:ads_app/Widgets/welcome_bonus_dialog.dart';



class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final user = LoginTextbox(padding: 10.0, icon: FontAwesomeIcons.user, hint: "اسم المستخدم....");
  final pass = LoginTextbox(padding: 10.0, icon: FontAwesomeIcons.lock, hint: "كلمة المرور....", isPassword: true);
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color.fromRGBO(233, 249, 255, 1),
        body: LoginBG(child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(height: 10),
                          
                          // Logo & Welcome Section
                          _buildHeader(),
                          
                          SizedBox(height: 20),
                          
                          // Login Card
                          _buildLoginCard(context),
                          
                          SizedBox(height: 15),
                          
                          // Guest Login Button
                          _buildGuestButton(context),
                          
                          SizedBox(height: 10),
                          
                          // Forgot Password
                          _buildForgotPassword(context),
                          
                          SizedBox(height: 15),
                          
                          // Register Button
                          _buildRegisterButton(context),
                          
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ))
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo Container with gradient and shadow
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(37, 150, 250, 1),
                Color.fromRGBO(54, 74, 98, 1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(37, 150, 250, 0.4),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Icon(
            FontAwesomeIcons.rectangleAd,
            size: 35,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: 16),
        
        // Welcome Text
        Text(
          "مرحباً بك",
          style: GoogleFonts.cairo(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 6),
        
        Text(
          "سجل الدخول للمتابعة",
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Title
            Text(
              "تسجيل الدخول",
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(54, 74, 98, 1),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Username Field
            user,
            
            SizedBox(height: 10),
            
            // Password Field
            pass,
            
            SizedBox(height: 12),
            
            // Remember Me Checkbox
            _buildRememberMeCheckbox(),
            
            SizedBox(height: 20),
            
            // Login Button
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(37, 150, 250, 1),
                    Color.fromRGBO(54, 74, 98, 1),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(37, 150, 250, 0.3),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () => tryLogin(context),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.rightToBracket, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "تسجيل الدخول",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _rememberMe = !_rememberMe;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "تذكرني",
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Color.fromRGBO(54, 74, 98, 1),
                    fontWeight: FontWeight.w500,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _rememberMe
                          ? Color.fromRGBO(37, 150, 250, 1)
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: _rememberMe
                        ? Color.fromRGBO(37, 150, 250, 1)
                        : Colors.transparent,
                  ),
                  child: _rememberMe
                      ? Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white.withOpacity(0.9),
        border: Border.all(
          color: Color.fromRGBO(37, 150, 250, 1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => enterGuest(context),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.userSecret, 
                  color: Color.fromRGBO(37, 150, 250, 1), 
                  size: 18
                ),
                SizedBox(width: 8),
                Text(
                  "دخول كزائر",
                  style: GoogleFonts.cairo(
                    color: Color.fromRGBO(37, 150, 250, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(37, 150, 250, 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.pushReplacementNamed(context, "/pass_reset_request");
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.unlockKeyhole,
                  size: 16,
                  color: Color.fromRGBO(54, 74, 98, 1),
                ),
                SizedBox(width: 10),
                Text(
                  "هل نسيت كلمة المرور؟",
                  style: GoogleFonts.cairo(
                    color: Color.fromRGBO(54, 74, 98, 1),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Color.fromRGBO(54, 74, 98, 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {
            Navigator.of(context).pushReplacementNamed("/register");
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.userPlus, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  "أنشئ حساب جديد",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void enterGuest(context)
  {
    final cubit = BlocProvider.of<AuthCubit>(context);

    cubit.enterGuestMode();
    Navigator.pushReplacementNamed(context, "/home");
  }

  void tryLogin(context) async {
  final cubit = BlocProvider.of<AuthCubit>(context);

  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Color.fromRGBO(37, 150, 250, 1),
          ),
        ),
      ),
    ),
  );

  final loginResult = await cubit.login(user.data, pass.data, rememberMe: _rememberMe);

  // Close loading
  Navigator.of(context).pop();

  // Check if login was successful
  if (loginResult['success'] == true) {
    // Check if user received welcome bonus
    if (loginResult['welcome_bonus'] == true && loginResult['bonus_points'] > 0) {
      // Show welcome bonus dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WelcomeBonusDialog(
          bonusPoints: loginResult['bonus_points'],
        ),
      );
    }

    final isVerified = await cubit.verifyCheck();

    if (isVerified) {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      Navigator.pushReplacementNamed(context, "/verify");
    }
  } else {
      // Check if account is unverified
      if (cubit.state is AuthError) {
        final errorState = cubit.state as AuthError;
        
        if (errorState.error == "Unverified") {
          // حساب غير مؤكد - توجيه لصفحة التحقق
          Navigator.pushReplacementNamed(context, "/verify");
          return;
        }
      }
      
      // Get error message from cubit state
      String errorMessage = "اسم المستخدم أو كلمة المرور غير صحيحة\nبرجاء المحاولة مرة أخرى";
      
      if (cubit.state is AuthError) {
        final errorState = cubit.state as AuthError;
        
        // Translate backend error messages to Arabic
        if (errorState.error == "Account has been deleted") {
          errorMessage = "هذا الحساب تم حذفه\nبرجاء التواصل مع الإدارة";
        } else if (errorState.error.isNotEmpty) {
          errorMessage = errorState.error;
        }
      }
      
      // Show modern error dialog
      showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Error Icon with animation
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.shade50,
                    ),
                    child: Icon(
                      FontAwesomeIcons.circleXmark,
                      size: 45,
                      color: Colors.red.shade400,
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Error Title
                  Text(
                    "خطأ في تسجيل الدخول",
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Error Message (Dynamic)
                  Text(
                    errorMessage,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Try Again Button
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(37, 150, 250, 1),
                          Color.fromRGBO(54, 74, 98, 1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(37, 150, 250, 0.3),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Center(
                          child: Text(
                            "محاولة مرة أخرى",
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}