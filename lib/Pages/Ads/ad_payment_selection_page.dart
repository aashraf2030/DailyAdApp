import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Pages/Ads/ad_payment_webview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pay/pay.dart';

class AdPaymentSelectionPage extends StatefulWidget {
  final String name;
  final String imagePath;
  final String imageName;
  final String adLink;
  final String type;
  final int targetViews;
  final int category;
  final String keywords;

  const AdPaymentSelectionPage({
    super.key,
    required this.name,
    required this.imagePath,
    required this.imageName,
    required this.adLink,
    required this.type,
    required this.targetViews,
    required this.category,
    required this.keywords,
  });

  @override
  State<AdPaymentSelectionPage> createState() => _AdPaymentSelectionPageState();
}

class _AdPaymentSelectionPageState extends State<AdPaymentSelectionPage> {
  int _selectedMethod = 0; // 0: None, 1: Cash, 2: Card, 3: Apple Pay
  final double _pricePerView = 1.0; // 1 SAR per view (config match)

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.targetViews * _pricePerView;

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "الدفع وتأكيد الإعلان",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2596FA), Color(0xFF364A62)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<OperationalCubit, OperationalState>(
        listener: (context, state) {
          if (state is AdPaymentLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(child: CircularProgressIndicator()),
            );
          } else if (state is AdPaymentSuccess) {
            Navigator.popUntil(context, (route) => route.isFirst); // Clear dialogs
            // Show Success Dialog
             showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FontAwesomeIcons.circleCheck, color: Colors.green, size: 50),
                      SizedBox(height: 20),
                      Text(state.message, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                           Navigator.pop(context); // Close Payment Page
                           Navigator.pop(context); // Close Create Ad Page (handled by navigation stack usually)
                           Navigator.pushReplacementNamed(context, "/home");
                        },
                        child: Text("حسناً"),
                      )
                    ],
                  ),
                ),
              ),
            );
          } else if (state is AdPaymentRequired) {
            Navigator.pop(context); // Close loading
            // Navigate to WebView
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdPaymentWebViewPage(
                  url: state.paymentUrl,
                  orderId: state.orderId,
                  onSuccess: () {
                     // Payment Success from webview
                     Navigator.pop(context); // Close webview
                     // Verification is handled inside page or here?
                     // Verify again just in case or trust the callback?
                     // AdPaymentWebViewPage calls onSuccess when verifyAdPayment emits Success.
                     // So we don't need to do anything here except maybe nothing because the listener above (AdPaymentSuccess) will fire globally?
                     // Yes, OperationalCubit is global (or scoped above). AdPaymentWebViewPage uses the SAME cubit instance.
                     // So when verifyAdPayment emits AdPaymentSuccess, THIS listener will catch it too!
                  },
                  onFailure: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل الدفع")));
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          } else if (state is AdApplePayRequired) {
             Navigator.pop(context); // Close loading
             
             // Trigger Apple Pay Sheet
             final payClient = Pay.withAssets(['payment_configs/apple_pay_config.json']);
             final paymentItems = [
               PaymentItem(
                 label: 'Ad Payment',
                 amount: state.amount.toStringAsFixed(2),
                 status: PaymentItemStatus.final_price,
               )
             ];
             
             try {
               payClient.showPaymentSelector(
                 PayProvider.apple_pay,
                 paymentItems,
               ).then((result) {
                  // User authorized payment
                  final String tokenString = jsonEncode(result);
                  
                  // Call Cubit to confirm payment with backend
                  final cubit = BlocProvider.of<OperationalCubit>(context);
                  cubit.confirmAdApplePay(state.paymentId, tokenString);
                  
               }).catchError((e) {
                  print("Apple Pay Error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم إلغاء الدفع أو فشل العملية")));
               });
             } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل في تهيئة Apple Pay")));
             }

          } else if (state is AdPaymentFailure) {
            Navigator.pop(context); // Close loading
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          } else if (state is DoneOperational) {
             // For Cash flow (old flow)
             Navigator.popUntil(context, (route) => route.isFirst);
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم إنشاء الإعلان بنجاح")));
             Navigator.pushReplacementNamed(context, "/home");
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Card
              _buildSummaryCard(totalPrice),
              
              SizedBox(height: 24),
              
              Text(
                "طريقة الدفع",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF364A62),
                ),
                textAlign: TextAlign.end,
              ),
              
              SizedBox(height: 12),
              
              // Payment Methods
              _buildPaymentOption(
                index: 1,
                title: "دفع نقدي (عند التفعيل)",
                icon: FontAwesomeIcons.moneyBillWave,
                color: Colors.green,
              ),
              
              SizedBox(height: 12),
              
              _buildPaymentOption(
                index: 2,
                title: "بطاقة ائتمان / مدى",
                icon: FontAwesomeIcons.creditCard,
                color: Color(0xFF2596FA),
              ),
              
              if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                SizedBox(height: 12),
                _buildPaymentOption(
                  index: 3,
                  title: "Apple Pay",
                  icon: FontAwesomeIcons.apple,
                  color: Colors.black,
                ),
              ],
              
              SizedBox(height: 40),
              
              // Pay Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: _selectedMethod != 0 
                        ? [Color(0xFF2596FA), Color(0xFF364A62)]
                        : [Colors.grey, Colors.grey.shade600],
                  ),
                  boxShadow: _selectedMethod != 0 
                      ? [BoxShadow(color: Color(0xFF2596FA).withOpacity(0.4), blurRadius: 15, offset: Offset(0, 8))]
                      : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _selectedMethod != 0 ? _submitPayment : null,
                    child: Center(
                      child: Text(
                        _selectedMethod == 1 ? "تأكيد الإعلان" : "دفع ${totalPrice.toStringAsFixed(2)} ر.س",
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 18,
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
  }

  Widget _buildSummaryCard(double totalPrice) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                 "${widget.targetViews}",
                 style: GoogleFonts.cairo(
                   fontSize: 20, 
                   fontWeight: FontWeight.bold, 
                   color: Color(0xFF364A62)
                 )
               ),
               Text(
                 "عدد المشاهدات",
                 style: GoogleFonts.cairo(color: Colors.grey.shade600)
               ),
            ],
          ),
          Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                 "${totalPrice.toStringAsFixed(2)} ر.س",
                 style: GoogleFonts.cairo(
                   fontSize: 24, 
                   fontWeight: FontWeight.bold, 
                   color: Color(0xFF2596FA)
                 )
               ),
               Text(
                 "الإجمالي",
                 style: GoogleFonts.cairo(color: Colors.grey.shade600, fontWeight: FontWeight.bold)
               ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required int index,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    bool isSelected = _selectedMethod == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(0xFF2596FA) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
             if (isSelected)
               Icon(Icons.check_circle, color: Color(0xFF2596FA))
             else
               Icon(Icons.circle_outlined, color: Colors.grey.shade400),
             
             Spacer(),
             
             Text(
               title,
               style: GoogleFonts.cairo(
                 fontSize: 16,
                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                 color: Color(0xFF364A62),
               ),
             ),
             
             SizedBox(width: 16),
             
             Container(
               padding: EdgeInsets.all(8),
               decoration: BoxDecoration(
                 color: color.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(8),
               ),
               child: Icon(icon, color: color, size: 20),
             ),
          ],
        ),
      ),
    );
  }

  void _submitPayment() {
    final cubit = BlocProvider.of<OperationalCubit>(context);
    
    if (_selectedMethod == 1) {
      // Cash - Use Old Method
      String adType = "Dynamic";
      if (widget.type == "1") {
        adType = "Fixed";
      } else if (widget.type == "2") {
        adType = "Premium";
      } else {
         adType = widget.type; // Passthrough if already string
      }
      
      cubit.createNewAd(
        widget.name,
        widget.imagePath,
        widget.imageName,
        widget.adLink,
        adType,
        widget.targetViews,
        widget.category,
        widget.keywords,
      );
    } else {
      // Card Or Apple Pay
      String method = "card";
      if (_selectedMethod == 3) method = "apple_pay";
      
      String platform = "web";
      if (!kIsWeb) {
         if (defaultTargetPlatform == TargetPlatform.iOS) platform = "ios";
         if (defaultTargetPlatform == TargetPlatform.android) platform = "android";
      }
      
      cubit.initializeAdPayment(
        name: widget.name,
        imagePath: widget.imagePath,
        imageName: widget.imageName,
        adLink: widget.adLink,
        type: widget.type,
        targetViews: widget.targetViews,
        category: widget.category,
        keywords: widget.keywords,
        paymentMethod: method,
        platform: platform,
      );
    }
  }
}
