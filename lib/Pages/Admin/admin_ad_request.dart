import 'package:ads_app/Bloc/Authority/authority_cubit.dart';
import 'package:ads_app/Models/authority_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminAdRequestPage extends StatefulWidget{
  const AdminAdRequestPage({super.key});


  @override
  AdminAdRequestPageState createState() => AdminAdRequestPageState();
}

class AdminAdRequestPageState extends State<AdminAdRequestPage>{

  List<UserRequest> requests = [];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthorityCubit>(context).getUserRequests(null).then((x){
      setState(() {
        requests = x;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthorityCubit, AuthorityState>(builder: buildRequests);
  }

  Widget buildRequests(context, state)
  {
    if (state is AuthorityRequestDone)
      {
        requests = state.data;
        if (requests.isNotEmpty)
          {
            return GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: (MediaQuery.sizeOf(context).width / 300).round(),)
              , itemBuilder: requestBuilder, itemCount: requests.length,);
          }
        else{
          return Center(child: Text("لا يوجد اي طلبات", style: GoogleFonts.cairo(color: Colors.black),),);
        }
      }
    else if (state is AuthorityLoading)
      {
        return Center(child: SizedBox(width: 60, height: 60,
            child: CircularProgressIndicator(color: Colors.blueAccent),),);
      }
    else
      {
        return Center(child: Text("خطأ", style: GoogleFonts.cairo(color: Colors.red),),);
      }
  }

  Widget requestBuilder (context, int i)
  {
    final req = requests[i];

    if (req is DefaultRequest)
      {
        return Container(
          margin: EdgeInsets.all(3),
          decoration: BoxDecoration(border: Border.all(color: Colors.orange)),
          child: GridTile(header: Container(
              height: 40,
              decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20, 0.5)),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    SizedBox(
                      width: 30, height: 30,
                        child: FaIcon(req.category.icon, color: Colors.white)
                    ),

                    Text(req.adName,
                    textDirection: TextDirection.rtl, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center
                    ),
                  ],
                ),
              ),
            ),
            footer: Container(
              decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20, 0.5)),
              child: Column(
                textDirection: TextDirection.rtl,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      SizedBox(
                        width: 280,
                        child: Text("المستخدم : ${req.username}",
                          style: GoogleFonts.cairo(color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      SizedBox(
                        width: 280,
                        child: Text("فئة الاعلان : ${req.tier}",
                          style: GoogleFonts.cairo(color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      SizedBox(
                        width: 280,
                        child: Text("عدد المشاهدات المطلوب : ${req.target}",
                          style: GoogleFonts.cairo(color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,),
                      ),
                    ],
                  ),

                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      OutlinedButton(onPressed: () {acceptButton(req);}, style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        shape: CircleBorder(), padding: EdgeInsets.all(10)
                      ),
                          child: Icon(FontAwesomeIcons.check, color: Colors.white,)),

                      OutlinedButton(onPressed: () {rejectButton(req);}, style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: CircleBorder(), padding: EdgeInsets.all(10)
                      ),
                          child: Icon(FontAwesomeIcons.x, color: Colors.white,)),

                    ],
                  )
                ],
              ),
            ),child: FadeInImage.assetNetwork(placeholder: 'assets/imgs/LoadingImage.gif', image: req.image, fit: BoxFit.cover),
          ),
        );
      }
    else if (req is RenewRequest)
      {
        return Container(
          margin: EdgeInsets.all(3),
          decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
          child: GridTile(header: Container(
            height: 40,
            decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20, 0.5)),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  SizedBox(
                      width: 30, height: 30,
                      child: FaIcon(req.category.icon, color: Colors.white)
                  ),

                  Text(req.adName,
                      textDirection: TextDirection.rtl, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center
                  ),
                ],
              ),
            ),
          ),
            footer: Container(
              decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20, 0.5)),
              child: Column(
                textDirection: TextDirection.rtl,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      SizedBox(
                        width: 280,
                        child: Text("المستخدم : ${req.username}",
                          style: GoogleFonts.cairo(color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      SizedBox(
                        width: 280,
                        child: Text("رقم الهاتف : ${req.userPhone}",
                          style: GoogleFonts.cairo(color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      SizedBox(
                        width: 280,
                        child: Text("فئة الاعلان : ${req.tier}",
                          style: GoogleFonts.cairo(color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      SizedBox(
                        width: 280,
                        child: Text("عدد المشاهدات : ${req.views}/${req.target}",
                          style: GoogleFonts.cairo(color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      SizedBox(
                        width: 280,
                        child: Text("تاريخ انشاء الاعلان : ${req.creation}",
                          style: GoogleFonts.cairo(color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      SizedBox(
                        width: 280,
                        child: Text("تاريخ اخر تعديل : ${req.lastUpdate}",
                          style: GoogleFonts.cairo(color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,),
                      ),
                    ],
                  ),

                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      OutlinedButton(onPressed: () {acceptButton(req);}, style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.lightGreen,
                          shape: CircleBorder(), padding: EdgeInsets.all(10)
                      ),
                          child: Icon(FontAwesomeIcons.check, color: Colors.white,)),

                      OutlinedButton(onPressed: () {rejectButton(req);}, style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: CircleBorder(), padding: EdgeInsets.all(10)
                      ),
                          child: Icon(FontAwesomeIcons.x, color: Colors.white,)),

                    ],
                  )
                ],
              ),
            ),child: FadeInImage.assetNetwork(placeholder: 'assets/imgs/LoadingImage.gif', image: req.image, fit: BoxFit.cover,),
          ),
        );
      }
    else{
      return Text("");
    }
  }

  void acceptButton (req)
  {
    showDialog(context: context, builder: (_) {

      return AlertDialog(

        title: Center(child: Text("تاكيد", style: GoogleFonts.cairo(),)),
        content: Center(heightFactor: 0, child: Text("هل تود تاكيد نشر الاعلان ؟", style: GoogleFonts.cairo(),)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,

        actions: [
          OutlinedButton(onPressed: () {Navigator.pop(context);},
            style: OutlinedButton.styleFrom(backgroundColor: Colors.red), child: Text("إلغاء",
            style: GoogleFonts.cairo(color: Colors.white),),),

          OutlinedButton(onPressed: () {handleReq(req, true);},
            style: OutlinedButton.styleFrom(backgroundColor: Colors.green), child: Text("حفظ",
              style: GoogleFonts.cairo(color: Colors.white)),)
        ],

      );

    });
  }

  void rejectButton (req)
  {
    showDialog(context: context, builder: (_) {

      return AlertDialog(

        title: Center(child: Text("تاكيد", style: GoogleFonts.cairo(),)),
        content: Center(heightFactor: 0, child: Text("هل تود تاكيد حذف الاعلان ؟", style: GoogleFonts.cairo(),)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,

        actions: [
          OutlinedButton(onPressed: () {Navigator.pop(context);},
            style: OutlinedButton.styleFrom(backgroundColor: Colors.red), child: Text("إلغاء",
              style: GoogleFonts.cairo(color: Colors.white),),),

          OutlinedButton(onPressed: () {handleReq(req, false);},
            style: OutlinedButton.styleFrom(backgroundColor: Colors.green), child: Text("حفظ",
                style: GoogleFonts.cairo(color: Colors.white)),)
        ],

      );

    });
  }

  void handleReq(req, bool accept) async
  {
    final cubit = BlocProvider.of<AuthorityCubit>(context);

    if (req is DefaultRequest)
      {
        await cubit.handleRequest(req.id, accept);
      }
    else if (req is RenewRequest)
      {
        await cubit.handleRequest(req.id, accept);
      }

    Navigator.pop(context);
    cubit.getUserRequests(null);
  }
}