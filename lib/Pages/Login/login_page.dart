import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Widgets/login_background.dart';
import 'package:ads_app/Widgets/login_textbox.dart';



class LoginPage extends StatelessWidget{
  LoginPage({super.key});

  final user = LoginTextbox(padding: 10.0, icon: FontAwesomeIcons.user, hint: "اسم المستخدم....");
  final pass = LoginTextbox(padding: 10.0, icon: FontAwesomeIcons.lock, hint: "كلمة المرور....", isPassword: true,);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color.fromRGBO(233, 249, 255, 1),
        body: LoginBG(child: Center(
          child: Padding(padding: EdgeInsets.all(50),
            child: Stack(
              children: [
                  Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text("تسجيل الدخول", style: GoogleFonts.cairo(textStyle: TextStyle(color: Colors.white,
                        fontSize: 36))),

                    user,
                    pass,

                    Padding(
                        padding: EdgeInsets.all(20),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: OutlinedButton(
                            onPressed: () {
                              tryLogin(context);
                            },
                            style: OutlinedButton.styleFrom(
                                foregroundColor: Color.fromRGBO(70, 80, 150, 1),
                                backgroundColor: Color.fromRGBO(58, 63, 138, 1)
                            ),
                            child: Text("تسجيل الدخول",
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 16
                              ),
                            ),
                          ),
                        )
                    ),

                    Padding(padding: EdgeInsets.all(20),
                      child: TextButton(onPressed: () {
                        Navigator.pushReplacementNamed(context, "/pass_reset_request");
                      }, child: Text("هل نسيت كلمة المرور",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white
                          )
                        ),
                      ),
                    )
                  ],
                ),

                Positioned(bottom: 50, left: 20, right: 20,child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed("/register");
                      },
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Color.fromRGBO(80, 80, 80, 1),
                          backgroundColor: Color.fromRGBO(73, 69, 69, 1)
                      ),
                      child: Text("أنشئ حساب جديد",
                        style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  )
                )
              ]),
            ),
          )
        )
    );
  }

  void tryLogin(context) async
  {
    final cubit = BlocProvider.of<AuthCubit>(context);

    final loginResult = await cubit.login(user.data, pass.data);

    if (loginResult)
      {
        final isVerified = await cubit.verifyCheck();

        if (isVerified) {
          Navigator.pushReplacementNamed(context, "/home");
        }else{

          Navigator.pushReplacementNamed(context, "/verify");
        }
      }
    else
      {
        showDialog(context: context, builder: (_) {
          return AlertDialog(
            title: Text("خطأ في تسجيل الدخول"),
            icon: FaIcon(FontAwesomeIcons.bug),
            iconColor: Colors.red,
            actions: [
              OutlinedButton(onPressed: (){ Navigator.of(context).pop();},
                child: Text("محاولة مرة اخرى", style: GoogleFonts.cairo(color: Colors.white),),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.green[500],
                ),
              )
            ],

          );
        });
      }
  }
}