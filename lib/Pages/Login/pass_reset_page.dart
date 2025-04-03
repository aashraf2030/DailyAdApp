import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Widgets/login_background.dart';
import 'package:ads_app/Widgets/login_textbox.dart';


class PassResetPage extends StatelessWidget{
  PassResetPage({super.key});

  final code = LoginTextbox(padding: 20.0, icon: FontAwesomeIcons.hashtag, hint: "كود البريد الالكتورني...");


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
                      Text("تغيير كلمة المرور", style: GoogleFonts.cairo(textStyle: TextStyle(color: Colors.white,
                          fontSize: 30))),

                      code,

                      Padding(
                          padding: EdgeInsets.all(20),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: OutlinedButton(
                              onPressed: () {
                                changePassRequest(context);
                              },
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Color.fromRGBO(70, 80, 150, 1),
                                  backgroundColor: Color.fromRGBO(58, 63, 138, 1)
                              ),
                              child: Text("تاكيد",
                                style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 16
                                ),
                              ),
                            ),
                          )
                      ),

                      Padding(padding: EdgeInsets.all(20),
                        child: TextButton(onPressed: () { resendCode(context);}
                          , child: Text("اعادة الارسال",
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

  void changePassRequest(context) async
  {
    final cubit = BlocProvider.of<AuthCubit>(context);

    final res = await cubit.validateResetPass(code.data);

    if (res)
    {
      Navigator.pushReplacementNamed(context, "/change_pass");
    }
    else
    {
      showDialog(context: context, builder: (_) {
        return AlertDialog(
          title: Text("هذا الكود خاطئ"),
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

  void resendCode(context) async
  {
    final cubit = BlocProvider.of<AuthCubit>(context);

    final res = await cubit.sendCode(passReset: true);

    String message;

    if (res)
    {
      message = "تم ارسال الكود";
    }
    else
    {
      message = "حدث خطأ";
    }

    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text(message),
        icon: FaIcon(FontAwesomeIcons.bug),
        iconColor: Colors.red,
        actions: [
          OutlinedButton(onPressed: (){ Navigator.of(context).pop();},
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.green[500],
            ),
            child: Text(res ? "تم" :"محاولة مرة اخرى",
              style: GoogleFonts.cairo(color: Colors.white),),
          )
        ],

      );
    });
  }
}