import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Models/category_model.dart';


class CategoryButton extends StatelessWidget {

  CategoryButton(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: () {clicked(context);},
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
        ),
        child: Text(categories[id].name, style: GoogleFonts.cairo(fontSize: 14, color: Colors.black),)
    );
  }

  void clicked (context)
  {
    Navigator.pushNamed(context, "/show_cat", arguments: categories[id]);
  }
}