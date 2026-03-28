import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Widgets/login_background.dart';
import 'package:ads_app/Widgets/login_textbox.dart';



class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final name = LoginTextbox(padding: 5.0, icon: FontAwesomeIcons.user, hint: "الإسم بالكامل....");
  final user = LoginTextbox(padding: 5.0, icon: FontAwesomeIcons.user, hint: "اسم المستخدم....");
  final email = LoginTextbox(padding: 5.0, icon: FontAwesomeIcons.at, hint: "البريد الإلكتروني....");
  final phone = LoginTextbox(padding: 5.0, icon: FontAwesomeIcons.phone, hint: "رقم الهاتف (إختياري)....");
  final pass = LoginTextbox(padding: 5.0, icon: FontAwesomeIcons.lock, hint: "كلمة المرور....", isPassword: true);
  final passConfirm = LoginTextbox(padding: 5.0, icon: FontAwesomeIcons.lock, hint: "تأكيد كلمة المرور....", isPassword: true);

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
                          
                          
                          _buildHeader(),
                          
                          SizedBox(height: 15),
                          
                          
                          _buildRegistrationCard(context),
                          
                          SizedBox(height: 15),
                          
                          
                          _buildLoginButton(context),
                          
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
        
        Container(
          width: 60,
          height: 60,
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
            FontAwesomeIcons.userPlus,
            size: 28,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: 12),
        
        Text(
          "إنشاء حساب جديد",
          style: GoogleFonts.cairo(
            fontSize: 24,
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
      ],
    );
  }

  Widget _buildRegistrationCard(BuildContext context) {
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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            
            Text(
              "تسجيل",
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(54, 74, 98, 1),
              ),
            ),
            
            SizedBox(height: 15),
            
            
            name,
            user,
            email,
            phone,
            pass,
            passConfirm,
            
            SizedBox(height: 15),
            
            
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
                  onTap: () => tryRegister(context),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.userPlus, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "تسجيل",
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

  Widget _buildLoginButton(BuildContext context) {
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
            Navigator.pushReplacementNamed(context, "/login");
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.rightToBracket, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  "لديك حساب بالفعل",
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

  void tryRegister(context) async {
    
    if (user.data.isEmpty || pass.data.isEmpty ||
        passConfirm.data.isEmpty || name.data.isEmpty ||
        email.data.isEmpty) {
      showError(context, "البيانات المطلوبة غير مكتملة");
      return;
    }

    if (pass.data != passConfirm.data) {
      showError(context, "كلمات المرور غير متطابقة");
      return;
    }

    
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

    final cubit = BlocProvider.of<AuthCubit>(context);
    final phoneData = phone.data.isEmpty ? null : phone.data;

    final x = await cubit.register(
      name.data,
      user.data,
      pass.data,
      email.data,
      phoneData,
    );

    
    Navigator.of(context).pop();

    if (x) {
      
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
                  colors: [Colors.white, Colors.green.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.shade50,
                    ),
                    child: Icon(
                      FontAwesomeIcons.circleCheck,
                      size: 45,
                      color: Colors.green.shade400,
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  Text(
                    "تم التسجيل بنجاح!",
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 12),
                  
                  Text(
                    "تم إرسال رمز التحقق إلى بريدك الإلكتروني",
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  
                  SizedBox(height: 30),
                  
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade400,
                          Colors.green.shade600,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade300,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child:                       InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacementNamed(context, "/verify");
                        },
                        child: Center(
                          child: Text(
                            "التحقق من البريد الإلكتروني",
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
    } else {
      showError(context, "هذا المستخدم موجود بالفعل");
    }
  }
  
  void showError(context, String errorMessage) {
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
                
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.shade50,
                  ),
                  child: Icon(
                    FontAwesomeIcons.triangleExclamation,
                    size: 45,
                    color: Colors.red.shade400,
                  ),
                ),
                
                SizedBox(height: 20),
                
                
                Text(
                  "خطأ في التسجيل",
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 12),
                
                
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
                          "حسناً",
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