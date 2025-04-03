import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Widgets/login_background.dart';
import 'package:ads_app/Widgets/login_textbox.dart';


class PassResetRequestPage extends StatelessWidget{
  PassResetRequestPage({super.key});

  final email = LoginTextbox(padding: 20.0, icon: FontAwesomeIcons.at, hint: "البريد الالكتورني...");


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

                      email,

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
                              child: Text("طلب تغيير",
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

  void changePassRequest(context) async
  {
    final cubit = BlocProvider.of<AuthCubit>(context);

    final res = await cubit.resetPass(email.data);

    print(res);

    if (res)
    {
      Navigator.pushReplacementNamed(context, "/pass_reset");
    }
    else
    {
      showDialog(context: context, builder: (_) {
        return AlertDialog(
          title: Text("هذا المستخدم غير موجود"),
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