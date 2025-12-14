import 'package:ads_app/API/base.dart';
import 'package:ads_app/Bloc/Store/store_cubit.dart';
import 'package:ads_app/Bloc/Store/store_state.dart';
import 'package:ads_app/Widgets/payment_method_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
                    
                    // Apple Pay Option (Placeholder for future implementation)
                    PaymentMethodCard(
                      icon: FontAwesomeIcons.applePay,
                      title: "Apple Pay",
                      description: "ادفع بشكل آمن عبر Apple Pay",
                      isSelected: selectedPaymentMethod == 'apple_pay',
                      color: Colors.black87,
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
            
            // Confirm Button
            _buildConfirmButton(context),
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
                "$total EGP",
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

  Widget _buildConfirmButton(BuildContext context) {
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
          
          return SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => _handlePayment(context),
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
                  if (selectedPaymentMethod == 'cash')
                    Icon(FontAwesomeIcons.moneyBill, size: 20)
                  else
                    Icon(FontAwesomeIcons.applePay, size: 20),
                  SizedBox(width: 10),
                  Text(
                    selectedPaymentMethod == 'cash' 
                        ? "تأكيد الطلب" 
                        : "الدفع عبر Apple Pay",
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
        },
      ),
    );
  }

  void _handlePayment(BuildContext context) {
    if (selectedPaymentMethod == 'cash') {
      // Handle cash payment
      context.read<StoreCubit>().placeOrder(
            receiverName: widget.receiverName,
            address: widget.address,
            phone: widget.phone,
            paymentMethod: 'cash',
          );
    } else if (selectedPaymentMethod == 'apple_pay') {
      // TODO: Handle Apple Pay integration
      // For now, show a message that it's coming soon
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Apple Pay سيكون متاحاً قريباً",
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
