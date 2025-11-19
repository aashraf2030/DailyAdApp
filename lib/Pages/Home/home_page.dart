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
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../chat/chat_page.dart';
import '../chat/admin_chat_list_page.dart';
import '../../core/di/service_locator.dart';
import '../../Bloc/chat/chat_cubit.dart';
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

          BlocBuilder<HomeCubit, HomeState>(
            bloc: BlocProvider.of(context),
            builder: buildBody,
          ),


        ],
      ),
      bottomNavigationBar:
          BlocBuilder<HomeCubit, HomeState>(builder: buildNavbar),
      floatingActionButton: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          // إخفاء أيقونة الواتساب في صفحة الدردشة
          if (state is HomeChatState) {
            return const SizedBox.shrink();
          }
          // عرض أيقونة الواتساب في باقي الصفحات
          return FloatingActionButton(
            onPressed: _openWhatsApp,
            backgroundColor: Color(0xFF25D366),
            child: FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Colors.white,
              size: 30,
            ),
            tooltip: 'تواصل معنا على واتساب',
          );
        },
      ),
    );
  }

  Future<void> _openWhatsApp() async {
    final phoneNumber = '966570949696';
    final whatsappUrl = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent('مرحباً، أحتاج المساعدة')}');
    
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
    if (state is HomeLoadingState) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is HomeLandingState) {
      // جلب الإعلانات الثابتة فقط للعرض في الـ Slider
      final fixedAds = BlocProvider.of<HomeCubit>(context).getFixedAds();
      return BlocProvider.value(
        value: BlocProvider.of<AdCubit>(context),
        child: HomeLanding(type: 0, ads: state.ads, fixedAds: fixedAds),
      );
    }

    if (state is HomeSearchState) {
      // جلب الإعلانات الثابتة فقط للعرض في الـ Slider
      final fixedAds = BlocProvider.of<HomeCubit>(context).getFixedAds();
      return BlocProvider.value(
        value: BlocProvider.of<AdCubit>(context),
        child: HomeLanding(type: 1, ads: state.ads, fixedAds: fixedAds),
      );
    }

    if (state is HomeProfileState) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: BlocProvider.of<AuthCubit>(context)),
          BlocProvider.value(value: BlocProvider.of<OperationalCubit>(context)),
        ],
        child: HomeProfile(),
      );
    }

    if (state is HomeAdsState) {
      return MyAds();
    }

    if (state is HomeAdminState) {
      return FutureBuilder<bool>(
        future: BlocProvider.of<AuthCubit>(context).isAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // فحص لو المستخدم مسؤول
          if (snapshot.hasData && snapshot.data == true) {
            return BlocProvider.value(
              value: BlocProvider.of<AuthorityCubit>(context),
              child: AdminPanel(),
            );
          } else {
            // المستخدم ليس مسؤول - عرض رسالة خطأ
            return _buildAccessDeniedPage(context);
          }
        },
      );
    }

    if (state is HomeAdRequestState) {
      return FutureBuilder<bool>(
        future: BlocProvider.of<AuthCubit>(context).isAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // فحص لو المستخدم مسؤول
          if (snapshot.hasData && snapshot.data == true) {
            return BlocProvider.value(
              value: BlocProvider.of<AuthorityCubit>(context),
              child: AdminAdRequestPage(),
            );
          } else {
            // المستخدم ليس مسؤول - عرض رسالة خطأ
            return _buildAccessDeniedPage(context);
          }
        },
      );
    }

    if (state is HomeMoneyRequestState) {
      return FutureBuilder<bool>(
        future: BlocProvider.of<AuthCubit>(context).isAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // فحص لو المستخدم مسؤول
          if (snapshot.hasData && snapshot.data == true) {
            return BlocProvider.value(
              value: BlocProvider.of<AuthorityCubit>(context),
              child: MoneyRequestPage(),
            );
          } else {
            // المستخدم ليس مسؤول - عرض رسالة خطأ
            return _buildAccessDeniedPage(context);
          }
        },
      );
    }

    if (state is HomeChatState) {
      // للمسؤول: عرض قائمة المحادثات مباشرة
      if (widget.isAdmin) {
        return BlocProvider(
          create: (_) => sl<ChatCubit>(),
          child: const AdminChatListPage(),
        );
      }
      
      // للمستخدم العادي: عرض صفحة الدردشة مباشرة
      // بدون أي تحقق - فقط فحص بسيط لتسجيل الدخول
      return FutureBuilder<bool>(
        future: BlocProvider.of<AuthCubit>(context).isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // فحص لو المستخدم مسجل دخول
          final isGuest = BlocProvider.of<OperationalCubit>(context).prefs.getBool("guest") ?? false;
          
          if (snapshot.hasData && snapshot.data == true && !isGuest) {
            // المستخدم مسجل دخول - عرض ChatPage مباشرة
            return BlocProvider(
              create: (_) => sl<ChatCubit>(),
              child: const ChatPage(),
            );
          } else {
            // المستخدم غير مسجل دخول - عرض رسالة تسجيل الدخول
            return _buildChatLoginRequiredPage(context);
          }
        },
      );
    }

    return const Center(child: CircularProgressIndicator());
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
                                shape: BoxShape.circle,
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
            icon: FaIcon(FontAwesomeIcons.comments), label: "الدردشة"),
      ];
    } else {
      // المستخدم العادي: أيقونة مخصصة للدردشة (message icon)
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
            icon: FaIcon(FontAwesomeIcons.message), label: "الدردشة"),
      ];
    }
  }

  void changeScreen(int i) {
    setState(() {
      widget._currentIndex = BlocProvider.of<HomeCubit>(context).changeRoute(i);
    });
  }
}

class HomeLanding extends StatefulWidget {
  const HomeLanding({super.key, this.type, required this.ads, this.fixedAds});

  final type;
  final List<AdData> ads;  // كل الإعلانات
  final List<AdData>? fixedAds;  // الإعلانات الثابتة فقط

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

              Padding(
                padding: EdgeInsets.only(top: 220),
                child: ListView(
                  children: [

                    _buildWelcomeBanner(context),
                    
                    SizedBox(height: 4),
                    

                    allAdsBuilder(context),
                  ],
                ),
              ),
              

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
                  child: FixedAdsArea(ads: widget.fixedAds ?? []),
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

              Padding(
                padding: EdgeInsets.only(top: 220),
                child: Column(
                  children: [

                    _buildSearchHeader(),
                    

                    Expanded(
                      child: _buildCategoriesGrid(),
                    ),
                  ],
                ),
              ),
              

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
                  child: FixedAdsArea(ads: widget.fixedAds ?? []),
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
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: BlocProvider.of<AdCubit>(context)),
        BlocProvider.value(value: BlocProvider.of<OperationalCubit>(context)),
      ],
      child: CategoryArea(category: CategoryManager.getCategoryById(i)),
    );
  }

  Widget allAdsBuilder(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: BlocProvider.of<AdCubit>(context)),
        BlocProvider.value(value: BlocProvider.of<OperationalCubit>(context)),
      ],
      child: AllAdsArea(),
    );
  }
}

Widget _buildAccessDeniedPage(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2596FA), Color(0xFF364A62)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // أيقونة القفل
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // العنوان
                  Text(
                    'غير مصرح بالوصول',
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // الرسالة
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'هذه الصفحة متاحة فقط للمسؤولين\nليس لديك صلاحيات للوصول إلى صفحة الإدارة',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        color: Colors.white,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // زر العودة
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<HomeCubit>(context).changeRoute(0);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2596FA),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_back, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'العودة للرئيسية',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
}

Widget _buildChatLoginRequiredPage(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2596FA), Color(0xFF364A62)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة القفل
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // العنوان
                Text(
                  'تسجيل الدخول مطلوب',
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // الرسالة
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'برجاء تسجيل الدخول أولاً\nحتى تتمكن من استخدام الدردشة',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // زر تسجيل الدخول
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2596FA),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.login, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'تسجيل الدخول',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () {
                    BlocProvider.of<HomeCubit>(context).changeRoute(0);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'العودة للرئيسية',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
