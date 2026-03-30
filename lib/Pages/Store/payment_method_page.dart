
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
import '../../Widgets/custom_apple_pay_icon.dart';
import 'package:ads_app/Pages/Store/store_page.dart';
import 'package:ads_app/core/di/service_locator.dart';
import 'package:ads_app/core/widgets/login_required_dialog.dart';
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
  String selectedPaymentMethod = 'cash'; 
  late Future<PaymentConfiguration> _applePayConfigFuture;
  bool _applePayAvailable = false;
  
  final List<PaymentItem> _paymentItems = [];

  @override
  void initState() {
    super.initState();
    _calculateTotal();
    _applePayConfigFuture = PaymentConfiguration.fromAsset(
      'payment_configs/apple_pay_config.json',
    );
    _checkApplePayAvailability();
  }

  Future<void> _checkApplePayAvailability() async {
    
    if (mounted) setState(() => _applePayAvailable = true);
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
    if (context.read<AuthCubit>().isGuestMode()) {
      showLoginRequiredDialog(
        context,
        actionName: "إتمام الطلب",
      );
      return;
    }

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
    if (context.read<AuthCubit>().isGuestMode()) {
      showLoginRequiredDialog(
        context,
        actionName: "إتمام الطلب",
      );
      return;
    }

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
                                  (route) => false, 
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
        child: SafeArea(
          child: Column(
            children: [
              
              _buildOrderSummary(context),
              
              SizedBox(height: 20),
              
              
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
                      
                      
                      PaymentMethodCard(
                        icon: FontAwesomeIcons.moneyBillWave,
                        title: "الدفع نقداً",
                        description: "ادفع عند استلام الطلب",
                        isSelected: selectedPaymentMethod == 'cash',
                        color: Colors.green,
                        onTap: () {
                          setState(() {
                            selectedPaymentMethod = 'cash';
                          });
                        },
                      ),
                      
                      SizedBox(height: 16),
                      
                      
                      PaymentMethodCard(
                        icon: FontAwesomeIcons.creditCard,
                        title: "بطاقة ائتمان / مدى",
                        description: "ادفع بشكل آمن عبر Visa أو Mastercard",
                        isSelected: selectedPaymentMethod == 'card',
                        color: Color(0xFF2596FA),
                        onTap: () {
                          setState(() {
                            selectedPaymentMethod = 'card';
                          });
                        },
                      ),
                      
                      SizedBox(height: 16),
                      
                      
                      if (_applePayAvailable) ...[
                        SizedBox(height: 24),
                        _buildDividerWithOr(),
                        SizedBox(height: 24),
                        FutureBuilder<PaymentConfiguration>(
                          future: _applePayConfigFuture,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return kIsWeb || defaultTargetPlatform != TargetPlatform.iOS
                                ? Container(
                                    width: double.infinity,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(4),
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
                                  debugPrint("Apple Pay Error: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('عفواً، لا يمكن إتمام الدفع عبر Apple Pay على هذا الجهاز.', style: GoogleFonts.cairo())),
                                  );
                                },
                              );
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error loading Apple Pay config'));
                            }
                            return Center(child: CircularProgressIndicator());
                          }
                        ),
                      ],
                      
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              
              
              _buildActionArea(context),
            ],
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
        
        
        if (selectedPaymentMethod == 'apple_pay') {
           return const SizedBox.shrink(); 
        } 
        
        else if (selectedPaymentMethod == 'card') {
          return SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                if (context.read<AuthCubit>().isGuestMode()) {
                  showLoginRequiredDialog(
                    context,
                    actionName: "الدفع ببطاقة الائتمان",
                  );
                  return;
                }

                
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
        
        else {
          return SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                if (context.read<AuthCubit>().isGuestMode()) {
                  showLoginRequiredDialog(
                    context,
                    actionName: "تأكيد الطلب",
                  );
                  return;
                }

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
