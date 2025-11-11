import 'dart:async';
import 'package:ads_app/Bloc/Ad/ad_cubit.dart';
import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:ads_app/Models/ad_models.dart';
import 'package:ads_app/Widgets/ad_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class MyAds extends StatefulWidget
{
  const MyAds({super.key});

  @override
  MyAdsState createState () => MyAdsState();
}

class MyAdsState extends State<MyAds>
{
  List<AdData> ads = [];
  bool _showNoData = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<AdCubit>(context).getUserAds();
    
    // بعد 3 ثواني لو لسه بيحمل، نعتبر مافيش داتا
    _timer = Timer(Duration(seconds: 3), () {
      if (mounted && ads.isEmpty) {
        setState(() {
          _showNoData = true;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        children: [
          // Header مع زرار إنشاء إعلان
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2596FA),
                    Color(0xFF364A62),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF2596FA).withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => createAd(context),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                        SizedBox(width: 10),
                        Text(
                          "إنشاء إعلان جديد",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // محتوى الإعلانات
          Expanded(
            child: BlocBuilder<AdCubit, AdState>(
              builder: dataBuilder,
            ),
          ),
        ],
      ),
    );
  }

  Widget dataBuilder (context, state)
  {
    if (state is AdLoadingState || (ads.isEmpty && !_showNoData))
      {
        // Skeleton UI بدلاً من Spinner
        return _buildSkeletonLoader();
      }
    else if (state is AdDoneState)
      {
        ads = state.data;
        _timer?.cancel(); // إلغاء التايمر لما الداتا توصل
        
        if (ads.isNotEmpty)
          {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68, // عشان Progress Bar والمحتوى الجديد
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: cardBuilder,
              padding: EdgeInsets.all(16),
              shrinkWrap: false,
              itemCount: ads.length,
            );
          }
        else {
          return _buildEmptyState();
        }
      }
    else if (state is AdErrorState)
      {
        return _buildErrorState();
      }
    else if (_showNoData)
      {
        return _buildEmptyState();
      }
    else
      {
        return _buildSkeletonLoader();
      }
  }
  
  // Skeleton Loading UI
  Widget _buildSkeletonLoader() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68, // نفس قيمة الكروت الحقيقية
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20), // نفس الـ border radius
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  height: 140, // نفس ارتفاع الصورة في الكارت الحقيقي
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title placeholder
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 12),
                      // Progress bar placeholder
                      Container(
                        width: double.infinity,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Color(0xFF2596FA).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.ad_units_outlined,
              size: 60,
              color: Color(0xFF2596FA),
            ),
          ),
          
          SizedBox(height: 24),
          
          Text(
            "لا توجد إعلانات",
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          
          SizedBox(height: 12),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "ابدأ بإنشاء إعلانك الأول\nللوصول لعملاء جدد",
              style: GoogleFonts.cairo(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
          
          SizedBox(height: 32),
          
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2596FA),
                  Color(0xFF364A62),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF2596FA).withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => createAd(context),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "إنشاء إعلان",
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Error State
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade300,
          ),
          SizedBox(height: 16),
          Text(
            "حدث خطأ في التحميل",
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "حاول مرة أخرى",
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showNoData = false;
                ads = [];
              });
              BlocProvider.of<AdCubit>(context).getUserAds();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2596FA),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "إعادة المحاولة",
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget cardBuilder (context, i)
  {
    return AdCard(ad: ads[i]);
  }

  void createAd(context)
  {
    final cubit = BlocProvider.of<AuthCubit>(context);

    if (cubit.isGuestMode())
      {
        showDialog(context: context, builder: (x) {
          return AlertDialog(
            icon: Icon(Icons.error),
            backgroundColor: Colors.white70,
            contentTextStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.black),
            content: Text("لا يمكن انشاء اعلان في وضع الزيارة"),
            actions: [

              OutlinedButton(onPressed: (){Navigator.pop(context);},
                child: Text("متابعة"),
              )
            ],
          );
        });
        return;
      }

    Navigator.pushNamed(context, "/create_ad").then((x) {
      setState(() {
        BlocProvider.of<AdCubit>(context).getUserAds();
      });
    });
  }

}