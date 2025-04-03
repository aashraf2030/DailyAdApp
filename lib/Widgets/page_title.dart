import 'package:ads_app/Bloc/Home/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class PageTitle extends StatefulWidget{

  @override
  PageTitleState createState() => PageTitleState();
}

class PageTitleState extends State<PageTitle>{
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(builder: getTitle);
  }

  Widget getTitle(context, state)
  {
    if (state is HomeLandingState)
      {
        return Center(child: Text("الصفحة الرئيسية",
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),));
      }
    else if (state is HomeSearchState) {
      return Center(child: Text("تصفح مخصص",
        style: GoogleFonts.cairo(
            color: Colors.white, fontWeight: FontWeight.bold),));
    }
    else if (state is HomeAdsState) {
      return Center(child: Text("اعلاناتي",
        style: GoogleFonts.cairo(
            color: Colors.white, fontWeight: FontWeight.bold),));
    }
    else if (state is HomeProfileState) {
      return Center(child: Text("الملف الشخصي",
        style: GoogleFonts.cairo(
            color: Colors.white, fontWeight: FontWeight.bold),));
    }
    else if (state is HomeAdRequestState) {
      return Center(child: Text("طلبات الاعلانات",
        style: GoogleFonts.cairo(
            color: Colors.white, fontWeight: FontWeight.bold),));
    }
    else if (state is HomeMoneyRequestState) {
      return Center(child: Text("طلبات الاموال",
        style: GoogleFonts.cairo(
            color: Colors.white, fontWeight: FontWeight.bold),));
    }
    else if (state is HomeAdminState) {
      return Center(child: Text("صفحة المسئولية",
        style: GoogleFonts.cairo(
            color: Colors.white, fontWeight: FontWeight.bold),));
    }
    else
      {
        return Center(child: Text("الصفحة الرئيسية",
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),));
      }
  }
}
