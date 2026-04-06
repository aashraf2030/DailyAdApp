import 'package:flutter/foundation.dart';
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

  static PaymentConfiguration? _cachedConfig;
  static bool? _cachedCanPay;

  static Future<void> preload() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
    if (_cachedConfig != null) return;
    try {
      final config = await PaymentConfiguration.fromAsset(
        'payment_configs/apple_pay_config.json',
      );
      final canPay = await Pay({PayProvider.apple_pay: config})
          .userCanPay(PayProvider.apple_pay);
      _cachedConfig = config;
      _cachedCanPay = canPay;
    } catch (e) {
      debugPrint('Apple Pay preload failed: $e');
      _cachedCanPay = false;
    }
  }

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String selectedPaymentMethod = 'cash';
  final List<PaymentItem> _paymentItems = [];

  bool get _applePayChecked => PaymentMethodPage._cachedCanPay != null;
  bool get _applePayAvailable => PaymentMethodPage._cachedCanPay ?? false;
  PaymentConfiguration? get _applePayConfig => PaymentMethodPage._cachedConfig;

  @override
  void initState() {
    super.initState();
    _calculateTotal();
    if (!_applePayChecked && !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      PaymentMethodPage.preload().then((_) {
        if (mounted) setState(() {});
      });
    }
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
      showLoginRequiredDialog(context, actionName: 'إتمام الطلب');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'طريقة الدفع',
          style: GoogleFonts.cairo(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<StoreCubit, StoreState>(
        listener: (context, state) {
          if (state is StoreOrderSuccess) {
            _showSuccessDialog(
              context,
              title: 'تم الطلب بنجاح!',
              subtitle: 'سيتم التواصل معك قريباً لتأكيد الطلب',
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
                _showSuccessDialog(
                  context,
                  title: 'تم عملية الدفع بنجاح!',
                  subtitle: 'تم استلام طلبك.',
                  goToStore: true,
                );
              }
            });
          } else if (state is StoreApplePayRequired) {
            _showSuccessDialog(
              context,
              title: 'تم عملية الدفع بنجاح!',
              subtitle: 'تم استلام طلبك وسيتم معالجته.',
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              _buildOrderSummary(context),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختر طريقة الدفع',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      PaymentMethodCard(
                        icon: FontAwesomeIcons.moneyBillWave,
                        title: 'الدفع نقداً',
                        description: 'ادفع عند استلام الطلب',
                        isSelected: selectedPaymentMethod == 'cash',
                        color: Colors.green,
                        onTap: () => setState(() => selectedPaymentMethod = 'cash'),
                      ),
                      const SizedBox(height: 16),

                      PaymentMethodCard(
                        icon: FontAwesomeIcons.creditCard,
                        title: 'بطاقة ائتمان / مدى',
                        description: 'ادفع بشكل آمن عبر Visa أو Mastercard',
                        isSelected: selectedPaymentMethod == 'card',
                        color: const Color(0xFF2596FA),
                        onTap: () => setState(() => selectedPaymentMethod = 'card'),
                      ),

                      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'أو',
                                style: GoogleFonts.cairo(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (!_applePayChecked)
                          Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          )
                        else if (_applePayAvailable && _applePayConfig != null)
                          ApplePayButton(
                            paymentConfiguration: _applePayConfig!,
                            paymentItems: _paymentItems,
                            style: ApplePayButtonStyle.black,
                            width: double.infinity,
                            height: 55,
                            cornerRadius: 8,
                            type: ApplePayButtonType.buy,
                            onPaymentResult: onApplePayResult,
                            loadingIndicator: const Center(
                              child: CircularProgressIndicator(),
                            ),
                            onError: (e) {
                              debugPrint('Apple Pay Error: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'حدث خطأ أثناء الدفع عبر Apple Pay.',
                                    style: GoogleFonts.cairo(),
                                  ),
                                ),
                              );
                            },
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.orange.shade700,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Apple Pay غير متاح',
                                        textDirection: TextDirection.rtl,
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'جهازك لا يدعم Apple Pay أو لم تُضف بطاقة في تطبيق Wallet بعد.',
                                        textDirection: TextDirection.rtl,
                                        style: GoogleFonts.cairo(
                                          color: Colors.orange.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],

                      const SizedBox(height: 30),
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

  Widget _buildOrderSummary(BuildContext context) {
    final cart = context.read<StoreCubit>().cart;
    double total = 0;
    for (var item in cart) {
      total += (double.parse(item['price'].toString()) * item['quantity']);
    }
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(FontAwesomeIcons.receipt, color: Color(0xFF2596FA), size: 20),
              const SizedBox(width: 10),
              Text(
                'ملخص الطلب',
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('عدد المنتجات', style: GoogleFonts.cairo(color: Colors.grey.shade700)),
              Text('${cart.length} منتج', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '$total ريال سعودي',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2596FA),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionArea(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BlocBuilder<StoreCubit, StoreState>(
          builder: (context, state) {
            if (state is StoreLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (selectedPaymentMethod == 'card') {
              return SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (context.read<AuthCubit>().isGuestMode()) {
                      showLoginRequiredDialog(context, actionName: 'الدفع ببطاقة الائتمان');
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
                    backgroundColor: const Color(0xFF2596FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(FontAwesomeIcons.creditCard, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'ادفع ببطاقة الائتمان',
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
            return SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (context.read<AuthCubit>().isGuestMode()) {
                    showLoginRequiredDialog(context, actionName: 'تأكيد الطلب');
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
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(FontAwesomeIcons.moneyBill, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'تأكيد الطلب',
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
      ),
    );
  }

  void _showSuccessDialog(
    BuildContext context, {
    required String title,
    required String subtitle,
    bool goToStore = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FontAwesomeIcons.circleCheck, color: Colors.green, size: 60),
              const SizedBox(height: 20),
              Text(
                title,
                style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: GoogleFonts.cairo(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (goToStore) {
                      final authCubit = context.read<AuthCubit>();
                      Navigator.of(context).pushAndRemoveUntil(
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
                    } else {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'العودة للرئيسية',
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
}
