import 'package:ads_app/Models/ad_models.dart';
import 'package:flutter/material.dart';

class FixedAdsArea extends StatelessWidget{
  const FixedAdsArea({super.key, required this.ads});

  final List<AdData> ads;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: 150,
      decoration: BoxDecoration(
          color: Color.fromRGBO(250, 250, 250, 1),
          boxShadow: [BoxShadow(color: Colors.black, blurRadius: 1, blurStyle: BlurStyle.outer)],
          border: Border.all(color: Colors.white, width: 1)
      ),

      child: ListView.builder(itemBuilder: itemBuilder, itemCount: ads.length,
        scrollDirection: Axis.horizontal, padding: EdgeInsets.all(10),
      ),
    );
  }

  Widget itemBuilder(context, int i)
  {
    return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      child: FadeInImage.assetNetwork(placeholder: "assets/imgs/Loading.gif",
          image: ads[i].image),
    );
  }
}