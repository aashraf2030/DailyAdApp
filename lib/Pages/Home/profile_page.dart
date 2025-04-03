import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:ads_app/Bloc/Authority/authority_cubit.dart';
import 'package:ads_app/Models/auth_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProfile extends StatefulWidget{

  const HomeProfile({super.key});

  @override
  ProfilePageState createState () => ProfilePageState();
}

class ProfilePageState extends State<HomeProfile> {

  UserProfile profile = UserProfile();

  @override
  void initState() {
    super.initState();

    BlocProvider.of<AuthCubit>(context).getProfile().then((x) {
      setState(() {
        profile = x;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {

      if (state is AuthDone)
        {
          return basePage(context);
        }
      else if (state is AuthError)
        {
          return Text(state.error, style: GoogleFonts.cairo(color: Colors.red),);
        }
      else{
        return CircularProgressIndicator(color: Colors.blueAccent,);
      }

    },);
  }

  Widget basePage(context)
  {
    return ListView(
      children: [

        Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 1, color: Colors.grey.shade700)),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.person),
              SizedBox(width: 200, child: Text("${profile.name}",
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(color: Colors.black, fontSize: 14)
                ,),)
            ],
          ),
        ),

        Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 1, color: Colors.grey.shade700)),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.account_circle),
              SizedBox(width: 200, child: Text("${profile.username}",
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(color: Colors.black, fontSize: 14)
                ,),)
            ],
          ),
        ),

        Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 1, color: Colors.grey.shade700)),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.email),
              SizedBox(width: 200, child: Text("${profile.email}",
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(color: Colors.black, fontSize: 14)
                ,),)
            ],
          ),
        ),

        Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 1, color: Colors.grey.shade700)),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.phone_android),
              SizedBox(width: 200, child: Text("${profile.phone}",
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(color: Colors.black, fontSize: 14)
                ,),)
            ],
          ),
        ),

        Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 1, color: Colors.grey.shade700)),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.date_range),
              SizedBox(width: 200, child: Text("${profile.join}",
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(color: Colors.black, fontSize: 14)
                ,),)
            ],
          ),
        ),

        Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 1, color: Colors.grey.shade700)),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.score_rounded),
              SizedBox(width: 200, child: Text("${profile.points}",
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(color: Colors.black, fontSize: 14)
                ,),)
            ],
          ),
        ),
        OutlinedButton(onPressed: (){exchangePoints(context);},
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
            ),
            child: Text("تبديل النقاط",
              style: GoogleFonts.cairo(color: Colors.black, fontSize: 14),)),

        OutlinedButton(onPressed: (){Navigator.pushNamed(context, "/my_request");},
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
            ),
            child: Text("طلباتي",
              style: GoogleFonts.cairo(color: Colors.black, fontSize: 14),)),

        OutlinedButton(onPressed: (){logout(context);},
            style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                backgroundColor: Colors.red[800]
            ),
            child: Text("تسجيل الخروج",
              style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),)),
      ],
    );
  }

  void exchangePoints (context) async
  {
    final cubit = BlocProvider.of<AuthorityCubit>(context);

    final res = await cubit.exchangePoints();


    if (res)
      {
        BlocProvider.of<AuthCubit>(context).getProfile().then((x){

          setState(() {
            profile = x;
          });

        });
      }
    else
    {
      showError(context);
    }
  }

  void showError(context)
  {
    showDialog(context: context, builder: (context) {

      return AlertDialog(
        backgroundColor: Colors.white,
        title: Center(child: Text("خطأ",
          style: GoogleFonts.cairo(color: Colors.red),)),
        content: Text("يجب ان يتوفر حسابك علي 1000 نقطة علي الاقل",
          style: GoogleFonts.cairo(color: Colors.black),),

        actions: [
          OutlinedButton(onPressed: (){Navigator.pop(context);},
              child: Text("خروج", style: GoogleFonts.cairo(color: Colors.black),))
        ],
      );

    });
  }

  void logout (context) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AuthCubit(AuthInitial(), prefs).logout().then((x) {
      Navigator.pushReplacementNamed(context, "/login");
    } );
  }

}
