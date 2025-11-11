import 'dart:async';
import 'package:ads_app/Models/ad_models.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class FixedAdsArea extends StatefulWidget {
  const FixedAdsArea({super.key, required this.ads});

  final List<AdData> ads;

  @override
  State<FixedAdsArea> createState() => _FixedAdsAreaState();
}

class _FixedAdsAreaState extends State<FixedAdsArea> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.9);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // بدء التحرك التلقائي للـ Slider
    if (widget.ads.isNotEmpty) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (widget.ads.isEmpty) return;
      
      _currentPage = (_currentPage + 1) % widget.ads.length;
      
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Slider Container
          Container(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.ads.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, i) {
                return _itemBuilder(context, i);
              },
            ),
          ),
          
          SizedBox(height: 12),
          
          // Custom Indicators
          _buildIndicators(),
        ],
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int i) {
    bool isActive = i == _currentPage;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: isActive ? 0 : 12,
      ),
      child: GestureDetector(
        onTap: () {
          _action(context, i);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF2596FA).withOpacity(isActive ? 0.3 : 0.15),
                blurRadius: isActive ? 20 : 10,
                spreadRadius: isActive ? 2 : 0,
                offset: Offset(0, isActive ? 8 : 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Image with Gradient Overlay
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Main Image
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: FadeInImage.assetNetwork(
                        placeholder: "assets/imgs/Loading.gif",
                        fit: BoxFit.cover,
                        image: widget.ads[i].image,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 60,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'خطأ في تحميل الصورة',
                                  style: GoogleFonts.cairo(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Gradient Overlay for better text visibility
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 0.3, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Ad Title at Bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Text(
                    widget.ads[i].name,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.ads.length,
        (index) => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 32 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: _currentPage == index
                ? LinearGradient(
                    colors: [
                      Color(0xFF2596FA),
                      Color(0xFF364A62),
                    ],
                  )
                : null,
            color: _currentPage == index ? null : Colors.grey.shade300,
            boxShadow: _currentPage == index
                ? [
                    BoxShadow(
                      color: Color(0xFF2596FA).withOpacity(0.4),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  Future<void> _action(BuildContext context, int i) async {
    final url = widget.ads[i].path;

    // محاولة فتح الرابط (هيفتح التطبيق لو متوفر أو المتصفح)
    try {
      final Uri uri = Uri.parse(url);

      // لو الرابط يقدر يتفتح
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // يفتح في تطبيق خارجي
        );
      } else {
        // لو فشل، نحاول نفتحه كأي رابط عادي
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'عذراً، لا يمكن فتح هذا الرابط',
                textDirection: TextDirection.rtl,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // لو حصل خطأ في الرابط
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ في فتح الرابط',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
