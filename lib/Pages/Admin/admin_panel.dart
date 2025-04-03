import 'package:ads_app/Bloc/Authority/authority_cubit.dart';
import 'package:ads_app/Models/user_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';


class AdminPanel extends StatefulWidget{


  @override
  AdminPanelState createState() => AdminPanelState();
}


class AdminPanelState extends State<AdminPanel>{

  List<LeaderboardUser> users = [];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthorityCubit>(context).getLeaderboard().then((x) {
      setState(() {
        users = x;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthorityCubit, AuthorityState>(builder:
      createData,);
  }

  Widget createData(context, state)
  {
    if (state is AuthorityLoading)
      {
        return Center(child: CircularProgressIndicator(color: Colors.blueAccent,),);
      }
    else if (state is LeaderboardState)
      {
        users = state.users;
        if (users.isNotEmpty)
          {
            return ListView.builder(itemBuilder: listBuilder,
              itemCount: users.length, );
          }
        else
          {
            return Center(child: Text("لا يوجد اي مستخدمين بعد",
              style: GoogleFonts.cairo(color: Colors.black),));
          }
      }
    else
      {
        return Center(child: Text("حدث خطأ",
          style: GoogleFonts.cairo(color: Colors.red),));
      }
  }

  Widget listBuilder (context, i)
  {
    return Card(
      margin: EdgeInsets.all(5),
      color: Colors.grey.shade200,
      child: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: TextDirection.rtl,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text("الاسم : ${users[i].name}", textDirection: TextDirection.rtl,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(color: Colors.black),
              ),

              Text("عدد المشاهدات : ${users[i].views}", textDirection: TextDirection.rtl,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(color: Colors.black),
              )
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.rtl,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text("اسم المستخدم : ${users[i].username}", textDirection: TextDirection.rtl,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(color: Colors.black),
                ),

                Text("عدد النقاط : ${users[i].points}", textDirection: TextDirection.rtl,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(color: Colors.black),
                ),


              ]
            ),

            Text("البريد الالكتروني : ${users[i].email}", textDirection: TextDirection.rtl,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(color: Colors.black),
            ),


            Text("رقم الهاتف : ${users[i].phone}", textDirection: TextDirection.rtl,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(color: Colors.black),
            ),
          ],
        )
      ),
    );
  }
}