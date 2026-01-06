import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Start polling for payment status
    context.read<StoreCubit>().verifyPayment(widget.orderId);

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // Check for success/failure redirects if needed
            // Otherwise reliance on webhook+polling is safer
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoreCubit, StoreState>(
      listener: (context, state) {
        if (state is StorePaymentSuccess) {
          if (state.orderId == widget.orderId) {
             Navigator.of(context).pop(true); // Return true for success
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete Payment'),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
