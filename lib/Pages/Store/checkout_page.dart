import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:ads_app/Bloc/Store/store_cubit.dart';
import 'package:ads_app/Pages/Store/payment_method_page.dart';
import 'package:ads_app/Widgets/login_textbox.dart';
import 'package:ads_app/core/widgets/login_required_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutPage extends StatelessWidget {
  CheckoutPage({super.key});

  final address = LoginTextbox(padding: 10, icon: Icons.location_on, hint: "عنوان التوصيل بالتفصيل...");
  final phone = LoginTextbox(padding: 10, icon: Icons.phone, hint: "رقم هاتف إضافي...");
  final receiver = LoginTextbox(padding: 10, icon: Icons.person, hint: "اسم المستلم...");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          "بيانات التوصيل",
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF2596FA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFF2596FA).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF2596FA)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "يرجى ملء بيانات التوصيل بدقة لضمان وصول طلبك",
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Color(0xFF2596FA),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            Text(
              "معلومات المستلم",
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            
            receiver,
            SizedBox(height: 15),
            
            Text(
              "عنوان التوصيل",
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            
            address,
            SizedBox(height: 15),
            
            Text(
              "رقم الهاتف",
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            
            phone,
            SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  if (context.read<AuthCubit>().isGuestMode()) {
                    await showLoginRequiredDialog(
                      context,
                      actionName: "متابعة إتمام الشراء",
                    );
                    return;
                  }
                  
                  if (receiver.data.isEmpty || address.data.isEmpty || phone.data.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("يرجى ملء جميع البيانات", style: GoogleFonts.cairo()),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: context.read<StoreCubit>()),
                          BlocProvider.value(value: context.read<AuthCubit>()),
                        ],
                        child: PaymentMethodPage(
                          receiverName: receiver.data,
                          address: address.data,
                          phone: phone.data,
                        ),
                      ),
                    ),
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
                    Text(
                      "التالي - اختيار طريقة الدفع",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
