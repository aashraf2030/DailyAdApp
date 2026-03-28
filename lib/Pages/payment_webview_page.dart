import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Bloc/Store/store_cubit.dart';
import '../Bloc/Store/store_state.dart';

class PaymentWebviewPage extends StatefulWidget {
  final String url;
  final int orderId;

  const PaymentWebviewPage({
    Key? key, 
    required this.url,
    required this.orderId
  }) : super(key: key);

  @override
  State<PaymentWebviewPage> createState() => _PaymentWebviewPageState();
}

class _PaymentWebviewPageState extends State<PaymentWebviewPage> {
  WebViewController? controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    
    
    context.read<StoreCubit>().verifyPayment(widget.orderId);

    if (kIsWeb) {
      
      _launchPaymentUrl();
    } else {
      
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              
            },
            onPageStarted: (String url) {},
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {},
            onNavigationRequest: (NavigationRequest request) {
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  Future<void> _launchPaymentUrl() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch payment URL')),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoreCubit, StoreState>(
      listener: (context, state) {
        if (state is StorePaymentSuccess) {
          if (state.orderId == widget.orderId) {
             Navigator.of(context).pop(true); 
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete Payment'),
        ),
        body: kIsWeb
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.payment, size: 80, color: Colors.blue),
                    const SizedBox(height: 20),
                    const Text(
                      'جاري الدفع في نافذة جديدة...',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text('يرجى إتمام عملية الدفع في النافذة المنبثقة'),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _launchPaymentUrl,
                      child: const Text('فتح صفحة الدفع مرة أخرى'),
                    ),
                    const SizedBox(height: 10),
                    if (isLoading) const CircularProgressIndicator(),
                  ],
                ),
              )
            : Stack(
                children: [
                  if (controller != null) WebViewWidget(controller: controller!),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
      ),
    );
  }
}
