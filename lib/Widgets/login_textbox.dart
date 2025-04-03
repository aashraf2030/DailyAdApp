import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginTextbox extends StatefulWidget{
  LoginTextbox({super.key, required this.padding, required this.icon, required this.hint, this.isPassword = false});
  final double padding;
  final IconData icon;
  final String hint;
  final bool isPassword;

  String data = "";

  @override
  TextboxState createState () => TextboxState();
}

class TextboxState extends State<LoginTextbox> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widget.padding),
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromRGBO(102, 134, 180, 1),
                width: 3,
                strokeAlign: BorderSide.strokeAlignOutside
              ),
              borderRadius: BorderRadius.circular(50),
              color: Colors.white
            ),

            child: Stack(
                children: [
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(177, 178, 181, 0.4),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(50),
                        bottomRight: Radius.circular(50))
                  ),
                ),
              ),

            Positioned(
                  top: 5,
                  right: 20,
                  child: FaIcon(widget.icon,
                    size: 30,
                    color: Color.fromRGBO(77, 98, 160, 0.86),
                  )),

                  Positioned(
                      left: 15,
                      right: 70,
                      child: TextField(
                        textDirection: TextDirection.rtl,
                        enableSuggestions: false,
                        autocorrect: false,
                        obscureText: widget.isPassword,
                        decoration: InputDecoration(
                          hintText: widget.hint,
                          border: InputBorder.none,
                          hintTextDirection: TextDirection.rtl,
                          hintStyle: GoogleFonts.cairo(textStyle: TextStyle(color: Color.fromRGBO(10, 10, 10, 0.3)))
                        ),
                        onChanged: (str) {widget.data = str;},
                      ))
            ]),
          ),
        ],
      ),
    );
  }
}