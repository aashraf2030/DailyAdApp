import 'package:ads_app/Bloc/Ad/ad_cubit.dart';
import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Models/ad_models.dart';
import 'package:ads_app/Models/category_model.dart';
import 'package:ads_app/Widgets/ad_loading_card.dart';
import 'package:ads_app/Widgets/ad_watch_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryArea extends StatefulWidget {
  const CategoryArea({super.key, required this.category});

  final Category category;

  @override
  CategoryAreaState createState() => CategoryAreaState();
}

class CategoryAreaState extends State<CategoryArea> with SingleTickerProviderStateMixin {
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
    BlocProvider.of<AdCubit>(context).fetchAds(widget.category.id, full: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget buildByBloc(context, state) {
    if (state is AdLoadingState) {
      return GridView.builder(
        itemBuilder: buildLoadingCards,
        itemCount: 4,
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
        itemCount: ads.length > 4 ? 4 : ads.length,
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
    } else {
      return _buildErrorState();
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
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            BlocBuilder<AdCubit, AdState>(builder: buildByBloc),
            if (widget.category.id != 0 && ads.isNotEmpty) _buildViewAllButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
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
              // أيقونة الفئة
              Container(
                padding: EdgeInsets.all(10),
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
                      color: Color(0xFF2596FA).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.category.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              
              SizedBox(width: 12),
              
              // اسم الفئة
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.name,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  if (ads.isNotEmpty)
                    Text(
                      "${ads.length} إعلان",
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ],
          ),
          
          // Badge
          if (ads.length > 4)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF2596FA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "جديد",
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2596FA),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildViewAllButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pushNamed(context, "/show_cat", arguments: widget.category);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2596FA).withOpacity(0.08),
                  Color(0xFF364A62).withOpacity(0.08),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFF2596FA).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "عرض الكل",
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2596FA),
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_back_ios,
                  size: 14,
                  color: Color(0xFF2596FA),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}