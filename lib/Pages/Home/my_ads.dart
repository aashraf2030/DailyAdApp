import 'package:ads_app/Bloc/Ad/ad_cubit.dart';
import 'package:ads_app/Models/ad_models.dart';
import 'package:ads_app/Widgets/ad_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAds extends StatefulWidget
{
  const MyAds({super.key});

  @override
  MyAdsState createState () => MyAdsState();
}

class MyAdsState extends State<MyAds>
{
  List<AdData> ads = [];

  @override
  void initState() {
    super.initState();

    BlocProvider.of<AdCubit>(context).getUserAds();
  }

  @override
  Widget build(BuildContext context) {
    return
        ConstrainedBox(constraints: BoxConstraints.expand(height: MediaQuery.sizeOf(context).height),
            child: Column(
            children: [
              Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 70,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(250, 250, 250, 1),
                      boxShadow: [BoxShadow(color: Colors.black, blurRadius: 1, blurStyle: BlurStyle.outer)],
                      border: Border.all(color: Colors.white, width: 1)
                  ),
                  child: Padding(padding: EdgeInsets.all(10),
                    child: OutlinedButton(onPressed: () { createAd(context);},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(44, 81, 151, 1),
                        ),
                        child: Text("إنشاء اعلان جديد", style: GoogleFonts.cairo(color: Colors.white,
                            fontSize: 14, fontWeight: FontWeight.bold
                        ),
                        )
                    ),
                  )
              ),

              Expanded(child: BlocBuilder<AdCubit, AdState>(builder: dataBuilder))
            ],
          ),

    );
  }

  Widget dataBuilder (context, state)
  {
    if (state is AdLoadingState)
      {
        return Center(child: CircularProgressIndicator(color: Colors.blueAccent,),);
      }
    else if (state is AdDoneState)
      {
        ads = state.data;
        if (ads.isNotEmpty)
          {
            return GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2)
              , itemBuilder: cardBuilder,
              padding: EdgeInsets.all(5),
              shrinkWrap: false,
              itemCount: ads.length,
            );
          }
        else{
          return Text("لا يوجد اعلانات", style: GoogleFonts.cairo(color: Colors.black),);
        }
      }
    else if (state is AdErrorState)
      {
        return Text("خطأ", style: GoogleFonts.cairo(color: Colors.red),);
      }
    else
      {
        return CircularProgressIndicator(color: Colors.blueAccent,);
      }
  }

  Widget cardBuilder (context, i)
  {
    return AdCard(ad: ads[i]);
  }

  void createAd(context)
  {
    Navigator.pushNamed(context, "/create_ad").then((x) {
      setState(() {
        BlocProvider.of<AdCubit>(context).getUserAds();
      });
    });
  }

}