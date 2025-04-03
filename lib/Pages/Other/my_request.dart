import 'package:ads_app/Bloc/Authority/authority_cubit.dart';
import 'package:ads_app/Models/authority_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class MyRequestPage extends StatefulWidget{

  const MyRequestPage({super.key});

  @override
  MyRequestPageState createState () => MyRequestPageState();
}

class MyRequestPageState extends State<MyRequestPage>{

  List<UserRequest> requests = [];

  @override
  void initState() {
    super.initState();

    BlocProvider.of<AuthorityCubit>(context).getMyRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        automaticallyImplyLeading: false,
        title: Text("طلباتي", style: GoogleFonts.cairo(color: Colors.white,
            fontWeight: FontWeight.bold),
          textAlign: TextAlign.center, textDirection: TextDirection.rtl,
        ),
        gradient: LinearGradient(colors: [Color.fromRGBO(37, 150, 250, 1),
          Color.fromRGBO(54, 74, 98, 0.85)], transform: GradientRotation(0.5)),
      actions: [
          IconButton(onPressed: (){Navigator.pop(context);},
              icon: Icon(Icons.arrow_forward))
        ]
      ),
      backgroundColor: Colors.white,
      body: BlocBuilder<AuthorityCubit, AuthorityState>(builder: pageBuilder),
    );
  }

  Widget pageBuilder (context, state)
  {
    if (state is AuthorityLoading)
      {
        return Center(child: CircularProgressIndicator(color: Colors.blueAccent,),);
      }
    else if (state is AuthorityRequestDone)
      {
        requests = state.data;
        if (requests.isNotEmpty)
          {
            return ListView.builder(itemBuilder: itemBuilder,
              itemCount: requests.length, padding: EdgeInsets.only(top: 5, bottom: 5),
            );
          }
        else
          {
            return Center(child: Text("لا يوجد طلبات", style: GoogleFonts.cairo(color: Colors.black),),);
          }
      }
    else
      {
        BlocProvider.of<AuthorityCubit>(context).getMyRequest();
        return Center(child: Text("خطأ", style: GoogleFonts.cairo(color: Colors.red),),);
      }
  }

  IconData getIcon (str){
    switch (str){
      case "Create":
        return FontAwesomeIcons.circlePlus;

      case "Renew":
        return Icons.rotate_right;

      case "Money":
        return FontAwesomeIcons.moneyBill;

      default:
        return Icons.error;
    }
  }

  Widget itemBuilder (context, int i)
  {
    final myRequest = requests[i] as MyRequest;
    return Card(color: Colors.grey.shade200,margin:
       EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(getIcon(myRequest.type), color: Colors.grey.shade400,),
            Spacer(),
            Text(myRequest.adName, style: GoogleFonts.cairo(color: Colors.black,
                fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis,),
            Spacer(),
            Text(myRequest.creation),
            Spacer(),
            IconButton(onPressed: myRequest.type != "Money" ? () async {
              await BlocProvider.of<AuthorityCubit>(context).deleteRequest(myRequest.id);
            } : null, icon: Icon(Icons.remove_circle,),
              disabledColor: Colors.grey.shade300, color: Colors.red,)
          ],
        ),
      ),
    );
  }
}