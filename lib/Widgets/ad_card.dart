import 'package:ads_app/Bloc/Ad/ad_cubit.dart';
import 'package:ads_app/Models/ad_models.dart';
import 'package:ads_app/utils/tier_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AdCard extends StatelessWidget
{
  AdCard({super.key, required this.ad});

  AdData ad;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {Navigator.pushNamed(context, "/edit_ad", arguments: ad).then((x) {
        BlocProvider.of<AdCubit>(context).getUserAds();
      });},
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),
          side: new BorderSide(color: TierConverts.TierColor(ad.tier))
        ),
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
                    image: ad.image, fit: BoxFit.cover,),
              ),

              Padding(padding: EdgeInsets.only(right: 20, left: 20, top: 5),
                child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(ad.category.icon, color: Colors.grey.shade700,),
                      SizedBox(
                        width: 90,
                        child: Text(ad.name, style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                          textDirection: TextDirection.rtl,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
              )
              ),

              Text("عدد المشاهدات : ${ad.views}", style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
              ), textDirection: TextDirection.rtl,)
            ],
          ),
        ),
      ),
    );
  }
}