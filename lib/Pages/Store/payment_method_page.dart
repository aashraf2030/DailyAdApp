// import 'dart:io'; // Removed for Web compatibility
import 'package:flutter/foundation.dart';

import 'package:ads_app/API/base.dart';
import 'package:ads_app/Bloc/Store/store_cubit.dart';
import 'package:ads_app/Bloc/Store/store_state.dart';
import 'package:ads_app/Widgets/payment_method_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:ads_app/Bloc/Home/home_cubit.dart';
import 'package:ads_app/Bloc/Ad/ad_cubit.dart';
import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Pages/Store/store_page.dart';
import 'package:ads_app/core/di/service_locator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pay/pay.dart';
import 'package:ads_app/Pages/payment_webview_page.dart';

class PaymentMethodPage extends StatefulWidget {
  final String receiverName;
  final String address;
  final String phone;

  const PaymentMethodPage({
    super.key,
    required this.receiverName,
    required this.address,
    required this.phone,
  });

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String selectedPaymentMethod = 'cash'; // Default to cash
  
  final List<PaymentItem> _paymentItems = [];

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  void _calculateTotal() {
    final cart = context.read<StoreCubit>().cart;
    double total = 0;
    for (var item in cart) {
      total += (double.parse(item['price'].toString()) * item['quantity']);
    }
    
    _paymentItems.add(
      PaymentItem(
        label: 'Total',
        amount: total.toStringAsFixed(2),
        status: PaymentItemStatus.final_price,
      ),
    );
  }

  void onApplePayResult(paymentResult) {
    debugPrint('Apple Pay Result: $paymentResult');
    context.read<StoreCubit>().placeOrder(
      receiverName: widget.receiverName,
      address: widget.address,
      phone: widget.phone,
      paymentMethod: 'apple_pay',
      paymentToken: paymentResult,
    );
  }

  void onGooglePayResult(paymentResult) {
    debugPrint('Google Pay Result: $paymentResult');
    context.read<StoreCubit>().placeOrder(
      receiverName: widget.receiverName,
      address: widget.address,
      phone: widget.phone,
      paymentMethod: 'google_pay',
      paymentToken: paymentResult,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          "طريقة الدفع",
          style: GoogleFonts.cairo(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<StoreCubit, StoreState>(
        listener: (context, state) {
          if (state is StoreOrderSuccess) {
            // Show success dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FontAwesomeIcons.circleCheck,
                        color: Colors.green,
                        size: 60,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "تم الطلب بنجاح!",
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "سيتم التواصل معك قريباً لتأكيد الطلب",
                        style: GoogleFonts.cairo(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "العودة للرئيسية",
                            style: GoogleFonts.cairo(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (state is StoreOrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: GoogleFonts.cairo()),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is StorePaymentRequired) {
            // Navigate to Webview
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<StoreCubit>(),
                  child: PaymentWebviewPage(
                    url: state.paymentUrl,
                    orderId: state.orderId,
                  ),
                ),
              ),
            ).then((success) {
              if (success == true) {
                // Show success dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FontAwesomeIcons.circleCheck,
                            color: Colors.green,
                            size: 60,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "تم عملية الدفع بنجاح!",
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "تم استلام طلبك.",
                            style: GoogleFonts.cairo(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final authCubit = context.read<AuthCubit>();
                                final nav = Navigator.of(context);

                                // Direct navigation to Store, clearing all previous routes
                                nav.pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider(create: (_) => sl<HomeCubit>()),
                                        BlocProvider(create: (_) => sl<AdCubit>()),
                                        BlocProvider(create: (_) => sl<StoreCubit>()),
                                        BlocProvider(create: (_) => sl<OperationalCubit>()),
                                        BlocProvider.value(value: authCubit),
                                      ],
                                      child: StorePage(),
                                    ),
                                  ),
                                  (route) => false, // Remove all previous routes
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "العودة للرئيسية",
                                style: GoogleFonts.cairo(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            });
          } else if (state is StoreApplePayRequired) {
            // Payment initiated successfully, treat as success for now
            // or navigate to a status page if needed.
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FontAwesomeIcons.circleCheck,
                        color: Colors.green,
                        size: 60,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "تم عملية الدفع بنجاح!",
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "تم استلام طلبك وسيتم معالجته.",
                        style: GoogleFonts.cairo(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "العودة للرئيسية",
                            style: GoogleFonts.cairo(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
        child: Column(
          children: [
            // Order Summary Section
            _buildOrderSummary(context),
            
            SizedBox(height: 20),
            
            // Payment Methods Section
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "اختر طريقة الدفع",
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Cash Payment Option
                    PaymentMethodCard(
                      icon: FontAwesomeIcons.moneyBill,
                      title: "الدفع نقداً",
                      description: "ادفع عند استلام الطلب",
                      isSelected: selectedPaymentMethod == 'cash',
                      color: Colors.green.shade100,
                      onTap: () {
                        setState(() {
                          selectedPaymentMethod = 'cash';
                        });
                      },
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Card/Visa Payment (All Platforms)
                    PaymentMethodCard(
                      icon: FontAwesomeIcons.creditCard,
                      title: "بطاقة ائتمان / مدى",
                      description: "ادفع بشكل آمن عبر Visa أو Mastercard",
                      isSelected: selectedPaymentMethod == 'card',
                      color: Color(0xFF2596FA).withOpacity(0.1),
                      onTap: () {
                        setState(() {
                          selectedPaymentMethod = 'card';
                        });
                      },
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Apple Pay (iOS only)
                    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
                      PaymentMethodCard(
                        icon: FontAwesomeIcons.applePay, // Use distinct Apple Pay icon
                        title: "Apple Pay",
                        description: "ادفع بسهولة وأمان",
                        isSelected: selectedPaymentMethod == 'apple_pay',
                        color: Colors.black, // Apple Pay brand color
                        onTap: () {
                          setState(() {
                            selectedPaymentMethod = 'apple_pay';
                          });
                        },
                      ),
                    
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            
            // Confirm/Payment Button Area
            _buildActionArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    final cart = context.read<StoreCubit>().cart;
    double total = 0;
    for (var item in cart) {
      total += (double.parse(item['price'].toString()) * item['quantity']);
    }

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
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
      child: Column(
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.receipt, color: Color(0xFF2596FA), size: 20),
              SizedBox(width: 10),
              Text(
                "ملخص الطلب",
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "عدد المنتجات",
                style: GoogleFonts.cairo(color: Colors.grey.shade700),
              ),
              Text(
                "${cart.length} منتج",
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          
          SizedBox(height: 8),
          Divider(),
          SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "الإجمالي",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$total ريال سعودي",
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2596FA),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionArea(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: Offset(0, -5),
        ),
      ],
    ),
    child: BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        if (state is StoreLoading) {
          return Center(child: CircularProgressIndicator());
        }
        
        // Apple Pay Button (iOS only)
        if (selectedPaymentMethod == 'apple_pay') {
          return Column(
            children: [
              ApplePayButton(
                paymentConfiguration: PaymentConfiguration.fromAsset(
                  'payment_configs/apple_pay_config.json',
                ),
                paymentItems: _paymentItems,
                style: ApplePayButtonStyle.black,
                width: double.infinity,
                height: 55,
                type: ApplePayButtonType.buy,
                onPaymentResult: onApplePayResult,
                loadingIndicator: const Center(
                  child: CircularProgressIndicator(),
                ),
                onError: (e) {
                  // Handle error if button fails to load or payment fails
                  debugPrint("Apple Pay Error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('حدث خطأ في تحميل Apple Pay')),
                  );
                },
              ),
              // Helper text if button doesn't appear
               const SizedBox(height: 8),
               Text(
                 "إذا لم يظهر الزر، تأكد من إعدادات الـ Merchant ID",
                 style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey),
               ),
            ],
          );
        } 
        // Card Payment Button
        else if (selectedPaymentMethod == 'card') {
          return SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                // Place order with card payment
                context.read<StoreCubit>().placeOrder(
                  receiverName: widget.receiverName,
                  address: widget.address,
                  phone: widget.phone,
                  paymentMethod: 'card',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2596FA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.creditCard, size: 20),
                  SizedBox(width: 10),
                  Text(
                    "ادفع ببطاقة الائتمان",
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        // Cash Payment Button
        else {
          return SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                context.read<StoreCubit>().placeOrder(
                  receiverName: widget.receiverName,
                  address: widget.address,
                  phone: widget.phone,
                  paymentMethod: 'cash',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.moneyBill, size: 20),
                  SizedBox(width: 10),
                  Text(
                    "تأكيد الطلب",
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    ),
  );
}
}
