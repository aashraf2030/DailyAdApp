import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:ads_app/Models/ad_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdWatchCard extends StatefulWidget {
  AdWatchCard({super.key, required this.ad});

  AdData ad;

  @override
  WatchCardState createState() => WatchCardState();
}

class WatchCardState extends State<AdWatchCard> with SingleTickerProviderStateMixin {
  int views = 0;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    views = widget.ad.views;
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        show(context);
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF2596FA).withOpacity(0.08),
                blurRadius: 20,
                spreadRadius: 0,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Stack(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: FadeInImage.assetNetwork(
                      placeholder: "assets/imgs/Loading.gif",
                      image: widget.ad.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 140,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 32,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                  
                  
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "$views",
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  
                  Positioned(
                    bottom: 12,
                    right: 12,
                    left: 12,
                    child: Text(
                      widget.ad.name,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              
              Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF2596FA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "مشاهدة الآن",
                            style: GoogleFonts.cairo(
                              color: Color(0xFF2596FA),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> show(context) async {
    final cubit = BlocProvider.of<OperationalCubit>(context);
    
    
    if (cubit.isGuest()) {
      final url = widget.ad.path;
      try {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'عذراً، لا يمكن فتح هذا الرابط',
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.cairo(),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'خطأ في فتح الرابط',
                textDirection: TextDirection.rtl,
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return; 
    }
    
    
    if (cubit.isMyAd(widget.ad.userid)) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "تنبيه",
                style: GoogleFonts.cairo(
                  color: Color(0xFF2596FA),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                "لا يمكنك مشاهدة إعلانك الخاص بك",
                style: GoogleFonts.cairo(
                  color: Color(0xFF2C3E50),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "حسناً",
                    style: GoogleFonts.cairo(
                      color: Color(0xFF2596FA),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
      return;
    }

    
    
    
    
    final int availability = await cubit.recordLocalView(widget.ad.id);

    if (availability == 2) {
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تجاوزت الحد المسموح (10 مرات) لهذا الإعلان. يرجى الانتظار ساعة واحدة.',
              textDirection: TextDirection.rtl,
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    
    final url = widget.ad.path;
    
    try {
      final Uri uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        
        if (availability == 0) {
          final res = await cubit.watchAd(widget.ad.id);

          if (!res) {
            
            
            
            
          } else {
            
            setState(() {
              views++;
            });
            
            
            if (context.mounted) {
              context.read<AuthCubit>().getProfile(forceRefresh: true);
            }
          }
        }
      } else {
        
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
