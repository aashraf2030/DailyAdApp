import 'package:ads_app/Bloc/Ad/ad_cubit.dart';
import 'package:ads_app/Bloc/Home/home_cubit.dart';
import 'package:ads_app/Models/ad_models.dart';
import 'package:ads_app/Models/category_model.dart';
import 'package:ads_app/Pages/Home/fixed_ads_area.dart';
import 'package:ads_app/Widgets/ad_watch_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ads_app/Widgets/gradient_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key, required this.category});

  final Category category;

  @override
  CategoryPageState createState() => CategoryPageState();
}

class CategoryPageState extends State<CategoryPage> {
  List<AdData> ads = [];
  List<AdData> fixedAds = [];

  @override
  void initState() {
    super.initState();
    fixedAds = BlocProvider.of<HomeCubit>(context).ads;
    BlocProvider.of<AdCubit>(context).fetchAds(widget.category.id, full: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
          automaticallyImplyLeading: false,
          title: Text(
            widget.category.name,
            style: GoogleFonts.cairo(
                color: Colors.white, fontWeight: FontWeight.bold),
            textDirection: TextDirection.rtl,
          ),
          gradient: LinearGradient(colors: [
            Color.fromRGBO(37, 150, 250, 1),
            Color.fromRGBO(54, 74, 98, 0.85)
          ], transform: GradientRotation(0.5)),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_forward))
          ],
        ),
        body: Column(
          children: [
            FixedAdsArea(ads: fixedAds),
            Expanded(child: BlocBuilder<AdCubit, AdState>(builder: dataBuilder))
          ],
        )
        );
  }

  Widget dataBuilder(context, state) {
    if (state is AdLoadingState) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.blueAccent,
        ),
      );
    } else if (state is AdDoneState) {
      ads = state.data;

      if (ads.isNotEmpty) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          padding: const EdgeInsets.all(8),
          itemCount: ads.length,
          itemBuilder: cardBuilder,
        );
      } else {
        return Text(
          "لا يوجد اعلانات",
          style: GoogleFonts.cairo(color: Colors.black),
        );
      }
    } else if (state is AdErrorState) {
      return Text(
        "خطأ",
        style: GoogleFonts.cairo(color: Colors.red),
      );
    } else {
      return CircularProgressIndicator(
        color: Colors.blueAccent,
      );
    }
  }

  Widget cardBuilder(context, i) {
    return AdWatchCard(ad: ads[i]);
  }
}
