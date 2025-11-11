import 'package:ads_app/Bloc/Ad/ad_cubit.dart';
import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Models/ad_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AdCard extends StatelessWidget {
  AdCard({super.key, required this.ad});

  AdData ad;

  @override
  Widget build(BuildContext context) {
    bool isCompleted = ad.views >= ad.targetViews;
    
    return GestureDetector(
      onTap: () {
        if (!isCompleted) {
          Navigator.pushNamed(context, "/edit_ad", arguments: ad).then((x) {
            BlocProvider.of<AdCubit>(context).getUserAds();
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFF8F9FA),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: ad.isFixed 
                ? Colors.redAccent.withOpacity(0.3)
                : Color(0xFF2596FA).withOpacity(0.15),
              blurRadius: 15,
              offset: Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصورة مع Badge نوع الإعلان
              Stack(
                children: [
                  // الصورة
                  Container(
                    width: double.infinity,
                    height: 120,
                    child: FadeInImage.assetNetwork(
                      placeholder: "assets/imgs/Loading.gif",
                      image: ad.image,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Gradient Overlay للصورة
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  
                  // Badge نوع الإعلان (Fixed/Dynamic)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: ad.isFixed 
                          ? Colors.redAccent 
                          : Color(0xFF2596FA),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            ad.isFixed ? Icons.star : Icons.flash_on,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            ad.isFixed ? "ثابت" : "ديناميكي",
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // أيقونة التعديل
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Color(0xFF2596FA),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              
              // محتوى الكارت
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // اسم الإعلان
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: ad.isFixed 
                                ? Colors.redAccent.withOpacity(0.1)
                                : Color(0xFF2596FA).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              ad.category.icon,
                              color: ad.isFixed 
                                ? Colors.redAccent 
                                : Color(0xFF2596FA),
                              size: 18,
                            ),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              ad.name,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                                fontSize: 13,
                                height: 1.2,
                              ),
                              textDirection: TextDirection.rtl,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 6),
                      
                      // المشاهدات والتقدم
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            textDirection: TextDirection.rtl,
                            children: [
                              Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    "${ad.views}",
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "من ${ad.targetViews}",
                                style: GoogleFonts.cairo(
                                  color: Colors.grey.shade600,
                                  fontSize: 10,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 4),
                          
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: ad.targetViews > 0 
                                ? (ad.views / ad.targetViews).clamp(0.0, 1.0)
                                : 0.0,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ad.isFixed 
                                  ? Colors.redAccent 
                                  : Color(0xFF2596FA),
                              ),
                              minHeight: 5,
                            ),
                          ),
                          
                          SizedBox(height: 3),
                          
                          // النسبة المئوية
                          Text(
                            "${((ad.targetViews > 0 ? (ad.views / ad.targetViews) : 0) * 100).toStringAsFixed(0)}٪ مكتمل",
                            style: GoogleFonts.cairo(
                              color: Colors.grey.shade600,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                      
                      // زر التجديد (يظهر فقط للإعلانات المنتهية)
                      if (isCompleted) ...[
                        SizedBox(height: 8),
                        _buildRenewButton(context),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRenewButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2596FA),
            Color(0xFF1976D2),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2596FA).withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showRenewDialog(context),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  "تجديد الإعلان",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showRenewDialog(BuildContext context) {
    TextEditingController viewsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // أيقونة
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Color(0xFF2596FA).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: Color(0xFF2596FA),
                    size: 36,
                  ),
                ),
                
                SizedBox(height: 20),
                
                // العنوان
                Text(
                  "تجديد الإعلان",
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                
                SizedBox(height: 8),
                
                // الوصف
                Text(
                  "حدد عدد المشاهدات الجديدة للإعلان",
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 24),
                
                // حقل إدخال العدد
                TextField(
                  controller: viewsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  decoration: InputDecoration(
                    labelText: "عدد المشاهدات",
                    labelStyle: GoogleFonts.cairo(
                      color: Colors.grey.shade600,
                    ),
                    hintText: "مثال: 500",
                    hintStyle: GoogleFonts.cairo(
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(
                      Icons.visibility,
                      color: Color(0xFF2596FA),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color(0xFF2596FA),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 8),
                
                // ملاحظة
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "سيتم إرسال طلب التجديد للمراجعة",
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // الأزرار
                Row(
                  children: [
                    // زر الإلغاء
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(dialogContext),
                            child: Center(
                              child: Text(
                                "إلغاء",
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 12),
                    
                    // زر التأكيد
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF2596FA),
                              Color(0xFF1976D2),
                            ],
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
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              int? views = int.tryParse(viewsController.text);
                              if (views == null || views < 50) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "أقل عدد مشاهدات مسموح به هو 50",
                                      style: GoogleFonts.cairo(),
                                      textDirection: TextDirection.rtl,
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              
                              Navigator.pop(dialogContext);
                              _sendRenewRequest(context, views);
                            },
                            child: Center(
                              child: Text(
                                "إرسال الطلب",
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _sendRenewRequest(BuildContext context, int views) async {
    final cubit = BlocProvider.of<OperationalCubit>(context);
    
    // عرض loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF2596FA),
              ),
              SizedBox(height: 16),
              Text(
                "جاري إرسال الطلب...",
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    final result = await cubit.renewAd(ad.id, views.toString());
    
    Navigator.pop(context); // إغلاق loading
    
    if (result) {
      // نجح
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.green.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green.shade600,
                    size: 40,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "تم إرسال الطلب!",
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "سيتم مراجعة طلب تجديد إعلانك قريباً",
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pop(context);
                        BlocProvider.of<AdCubit>(context).getUserAds();
                      },
                      child: Center(
                        child: Text(
                          "رائع!",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // فشل
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "فشل إرسال الطلب، حاول مرة أخرى",
            style: GoogleFonts.cairo(),
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
