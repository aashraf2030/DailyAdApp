import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pay/pay.dart';
import 'package:flutter/foundation.dart';

import '../Bloc/Store/store_cubit.dart';
import '../Bloc/Store/store_state.dart';
import '../Bloc/Auth/auth_cubit.dart';
import '../Bloc/Home/home_cubit.dart';
import '../Bloc/Ad/ad_cubit.dart';
import '../Bloc/Operational/operational_cubit.dart';
import 'Store/store_page.dart';
import '../core/di/service_locator.dart';
import 'payment_webview_page.dart';
import '../Widgets/custom_apple_pay_icon.dart';

class PaymentMethodSelectionPage extends StatefulWidget {
  final String address;
  final String phone;
  final String receiverName;

  const PaymentMethodSelectionPage({
    Key? key,
    required this.address,
    required this.phone,
    required this.receiverName,
  }) : super(key: key);

  @override
  State<PaymentMethodSelectionPage> createState() => _PaymentMethodSelectionPageState();
}

class _PaymentMethodSelectionPageState extends State<PaymentMethodSelectionPage> {
  String selectedMethod = 'card'; // Default
  
  // Apple Pay Configuration
  final String _paymentConfigurationAsset = 'payment_configs/apple_pay_config.json';
  late Future<PaymentConfiguration> _googlePayConfigFuture;
  
   @override
  void initState() {
    super.initState();
    _googlePayConfigFuture = PaymentConfiguration.fromAsset(_paymentConfigurationAsset);
  }

  void onApplePayResult(paymentResult) {
    debugPrint('Apple Pay Result: $paymentResult');
    // Here we get the token, now we need to send it to our backend
    // Since the original flow was "Confirm Payment" -> "StoreCubit.placeOrder" -> Backend
    // We should call placeOrder with the token.
    
    // Convert result to string if needed or extract token
    // The result is usually a Map.
    String token = jsonEncode(paymentResult);
    
    context.read<StoreCubit>().placeOrder(
      receiverName: widget.receiverName,
      address: widget.address,
      phone: widget.phone,
      paymentMethod: 'apple_pay',
      // We might need to pass the token here if the backend expects it directly
      // But looking at previous code in payment_method_page.dart:
      // context.read<StoreCubit>().placeOrder(..., paymentToken: paymentResult);
      // It seems StoreCubit can handle it.
      // However, looking at the previous file content of payment_selection_page.dart, 
      // placeOrder didn't take a token for 'apple_pay' because it was just selecting the method.
      // But in payment_method_page.dart it DOES take a token.
      // Let's assume placeOrder supports it or we need to update it.
      // Wait, let's check StoreCubit signature if possible, but for now I will pass it as an extra argument 
      // or assume the Cubit handles the "Success" state from Apple Pay.
      
      // Actually, looking at payment_method_page.dart (Step 12), onApplePayResult calls:
      // context.read<StoreCubit>().placeOrder(..., paymentMethod: 'apple_pay', paymentToken: paymentResult);
      // So I should do the same here.
      paymentToken: paymentResult, 
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoreCubit, StoreState>(
      listener: (context, state) {
        if (state is StorePaymentRequired) {
          // Navigate to Webview (For Cards)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentWebviewPage(
                url: state.paymentUrl,
                orderId: state.orderId,
              ),
            ),
          ).then((success) {
            if (success == true) {
              _showSuccessDialog();
            }
          });
        } else if (state is StoreOrderSuccess) {
          // Cash/ApplePay order success - navigate directly to Store
          print("✅ [PAYMENT] Order success - navigating to Store");
          
          try {
            final authCubit = context.read<AuthCubit>();
            final nav = Navigator.of(context);
            
            // Show quick success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("تم تأكيد الطلب بنجاح! رقم الطلب: ${state.data['order_id'] ?? 'N/A'}"),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            
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
          } catch (e) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("حدث خطأ أثناء التنقل: $e"), backgroundColor: Colors.red),
            );
          }
        } else if (state is StoreOrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Select Payment Method")),
        body: SafeArea( // Fix for Guideline 2.1 (Layout Overflow)
          child: SingleChildScrollView( // Fix for Guideline 2.1 (Scrollable)
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPaymentOption(
                  id: 'card', 
                  icon: FontAwesomeIcons.creditCard, 
                  title: 'Credit / Debit Card'
                ),
                const SizedBox(height: 15),
                _buildPaymentOption(
                  id: 'cash', 
                  icon: FontAwesomeIcons.moneyBillWave, 
                  title: 'Cash on Delivery'
                ),
                const SizedBox(height: 15),
                
                // Apple Pay Selection
                if (true) ...[ // Temporarily showing on all platforms for preview (was: defaultTargetPlatform == TargetPlatform.iOS)
                   _buildPaymentOption(
                    id: 'apple_pay', 
                    icon: FontAwesomeIcons.apple, 
                    title: 'Apple Pay',
                    customIcon: const CustomApplePayIcon(height: 28),
                  ),
                   const SizedBox(height: 30),
                ],
                
                const SizedBox(height: 40), // Spacer replaced with SizedBox for SingleChildScrollView
                
                BlocBuilder<StoreCubit, StoreState>(
                  builder: (context, state) {
                    if (state is StoreLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    // NEW LOGIC: Swap button based on selection (Guideline 4.9)
                    if (selectedMethod == 'apple_pay') {
                      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
                        return FutureBuilder<PaymentConfiguration>(
                          future: _googlePayConfigFuture,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ApplePayButton(
                                paymentConfiguration: snapshot.data!,
                                paymentItems: [
                                  PaymentItem(
                                    label: 'Total',
                                    amount: '1.00',
                                    status: PaymentItemStatus.final_price,
                                  )
                                ],
                                style: ApplePayButtonStyle.black,
                                type: ApplePayButtonType.buy,
                                width: double.infinity,
                                height: 50,
                                onPaymentResult: onApplePayResult,
                                loadingIndicator: const Center(child: CircularProgressIndicator()),
                                onError: (e) {
                                  debugPrint("Apple Pay Error: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Error loading Apple Pay')),
                                  );
                                },
                              );
                            }
                            return const Center(child: CircularProgressIndicator());
                          }
                        );
                      } else {
                        // Fake Apple Pay button for web/desktop preview
                        return Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.apple, color: Colors.white, size: 22),
                              SizedBox(width: 8),
                              Text("Pay", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }
                    }

                    // Default Confirm Button for Cash/Card
                    return ElevatedButton(
                      onPressed: () {
                        context.read<StoreCubit>().placeOrder(
                          address: widget.address,
                          phone: widget.phone,
                          receiverName: widget.receiverName,
                          paymentMethod: selectedMethod,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: Text(
                        "Confirm Payment",
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({required String id, required IconData icon, required String title, Widget? customIcon}) {
    final isSelected = selectedMethod == id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (customIcon != null)
              customIcon
            else
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueAccent.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey, size: 28),
              ),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blueAccent : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected) 
              const Icon(FontAwesomeIcons.circleCheck, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Text(
          "Order Placed Successfully!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final authCubit = context.read<AuthCubit>();
              final nav = Navigator.of(context);
              nav.pop(); // Close dialog
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
            child: const Text("Done"),
          )
        ],
      ),
    );
  }
}
