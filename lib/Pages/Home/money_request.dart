import 'package:ads_app/Bloc/Authority/authority_cubit.dart';
import 'package:ads_app/Models/authority_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class MoneyRequestPage extends StatefulWidget{

  const MoneyRequestPage({super.key});

  @override
  MoneyRequestPageState createState () => MoneyRequestPageState();
}

class MoneyRequestPageState extends State<MoneyRequestPage>{

  List<UserRequest> requests = [];

  @override
  void initState() {
    super.initState();

    BlocProvider.of<AuthorityCubit>(context).getMoneyRequest();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthorityCubit, AuthorityState>(builder: pageBuilder);
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
      else{
        return Center(child: Text("لا يوجد اي طلبات", style: GoogleFonts.cairo(color: Colors.black),),);
      }
    }
    else
    {
      BlocProvider.of<AuthorityCubit>(context).getMoneyRequest();
      return Center(child: Text("خطأ", style: GoogleFonts.cairo(color: Colors.red),),);
    }
  }

  Widget itemBuilder (context, int i)
  {
    final myRequest = requests[i] as MoneyRequest;
    return Card(color: Colors.grey.shade200,margin:
    EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Text(myRequest.username, style: GoogleFonts.cairo(color: Colors.black,
                    fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis,),
                Spacer(),
                Text(myRequest.userPhone, style: GoogleFonts.cairo(color: Colors.black,
                    fontSize: 14), overflow: TextOverflow.ellipsis,),
              ],
            ),
            Row(
              children: [
                Text("المبلغ المستحق : ${myRequest.money}"),
                Spacer(),
                Text("المشاهدات : ${myRequest.views}"),
              ],
            ),
            Row(
              children: [
                Text("تاريخ الانضمام : ${myRequest.join}",
                  textDirection: TextDirection.rtl,),
                Spacer(),
                IconButton(onPressed: () async {
                  await BlocProvider.of<AuthorityCubit>(context).handleRequest(myRequest.id, true);
                }, icon: Icon(Icons.check_circle,),
                  disabledColor: Colors.grey.shade300, color: Colors.green,)
              ],
            ),
          ],
        ),
      ),
    );
  }
}