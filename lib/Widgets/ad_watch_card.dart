import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Models/ad_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
class AdWatchCard extends StatefulWidget
{
  AdWatchCard({super.key, required this.ad});

  AdData ad;

  @override
  WatchCardState createState () => WatchCardState();
}

class WatchCardState extends State<AdWatchCard>{

  int views = 0;

  @override @override
  void initState() {
    super.initState();
    views = widget.ad.views;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { show(context); },
      child: SizedBox(
        width: 200,
        child: Card(
          margin: EdgeInsets.all(10),
          color: Colors.grey[200],
          child: Padding(padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 100,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10))),
                  child:
                  FadeInImage.assetNetwork(placeholder: "assets/imgs/Loading.gif",
                    image: widget.ad.image, fit: BoxFit.cover,),
                ),

                Padding(padding: EdgeInsets.only(right: 20, left: 20, top: 5),
                    child:SizedBox(
                      width: 90,
                      child: Text(widget.ad.name, style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                          fontSize: 16
                      ),
                        textDirection: TextDirection.rtl,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    )
                ),

                Text("عدد المشاهدات : $views", style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ), textDirection: TextDirection.rtl,)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void show(context)
  {
    final cubit = BlocProvider.of<OperationalCubit>(context);

    Navigator.pushNamed(context, "/view", arguments: widget.ad).then((x) async {

      final res = await cubit.watchAd(widget.ad.id);

      if (!res)
      {
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Text("خطأ", style: GoogleFonts.cairo(color: Colors.red),),
            content: Text("خطأ في ارسال النقاط", style: GoogleFonts.cairo(color: Colors.blueAccent),),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.grey.shade200,
            actions: [
              TextButton(onPressed: (){ Navigator.pop(context); }, child: Text("حاول مرة اخرى"))
            ],
          );
        });
      }
      else
      {
        setState(() {
          views++;
        });
      }

    });
  }
}