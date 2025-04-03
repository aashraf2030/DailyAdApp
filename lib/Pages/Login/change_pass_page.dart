import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Widgets/login_background.dart';
import 'package:ads_app/Widgets/login_textbox.dart';


class ChangePassPage extends StatelessWidget{
  ChangePassPage({super.key});

  final pass = LoginTextbox(padding: 20.0, icon: FontAwesomeIcons.lock, hint: "كلمة المرور...", isPassword: true,);
  final passConfirm = LoginTextbox(padding: 20.0, icon: FontAwesomeIcons.lock, hint: "تاكيد كلمة المرور...", isPassword: true,);


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
                      Text("كلمة مرور جديدة", style: GoogleFonts.cairo(textStyle: TextStyle(color: Colors.white,
                          fontSize: 30))),

                      pass,
                      passConfirm,

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
                              child: Text("تغيير",
                                style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 16
                                ),
                              ),
                            ),
                          )
                      ),
                    ],
                  ),

                  Positioned(bottom: 50, left: 20, right: 20,child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed("/login");
                      },
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Color.fromRGBO(80, 80, 80, 1),
                          backgroundColor: Color.fromRGBO(73, 69, 69, 1)
                      ),
                      child: Text("العودة",
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
    if (pass.data.isEmpty ||
        passConfirm.data.isEmpty)
    {
      showError(context, "البيانات المطلوبة غير مكتملة");
      return;
    }

    if (pass.data != passConfirm.data)
    {
      showError(context, "كلمات المرور غير متطابقة");
      return;
    }
    final cubit = BlocProvider.of<AuthCubit>(context);

    final res = await cubit.changePass(pass.data);

    if (res)
    {
      Navigator.pushReplacementNamed(context, "/login");
    }
    else
    {
      showError(context, "حدث خطأ");
    }
  }

  void showError(context, String errorMessage)
  {
    showDialog(context: context, builder: (_)
    {
      return AlertDialog(
        title: Text("خطأ في التغيير"),
        icon: FaIcon(FontAwesomeIcons.bug),
        iconColor: Colors.red,
        content: Text(
          errorMessage, style: GoogleFonts.cairo(color: Colors.red),),
        actions: [
          OutlinedButton(onPressed: () {
            Navigator.of(context).pop();
          },
            child: Text("محاولة مرة اخرى",
              style: GoogleFonts.cairo(color: Colors.white),),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.green[500],
            ),
          )
        ],

      );
    });
  }
}