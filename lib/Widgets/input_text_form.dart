import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputTextForm extends StatelessWidget{

  InputTextForm(this.hint, this.icon, {super.key, this.initialVal = ""})
  {
    out = initialVal;
  }

  final String hint;
  final IconData icon;
  final String initialVal;
  late String out;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialVal,
      textDirection: TextDirection.rtl,
      style: GoogleFonts.cairo(color: Colors.blueAccent),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        prefixIcon: Icon(icon),
      ),
      onChanged: (x) {out = x;},
    );
  }
}
