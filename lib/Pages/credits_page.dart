import 'package:flutter/material.dart';
import 'package:ads_app/Widgets/gradient_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class CreditsPage extends StatelessWidget
{
  CreditsPage ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        automaticallyImplyLeading: false,
        title: Container(alignment: Alignment.center,
          child: Text("حول التطبيق", style: GoogleFonts.cairo(
            color: Colors.white, fontWeight: FontWeight.bold,
          ), textAlign: TextAlign.center,
          ),
        ),
        gradient: LinearGradient(colors: [Color.fromRGBO(37, 150, 250, 1),
          Color.fromRGBO(54, 74, 98, 0.85)], transform: GradientRotation(0.5)),
      ),

      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(30),
        margin: EdgeInsets.fromLTRB(20,
            MediaQuery.of(context).size.height * 0.2, 20,
            MediaQuery.of(context).size.height * 0.2),
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          border: Border.all(color: Colors.blueGrey.shade300, width: 5,),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.blueGrey,
              offset: Offset(5, 3), blurRadius: 20, spreadRadius: 3)]
        ),
        child: Expanded(child: Column(
          textDirection: TextDirection.rtl,
          spacing: 30,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.rtl,
              children: [
                Text("ايميل الشركة : ", style: GoogleFonts.cairo(
                  fontSize: 15, fontWeight: FontWeight.bold,
        
                ),
                  textDirection: TextDirection.rtl,
                ),
        
                Text("info@dailyad-sa.com", style: GoogleFonts.cairo(
                  fontSize: 15,
        
                ),
                  textDirection: TextDirection.rtl,
                )
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.rtl,
              children: [
                Text("سعر الخدمة : ", style: GoogleFonts.cairo(
                  fontSize: 15, fontWeight: FontWeight.bold,

                ),
                  textDirection: TextDirection.rtl,
                ),

                Text("50 ريال لكل 1000 مشاهدة", style: GoogleFonts.cairo(
                  fontSize: 15,

                ),
                  textDirection: TextDirection.rtl,
                )
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              textDirection: TextDirection.rtl,
              children: [
                Flexible(child: Text("تطبيق تصفح للاعلانات هدفه توصيل المعلن بالمستهلك عن طريق العرض والمشاهدة. \nيقوم المعلن بعرض الاعلان الخاص به والدفع للمنصة.\nويقوم المستهلك بتصفح الاعلانات من اجل جمع النقاط والتي يمكن تبديلها بالمال.", style: GoogleFonts.cairo(
                  fontSize: 15, fontWeight: FontWeight.bold,
                ),
                  softWrap: true,
                  textDirection: TextDirection.rtl,

                ),
                )
              ],
            )
        
          ],
        )),
      ),
    );
  }
}