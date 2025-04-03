import 'package:ads_app/Bloc/Ad/ad_cubit.dart';
import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:ads_app/Bloc/Authority/authority_cubit.dart';
import 'package:ads_app/Bloc/Home/home_cubit.dart';
import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Models/category_model.dart';
import 'package:ads_app/Pages/Admin/admin_ad_request.dart';
import 'package:ads_app/Pages/Admin/admin_panel.dart';
import 'package:ads_app/Pages/Home/fixed_ads_area.dart';
import 'package:ads_app/Pages/Home/money_request.dart';
import 'package:ads_app/Pages/Home/profile_page.dart';
import 'package:ads_app/Widgets/category_button.dart';
import 'package:ads_app/Widgets/page_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'category_area.dart';
import 'my_ads.dart';

class HomePage extends StatefulWidget{
  HomePage({super.key});

  int _currentIndex = 0;
  bool isAdmin = false;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
{

  @override
  void initState() {
    super.initState();

    (BlocProvider.of<AuthCubit>(context).isAdmin()).then((x){
      setState(() {
        widget.isAdmin = x;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        automaticallyImplyLeading: false,
        title: BlocProvider.value(value: BlocProvider.of<HomeCubit>(context),
          child:  PageTitle(),),
        gradient: LinearGradient(colors: [Color.fromRGBO(37, 150, 250, 1),
          Color.fromRGBO(54, 74, 98, 0.85)], transform: GradientRotation(0.5)),
      ),
      backgroundColor: Color.fromRGBO(250, 255, 255, 1),
      body: BlocBuilder<HomeCubit, HomeState>(
        bloc: BlocProvider.of(context),
        builder: buildBody,
      ),
      bottomNavigationBar: BlocBuilder<HomeCubit, HomeState>(builder: buildNavbar)
    );
  }

  Widget buildBody (context, state)
  {
    switch (state.runtimeType)
    {
      case HomeLandingState :
        return HomeLanding(type: 0);

      case HomeSearchState :
        return HomeLanding(type: 1,);

      case HomeProfileState :
        return BlocProvider.value(value: BlocProvider.of<AuthCubit>(context),
          child: HomeProfile(),);

      case HomeAdsState :
        return MyAds();

      case HomeAdminState :
        return BlocProvider.value(value: BlocProvider.of<AuthorityCubit>(context),
          child:  AdminPanel(),
        );

      case HomeAdRequestState :
        return BlocProvider.value(value: BlocProvider.of<AuthorityCubit>(context),
          child:  AdminAdRequestPage(),
        );

      case HomeMoneyRequestState :
        return BlocProvider.value(value: BlocProvider.of<AuthorityCubit>(context),
          child:  MoneyRequestPage(),
        );

      default:
        return HomeLanding(type: 0,);
    }
  }

  Widget buildNavbar (context, state)
  {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      iconSize: 35,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: generateNavItems(),
      currentIndex: widget._currentIndex,
      onTap: changeScreen,
    );
  }

  List<BottomNavigationBarItem> generateNavItems()
  {
    if (widget.isAdmin)
      {
        return [
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.house), label: "Home", backgroundColor: Colors.white),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.magnifyingGlass), label: "Search", backgroundColor: Colors.white),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.chartBar), label: "My Ads", backgroundColor: Colors.white),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.circleUser), label: "User", backgroundColor: Colors.white),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.userTie), label: "Admin", backgroundColor: Colors.white),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.personCircleQuestion), label: "Request", backgroundColor: Colors.white),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.moneyBillTransfer), label: "Money", backgroundColor: Colors.white),
        ];
      }
    else
      {
        return [
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.house), label: "Home", backgroundColor: Colors.white),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.magnifyingGlass), label: "Search", backgroundColor: Colors.white),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.chartBar), label: "My Ads", backgroundColor: Colors.white),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.circleUser), label: "User", backgroundColor: Colors.white),
        ];
      }
  }

  void changeScreen(int i)
  {
    widget._currentIndex = BlocProvider.of<HomeCubit>(context).changeRoute(i);
  }
}

class HomeLanding extends StatelessWidget{
  const HomeLanding({super.key, this.type});

  final type;

  @override
  Widget build(BuildContext context)
  {
  switch (type)
    {
      case 0:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
//            FixedAdsArea(),
            Expanded(child: ListView.builder(itemBuilder: categoryAreasBuilder,
              cacheExtent: 1000,
              itemCount: categories.length,
              )
            )
          ],
        );

      case 1:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
//            FixedAdsArea(),
            Expanded(child: ListView(
              children: buildCategoryButtons(),
            ))
          ],
        );

      default:
        return Center(child: Text("هذا خطأ"),);
    }
  }

  Widget categoryAreasBuilder(context, int i)
  {
    SharedPreferences prefs = BlocProvider.of<AdCubit>(context).prefs;

    return MultiBlocProvider(providers:[
      BlocProvider(create: (_){return AdCubit(AdInitialState(), prefs);}),
      BlocProvider(create: (_){return OperationalCubit(InitialOperational(), prefs);})
    ],
        child: CategoryArea(category: categories[i]));
  }

  List<Widget> buildCategoryButtons()
  {
    List<Widget> res = [];

    for (var cat in categories) {
      if (cat.id == 0) {
        continue;
      }

      res.add(CategoryButton(cat.id,),);
    }

    return res;
  }

  void searchResult(int i)
  {
    
  }
}
