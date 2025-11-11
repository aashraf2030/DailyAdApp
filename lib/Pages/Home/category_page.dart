import 'package:ads_app/Bloc/Ad/ad_cubit.dart';
import 'package:ads_app/Bloc/Home/home_cubit.dart';
import 'package:ads_app/Models/ad_models.dart';
import 'package:ads_app/Models/category_model.dart';
import 'package:ads_app/Pages/Home/fixed_ads_area.dart';
import 'package:ads_app/Widgets/ad_watch_card.dart';
import 'package:ads_app/Widgets/ad_loading_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ads_app/Widgets/gradient_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

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
      return _buildSkeletonLoader();
    } else if (state is AdDoneState) {
      ads = state.data;

      if (ads.isNotEmpty) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          padding: const EdgeInsets.all(12),
          itemCount: ads.length,
          itemBuilder: cardBuilder,
        );
      } else {
        return _buildEmptyState();
      }
    } else if (state is AdErrorState) {
      return _buildErrorState();
    } else {
      return _buildSkeletonLoader();
    }
  }

  Widget _buildSkeletonLoader() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      padding: const EdgeInsets.all(12),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.category.icon,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 24),
          Text(
            "لا توجد إعلانات في ${widget.category.name}",
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            "كن أول من ينشر إعلاناً في هذه الفئة!",
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
          ),
          SizedBox(height: 24),
          Text(
            "حدث خطأ في تحميل الإعلانات",
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              BlocProvider.of<AdCubit>(context).fetchAds(widget.category.id, full: true);
            },
            icon: Icon(Icons.refresh),
            label: Text(
              "إعادة المحاولة",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2596FA),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget cardBuilder(context, i) {
    return AdWatchCard(ad: ads[i]);
  }
}
