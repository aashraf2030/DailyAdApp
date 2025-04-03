import 'package:ads_app/Bloc/Ad/ad_cubit.dart';
import 'package:ads_app/Models/ad_models.dart';
import 'package:ads_app/Models/category_model.dart';
import 'package:ads_app/Widgets/ad_watch_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';


class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key, required this.category});


  final Category category;
  
  @override
  CategoryPageState createState () => CategoryPageState();
}

class CategoryPageState extends State<CategoryPage>{

  List<AdData> ads = [];

  @override
  void initState() {
    super.initState();

    BlocProvider.of<AdCubit>(context).fetchAds(widget.category.id, full: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.category.name, style: GoogleFonts.cairo(
            color: Colors.white, fontWeight: FontWeight.bold
          ), textDirection: TextDirection.rtl,
        ),
        gradient: LinearGradient(colors: [Color.fromRGBO(37, 150, 250, 1),
          Color.fromRGBO(54, 74, 98, 0.85)], transform: GradientRotation(0.5)),
        actions: [
          IconButton(onPressed: () {Navigator.pop(context);}, icon: Icon(Icons.arrow_forward))
        ],
      ),
      body: ConstrainedBox(constraints: BoxConstraints.expand(height: MediaQuery.sizeOf(context).height),
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
                  child: Padding(padding: EdgeInsets.all(10))
                )
            ),

            Expanded(child: BlocBuilder<AdCubit, AdState>(builder: dataBuilder))
          ],
        ),
      )
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
    return AdWatchCard(ad: ads[i]);
  }
}