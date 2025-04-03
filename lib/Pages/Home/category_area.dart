import 'package:ads_app/Bloc/Ad/ad_cubit.dart';
import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Models/ad_models.dart';
import 'package:ads_app/Models/category_model.dart';
import 'package:ads_app/Widgets/ad_loading_card.dart';
import 'package:ads_app/Widgets/ad_watch_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryArea extends StatefulWidget {
  const CategoryArea({super.key, required this.category});

  final Category category;

  @override
  CategoryAreaState createState () => CategoryAreaState();
}

class CategoryAreaState extends State<CategoryArea>{

  List<AdData> ads = [];

  @override
  void initState() {
    super.initState();

    BlocProvider.of<AdCubit>(context).fetchAds(widget.category.id);
  }

  Widget buildByBloc(context, state)
  {
    if (state is AdLoadingState)
      {
        return ListView.builder(
          itemBuilder: buildLoadingCards,
          itemCount: state.size,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
        );
      }
    else if (state is AdDoneState)
      {
        ads = state.data;
        return ListView.builder(
          cacheExtent: 1000,
          itemBuilder: buildCards,
          itemCount: state.data.length,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
        );
      }
    else
      {
        return Text("خطأ في التحميل", style: GoogleFonts.cairo(color: Colors.red),);
      }
  }

  Widget buildLoadingCards(context, int i)
  {
    return AdLoadingCard();
  }
  
  Widget buildCards(context, int i)
  {
    final cubit = BlocProvider.of<OperationalCubit>(context);
    return BlocProvider.value(value: cubit, child: AdWatchCard(ad: ads[i]),);
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: 300,
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 2)
      ),
      child: Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, textDirection: TextDirection.rtl, children: [
              Text(widget.category.name, style: GoogleFonts.cairo(),),
              buildCatButton()
            ]
            )
        ),
        backgroundColor: Colors.white,

        body: BlocBuilder<AdCubit, AdState>(builder: buildByBloc)
      ),
    );
  }

  Widget buildCatButton ()
  {
    if (widget.category.id != 0)
      {
        return TextButton(onPressed: (){Navigator.pushNamed(context, "/show_cat",
            arguments: widget.category);}, child: Text("عرض الكل",
          style: GoogleFonts.cairo(color: Colors.pink[500],
              decoration: TextDecoration.underline,
              decorationColor: Colors.pink[500]
          ),));
      }

    return Text("");
  }
}