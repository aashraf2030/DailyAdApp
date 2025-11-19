import 'package:ads_app/Bloc/Ad/ad_cubit.dart';
import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Models/ad_models.dart';
import 'package:ads_app/Widgets/ad_loading_card.dart';
import 'package:ads_app/Widgets/ad_watch_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AllAdsArea extends StatefulWidget {
  const AllAdsArea({super.key});

  @override
  AllAdsAreaState createState() => AllAdsAreaState();
}

class AllAdsAreaState extends State<AllAdsArea> with SingleTickerProviderStateMixin {
  List<AdData> ads = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();

    // Fetch only Dynamic ads (category -1 means all categories)
    // This works for both guests and logged-in users
    // AuthInterceptor will automatically add token if user is logged in
    BlocProvider.of<AdCubit>(context).fetchAds(-1, full: true, adType: 'Dynamic');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget buildByBloc(context, state) {
    if (state is AdLoadingState || state is AdInitialState) {
      return GridView.builder(
        itemBuilder: buildLoadingCards,
        itemCount: 6,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(12),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
      );
    } else if (state is AdDoneState) {
      ads = state.data;
      
      if (ads.isEmpty) {
        return _buildEmptyState();
      }
      
      return GridView.builder(
        cacheExtent: 1000,
        itemBuilder: buildCards,
        itemCount: ads.length,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
      );
    } else if (state is AdErrorState) {
      return _buildErrorState();
    } else {
      // Default: show loading
      return GridView.builder(
        itemBuilder: buildLoadingCards,
        itemCount: 6,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(12),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16),
          Text(
            "لا توجد إعلانات حالياً",
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          SizedBox(height: 16),
          Text(
            "حدث خطأ في التحميل",
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.red.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoadingCards(context, int i) {
    return AdLoadingCard();
  }

  Widget buildCards(context, int i) {
    final cubit = BlocProvider.of<OperationalCubit>(context);
    return BlocProvider.value(
      value: cubit,
      child: AdWatchCard(ad: ads[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            BlocBuilder<AdCubit, AdState>(builder: buildByBloc),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2596FA).withOpacity(0.05),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: TextDirection.rtl,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [

              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2596FA),
                      Color(0xFF364A62),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2596FA).withOpacity(0.25),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  FontAwesomeIcons.rectangleAd,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              
              SizedBox(width: 10),
              

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "جميع الإعلانات",
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  if (ads.isNotEmpty)
                    Text(
                      "${ads.length} إعلان متاح",
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ],
          ),
          

          if (ads.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Color(0xFF2596FA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "جديد",
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2596FA),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

