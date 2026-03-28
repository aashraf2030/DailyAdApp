import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Pages/Ads/ad_payment_webview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pay/pay.dart';
import 'package:ads_app/core/ad_pricing_config.dart';
import '../../Widgets/custom_apple_pay_icon.dart';

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
  int _selectedMethod = 0; 
  
  
  final TextEditingController _couponController = TextEditingController();
  String? _appliedCouponCode;
  double? _discountAmount;
  double? _finalPrice; 

  
  late Future<PaymentConfiguration> _paymentConfigFuture;
  String? _pendingApplePayToken;
  bool _applePayAvailable = false;

  @override
  void initState() {
    super.initState();
    _paymentConfigFuture = PaymentConfiguration.fromAsset('payment_configs/apple_pay_config.json');
    _checkApplePayAvailability();
  }

  Future<void> _checkApplePayAvailability() async {
    
    if (mounted) {
      setState(() {
        _applePayAvailable = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    double originalPrice = AdPricingConfig.calculatePrice(widget.targetViews);
    double totalPrice = _finalPrice ?? originalPrice;

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
        listener: (context, state) async {
          if (state is AdPaymentLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(child: CircularProgressIndicator()),
            );
          } else if (state is AdPaymentSuccess) {
            Navigator.popUntil(context, (route) => route.isFirst); 
            
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
                          Navigator.pop(context); 
                           Navigator.pop(context); 
                           Navigator.pop(context); 
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
            Navigator.pop(context); 
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (newContext) => BlocProvider.value(
                  value: context.read<OperationalCubit>(),
                  child: AdPaymentWebViewPage(
                    url: state.paymentUrl,
                    orderId: state.orderId,
                    onSuccess: () {
                     
                     Navigator.pop(context); 
                     
                     
                     
                     
                     
                     
                    },
                    onFailure: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل الدفع")));
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            );
          } else if (state is AdApplePayRequired) {
             Navigator.pop(context); 
             
             if (_pendingApplePayToken != null) {
                
                final cubit = BlocProvider.of<OperationalCubit>(context);
                cubit.confirmAdApplePay(state.paymentId, _pendingApplePayToken!);
                _pendingApplePayToken = null; 
             } else {
                
                try {
                  final config = await PaymentConfiguration.fromAsset('payment_configs/apple_pay_config.json');
                  final payClient = Pay({PayProvider.apple_pay: config});
   
                  final paymentItems = [
                    PaymentItem(
                      label: 'Ad Payment',
                      amount: state.amount.toStringAsFixed(2),
                      status: PaymentItemStatus.final_price,
                    )
                  ];
                
                  if (context.mounted) {
                    payClient.showPaymentSelector(
                      PayProvider.apple_pay,
                      paymentItems,
                    ).then((result) {
                       if (!context.mounted) return;
                       final String tokenString = jsonEncode(result);
                       final cubit = BlocProvider.of<OperationalCubit>(context);
                       cubit.confirmAdApplePay(state.paymentId, tokenString);
                       
                    }).catchError((e) {
                       debugPrint("Apple Pay Error: $e");
                       if (context.mounted) _showErrorDialog(context, e);
                    });
                  }
                } catch (e) {
                   debugPrint("Pay Init Error: $e");
                   if (context.mounted) _showErrorDialog(context, e);
                }
             }

          } else if (state is AdPaymentFailure) {
            Navigator.pop(context); 
            _showErrorDialog(context, state.error);
          } else if (state is DoneOperational) {
             
             Navigator.popUntil(context, (route) => route.isFirst);
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم إنشاء الإعلان بنجاح")));
             Navigator.pushReplacementNamed(context, "/home");

          
          } else if (state is AdCouponLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => Center(child: CircularProgressIndicator()),
            );
          } else if (state is AdCouponValid) {
             Navigator.pop(context); 
             setState(() {
               _appliedCouponCode = state.code;
               _discountAmount = state.discountAmount;
               _finalPrice = state.newTotal;
             });
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text("تم تفعيل الكود بنجاح")));
          } else if (state is AdCouponInvalid) {
             Navigator.pop(context); 
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(state.error)));
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                _buildSummaryCard(originalPrice),
                
                SizedBox(height: 24),
                
                
                _buildCouponSection(originalPrice),
                
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
                
                if (_applePayAvailable) ...[
                  SizedBox(height: 24),
                  _buildDividerWithOr(),
                  SizedBox(height: 24),
                  FutureBuilder<PaymentConfiguration>(
                    future: _paymentConfigFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return kIsWeb || defaultTargetPlatform != TargetPlatform.iOS
                          ? Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(FontAwesomeIcons.apple, color: Colors.white, size: 20),
                                    SizedBox(width: 4),
                                    Text(
                                      "Pay",
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ApplePayButton(
                          paymentConfiguration: snapshot.data!,
                          paymentItems: [
                            PaymentItem(
                              label: 'Ad Payment',
                              amount: totalPrice.toStringAsFixed(2),
                              status: PaymentItemStatus.final_price,
                            )
                          ],
                          style: ApplePayButtonStyle.black,
                          type: ApplePayButtonType.buy,
                          width: double.infinity,
                          height: 56,
                          cornerRadius: 16,
                          onPaymentResult: (result) {
                            
                            setState(() {
                              _pendingApplePayToken = jsonEncode(result);
                            });
                            
                            _submitApplePay(totalPrice); 
                          },
                          loadingIndicator: const Center(child: CircularProgressIndicator()),
                          onError: (e) {
                            debugPrint("Apple Pay Error: $e");
                          },
                        );
                      }
                      return const SizedBox(
                        height: 56, 
                        child: Center(child: CircularProgressIndicator())
                      );
                    }
                  ),
                ],
                
                SizedBox(height: 40),
                
                SizedBox(height: 40),
                
                
                if (_selectedMethod != 0 && _selectedMethod != 3)
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Color(0xFF2596FA), Color(0xFF364A62)],
                      ),
                      boxShadow: [BoxShadow(color: Color(0xFF2596FA).withOpacity(0.4), blurRadius: 15, offset: Offset(0, 8))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _submitPayment(totalPrice),
                        child: Center(
                          child: Text(
                            _selectedMethod == 1 ? "تأكيد الإعلان" : "دفع ${totalPrice.toStringAsFixed(2)} ريال سعودي",
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
        ),
    );
  }

  Widget _buildDividerWithOr() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "أو",
            style: GoogleFonts.cairo(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
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
               if (_discountAmount != null && _discountAmount! > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       Text(
                         "${totalPrice.toStringAsFixed(2)} ريال سعودي",
                         style: GoogleFonts.cairo(
                           fontSize: 14, 
                           decoration: TextDecoration.lineThrough,
                           color: Colors.grey
                         )
                       ),
                       Text(
                         "${(_finalPrice ?? totalPrice).toStringAsFixed(2)} ريال سعودي",
                         style: GoogleFonts.cairo(
                           fontSize: 24, 
                           fontWeight: FontWeight.bold, 
                           color: Color(0xFF2596FA)
                         )
                       ),
                    ],
                  )
               else
                 Text(
                   "${totalPrice.toStringAsFixed(2)} ريال سعودي",
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
    bool isApplePay = index == 3;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2596FA).withOpacity(0.1) : Colors.white,
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

             if (isApplePay) ...[
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Apple Pay",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF364A62),
                      ),
                    ),
                    Text(
                      "ادفع بسهولة وأمان",
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(width: 12),
                
                
                SizedBox(
                  height: 32,
                  child: (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
                    ? RawApplePayButton(
                        style: ApplePayButtonStyle.black,
                        type: ApplePayButtonType.plain,
                        onPressed: () {},
                      )
                    : Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade400, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FontAwesomeIcons.apple, size: 16, color: Colors.black),
                            SizedBox(width: 4),
                            Text("Pay", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                          ],
                        ),
                      ),
                ),

             ] else ...[
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
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection(double originalPrice) {
    if (_appliedCouponCode != null) {
      return Container(
         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
         decoration: BoxDecoration(
           color: Colors.green.withOpacity(0.1),
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: Colors.green),
         ),
         child: Row(
           children: [
             Icon(Icons.local_offer, color: Colors.green),
             SizedBox(width: 12),
             Expanded(child: Text("تم استخدام كوبون: $_appliedCouponCode\nوفرت ${_discountAmount?.toStringAsFixed(2)} ريال سعودي", style: GoogleFonts.cairo(color: Colors.green[800], fontWeight: FontWeight.bold))),
             IconButton(
               icon: Icon(Icons.close, color: Colors.red),
               onPressed: () {
                 setState(() {
                   _appliedCouponCode = null;
                   _discountAmount = null;
                   _finalPrice = null;
                 });
               },
             )
           ],
         ),
      );
    }
    
    return Row(
      children: [
        Expanded(
          child: TextFormField(
             controller: _couponController,
             decoration: InputDecoration(
               hintText: "كود الخصم",
               hintStyle: GoogleFonts.cairo(),
               prefixIcon: Icon(Icons.discount_outlined),
               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
             ),
          ),
        ),
        SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            if (_couponController.text.isEmpty) return;
            context.read<OperationalCubit>().validateCoupon(_couponController.text, originalPrice);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF364A62),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          child: Text("تطبيق", style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  void _showErrorDialog(BuildContext context, dynamic error) {
    if (error is PlatformException && 
        (error.code == 'paymentCanceled' || error.code.toLowerCase().contains('cancel'))) {
      return;
    }

    String title = "تنبيه الدفع";
    String content = "تعذر إتمام العملية";

    if (error is PlatformException) {
       content = "عفواً، لم نتمكن من إكمال الدفع عبر Apple Pay. يرجى التأكد من إعدادات الدفع في جهازك والمحاولة لاحقاً.";
    } else {
      content = "حدث خطأ أثناء معالجة الدفع: ${error.toString()}";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.orange)),
        content: SingleChildScrollView(
          child: SelectableText(
            content,
            style: GoogleFonts.cairo(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("حسناً", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _submitApplePay(double totalPrice) {
    final cubit = BlocProvider.of<OperationalCubit>(context);
    
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
      paymentMethod: "apple_pay",
      platform: platform,
      couponCode: _appliedCouponCode,
    );
  }

  void _submitPayment(double currentTotal) {
    
    final cubit = BlocProvider.of<OperationalCubit>(context);
    
    if (_selectedMethod == 1) {
      
      String adType = "Dynamic";
      if (widget.type == "1") {
        adType = "Fixed";
      } else if (widget.type == "2") {
        adType = "Premium";
      } else {
         adType = widget.type; 
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
    } else if (_selectedMethod == 2) {
      
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
        paymentMethod: "card",
        platform: platform,
        couponCode: _appliedCouponCode,
      );
    }
  }
}
