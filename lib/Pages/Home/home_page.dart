import 'dart:ui';
import 'package:ads_app/Bloc/Ad/ad_cubit.dart';
import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:ads_app/Bloc/Authority/authority_cubit.dart';
import 'package:ads_app/Bloc/Home/home_cubit.dart';
import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Models/ad_models.dart';
import 'package:ads_app/Models/category_manager.dart';
import 'package:ads_app/Pages/Admin/admin_ad_request.dart';
import 'package:ads_app/Pages/Admin/admin_panel.dart';
import 'package:ads_app/Pages/Home/fixed_ads_area.dart';
import 'package:ads_app/Pages/Home/money_request.dart';
import 'package:ads_app/Pages/Home/profile_page.dart';
import 'package:ads_app/Widgets/category_button.dart';
import 'package:ads_app/Widgets/page_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ads_app/Widgets/gradient_app_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../chat/assistant_panel.dart';
import 'category_area.dart';
import 'my_ads.dart';
import 'all_ads_area.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  int _currentIndex = 0;
  bool isAdmin = false;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool _showAssistant = false;

  int get _assistantIndex => widget.isAdmin ? 7 : 4;

  @override
  void initState() {
    super.initState();
    (BlocProvider.of<AuthCubit>(context).isAdmin()).then((x) {
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
        title: BlocProvider.value(
          value: BlocProvider.of<HomeCubit>(context),
          child: PageTitle(),
        ),
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(37, 150, 250, 1),
            Color.fromRGBO(54, 74, 98, 0.85)
          ],
          transform: GradientRotation(0.5),
        ),
      ),
      backgroundColor: const Color.fromRGBO(250, 255, 255, 1),
      body: Stack(
        children: [
          // المحتوى العادي
          BlocBuilder<HomeCubit, HomeState>(
            bloc: BlocProvider.of(context),
            builder: buildBody,
          ),

          // خلفية بلور خفيفة و بانل المساعد الذكي (Overlay)
          if (_showAssistant) ...[
            // ضباب خفيف للخلفية
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showAssistant = false),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    color: Colors.black.withOpacity(0.15),
                  ),
                ),
              ),
            ),
            // البانل نفسه
            Positioned(
              left: 0,
              right: 0,
              bottom: 70, // نخلي مساحة للـ BottomNavigationBar
              top: 12,
              child: SafeArea(
                minimum: const EdgeInsets.fromLTRB(12, 12, 12, 82),
                child: AssistantPanel.withCubit(),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar:
          BlocBuilder<HomeCubit, HomeState>(builder: buildNavbar),
      floatingActionButton: FloatingActionButton(
        onPressed: _openWhatsApp,
        backgroundColor: Color(0xFF25D366),
        child: FaIcon(
          FontAwesomeIcons.whatsapp,
          color: Colors.white,
          size: 30,
        ),
        tooltip: 'تواصل معنا على واتساب',
      ),
    );
  }

  Future<void> _openWhatsApp() async {
    final phoneNumber = '966570949696';
    final whatsappUrl = Uri.parse('https://wa.me/$phoneNumber');
    
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(
          whatsappUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'عذراً، لا يمكن فتح واتساب',
                textDirection: TextDirection.rtl,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ في فتح واتساب',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget buildBody(context, state) {
    switch (state.runtimeType) {
      case HomeLoadingState:
        return const Center(child: CircularProgressIndicator());

      case HomeLandingState:
        return BlocProvider.value(
          value: BlocProvider.of<AdCubit>(context),
          child: HomeLanding(type: 0, ads: state.ads),
        );

      case HomeSearchState:
        return BlocProvider.value(
          value: BlocProvider.of<AdCubit>(context),
          child: HomeLanding(type: 1, ads: state.ads),
        );

      case HomeProfileState:
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: BlocProvider.of<AuthCubit>(context)),
            BlocProvider.value(value: BlocProvider.of<OperationalCubit>(context)),
          ],
          child: HomeProfile(), // شيلنا const
        );

      case HomeAdsState:
        return MyAds(); // شيلنا const

      case HomeAdminState:
        return BlocProvider.value(
          value: BlocProvider.of<AuthorityCubit>(context),
          child: AdminPanel(), // شيلنا const
        );

      case HomeAdRequestState:
        return BlocProvider.value(
          value: BlocProvider.of<AuthorityCubit>(context),
          child: AdminAdRequestPage(), // شيلنا const
        );

      case HomeMoneyRequestState:
        return BlocProvider.value(
          value: BlocProvider.of<AuthorityCubit>(context),
          child: MoneyRequestPage(), // شيلنا const
        );

      default:
        return const Center(child: RefreshProgressIndicator());
    }
  }

  Widget buildNavbar(context, state) {
    final items = generateNavItems();
    
    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final isSelected = widget._currentIndex == index;
                  final item = items[index];
                  
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => changeScreen(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // أيقونة مع خلفية دائرية للمحدد
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [Color(0xFF2596FA), Color(0xFF364A62)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected ? null : Colors.transparent,
                                shape: BoxShape.circle, // دائري تماماً
                              ),
                              child: item.icon is FaIcon
                                  ? FaIcon(
                                      (item.icon as FaIcon).icon,
                                      color: isSelected ? Colors.white : Colors.grey.shade600,
                                      size: 22,
                                    )
                                  : Icon(
                                      (item.icon as Icon).icon,
                                      color: isSelected ? Colors.white : Colors.grey.shade600,
                                      size: 22,
                                    ),
                            ),
                            
                            const SizedBox(height: 2),
                            
                            // نص الـ label
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: GoogleFonts.cairo(
                                fontSize: isSelected ? 10 : 9,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? const Color(0xFF2596FA) : Colors.grey.shade600,
                              ),
                              child: Text(
                                item.label ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> generateNavItems() {
    if (widget.isAdmin) {
      return const [
        BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house), label: "الرئيسية"),
        BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.magnifyingGlass), label: "بحث"),
        BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.chartBar), label: "إعلاناتي"),
        BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.circleUser), label: "الحساب"),
        BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.userTie), label: "الإدارة"),
        BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.personCircleQuestion),
            label: "الطلبات"),
        BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.moneyBillTransfer), label: "المدفوعات"),
        BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.robot), label: "المساعد"),
      ];
    } else {
      return const [
        BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house), label: "الرئيسية"),
        BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.magnifyingGlass), label: "بحث"),
        BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.chartBar), label: "إعلاناتي"),
        BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.circleUser), label: "الحساب"),
        BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.robot), label: "المساعد"),
      ];
    }
  }

  void changeScreen(int i) {
    // زر المساعد → أظهر/أخفي البانل من غير ما أغير التاب الحالي
    if (i == _assistantIndex) {
      setState(() => _showAssistant = !_showAssistant);
      return;
    }
    setState(() {
      widget._currentIndex = BlocProvider.of<HomeCubit>(context).changeRoute(i);
    });
  }
}

class HomeLanding extends StatefulWidget {
  const HomeLanding({super.key, this.type, required this.ads});

  final type;
  final List<AdData> ads;

  @override
  State<HomeLanding> createState() => _HomeLandingState();
}

class _HomeLandingState extends State<HomeLanding> {
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case 0:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF8F9FA),
                Color(0xFFFFFFFF),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // المحتوى الرئيسي مع padding من فوق عشان الـ slider
              Padding(
                padding: EdgeInsets.only(top: 220), // مساحة للـ slider
                child: ListView(
                  children: [
                    // Welcome Banner
                    _buildWelcomeBanner(context),
                    
                    SizedBox(height: 4),
                    
                    // All Ads (بدون فئات)
                    allAdsBuilder(context),
                  ],
                ),
              ),
              
              // Fixed Ads Area - ثابت في الأعلى
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FixedAdsArea(ads: widget.ads),
                ),
              ),
            ],
          ),
        );
      case 1:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF5F7FA),
                Color(0xFFFFFFFF),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // المحتوى الرئيسي مع padding من فوق
              Padding(
                padding: EdgeInsets.only(top: 220), // مساحة للـ slider
                child: Column(
                  children: [
                    // Search Header مع شريط البحث
                    _buildSearchHeader(),
                    
                    // Categories Grid
                    Expanded(
                      child: _buildCategoriesGrid(),
                    ),
                  ],
                ),
              ),
              
              // Fixed Ads Area - ثابت في الأعلى
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FixedAdsArea(ads: widget.ads),
                ),
              ),
            ],
          ),
        );
      default:
        return const Center(child: Text("هذا خطأ"));
    }
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Padding(
            padding: EdgeInsets.only(bottom: 12, right: 4),
            child: Text(
              "تصفح مخصص",
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          
          // شريط البحث
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Color(0xFFE0E6ED),
                width: 1,
              ),
            ),
            child: TextField(
              textDirection: TextDirection.rtl,
              style: GoogleFonts.cairo(
                fontSize: 15,
                color: Color(0xFF2C3E50),
              ),
              decoration: InputDecoration(
                hintText: "ابحث عن فئة...",
                hintTextDirection: TextDirection.rtl,
                hintStyle: GoogleFonts.cairo(
                  color: Color(0xFF95A5A6),
                  fontSize: 15,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(
                    Icons.search,
                    color: Color(0xFF95A5A6),
                    size: 24,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final filteredCategories = _getFilteredCategories();
    
    if (filteredCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              "لا توجد نتائج",
              style: GoogleFonts.cairo(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "جرب كلمة بحث أخرى",
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
      ),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        return CategoryButton(filteredCategories[index]);
      },
    );
  }

  List<int> _getFilteredCategories() {
    final allCategories = CategoryManager.getAllSearchCategories()
        .where((cat) => cat.id != 0)
        .toList();
    
    if (_searchQuery.isEmpty) {
      return allCategories.map((cat) => cat.id).toList();
    }
    
    return allCategories
        .where((cat) => cat.name.toLowerCase().contains(_searchQuery))
        .map((cat) => cat.id)
        .toList();
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2596FA),
            Color(0xFF364A62),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2596FA).withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "مرحباً بك! 👋",
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "اكتشف أحدث الإعلانات",
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.explore,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryAreasBuilder(context, int i) {
    SharedPreferences prefs = BlocProvider.of<AdCubit>(context).prefs;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AdCubit(AdInitialState(), prefs)),
        BlocProvider(
            create: (_) => OperationalCubit(InitialOperational(), prefs)),
      ],
      child: CategoryArea(category: CategoryManager.getCategoryById(i)),
    );
  }

  Widget allAdsBuilder(BuildContext context) {
    SharedPreferences prefs = BlocProvider.of<AdCubit>(context).prefs;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AdCubit(AdInitialState(), prefs)),
        BlocProvider(
            create: (_) => OperationalCubit(InitialOperational(), prefs)),
      ],
      child: AllAdsArea(),
    );
  }
}
