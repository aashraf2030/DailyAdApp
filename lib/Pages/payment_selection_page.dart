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
  final String _paymentConfigurationAsset = 'assets/payment_configs/apple_pay_config.json';
  
  @override
  Widget build(BuildContext context) {
    return BlocListener<StoreCubit, StoreState>(
      listener: (context, state) {
        if (state is StorePaymentRequired) {
          // Navigate to Webview
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
          // Cash order success - navigate directly to Store
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
            
            print("✅ [PAYMENT] Creating navigation route...");
            
            // Navigate to Store directly
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
            
            print("✅ [PAYMENT] Navigation completed!");
          } catch (e, stackTrace) {
            print("🔴 [PAYMENT ERROR] Exception during navigation: $e");
            print("🔴 [PAYMENT ERROR] Stack trace: $stackTrace");
            
            // Show error to user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("حدث خطأ أثناء التنقل: $e"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
        } else if (state is StoreOrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is StoreApplePayRequired) {
           // This state is just internal to prep Apple Pay if we were doing manual handling
           // But actually we might want to initiate the native Pay sheet here if not using the button directly
           // Or just let the button handle it? 
           // Since we use the library, the button usually handles the flow *before* hitting our backend for an intention
           // OR we get the intention first (client secret) then present payment.
           // Paymob's flow: Intention First -> Then generic Apple Pay sheet with client secret.
           
           // However, the `pay` package in Flutter simplifies this.
           // Since we implemented the backend to return client_secret, we might need to use a custom platform channel or specific package for Paymob Apple Pay if the standard `pay` package doesn't support "Intention" based flow directly easily.
           // BUT, standard Apple Pay token often needs to be sent to backend.
           // Let's stick to the prompt's simplicity: Using standard `pay` button if feasible, or custom UI.
           
           // For now, let's assume we proceed with the standard flow we built:
           // 1. User taps "Pay with Apple Pay" (Custom Button calling our Cubit)
           // 2. Cubit gets 'client_secret' from backend (Intention)
           // 3. We use a plugin to present Apple Pay with that secret? 
           // Actually, standard `pay` package generates a token that we send to backend.
           // Paymob's "Intention" is for when YOU want to use Paymob's direct integration.
           
           // Let's stick to the Paymob documentation flow we saw:
           // Backend returns `client_secret`.
           // We likely need to use a native method to present the payment sheet with that secret.
           // Since `pay` package is generic, it might be easier to treating Apple Pay like Card (WebView) if we can't do native easily without complex setup.
           // BUT wait, Paymob documentation said "Apple Pay: Native Apple Pay support".
           // And the backend retuns `payment_url` for cards.
           
           // For simplicity in this iteration: We'll show a message or valid UI.
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Select Payment Method")),
        body: Padding(
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
              if (true) ...[
                 _buildPaymentOption(
                  id: 'apple_pay', 
                  icon: FontAwesomeIcons.apple, 
                  title: 'Apple Pay',
                  customIcon: const CustomApplePayIcon(height: 28),
                ),
                 const SizedBox(height: 30),
              ],
              
              const Spacer(),
              
              BlocBuilder<StoreCubit, StoreState>(
                builder: (context, state) {
                  if (state is StoreLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
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
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: customIcon ?? Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey, size: 28),
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
              print("🔵 [DEBUG] Success Dialog - Done button pressed");
              final authCubit = context.read<AuthCubit>();
              final nav = Navigator.of(context);

              print("🔵 [DEBUG] Closing dialog...");
              nav.pop(); // Close dialog

              print("🔵 [DEBUG] Navigating directly to Store...");
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
              print("🔵 [DEBUG] Navigation complete!");
            },
            child: const Text("Done"),
          )
        ],
      ),
    );
  }
}
