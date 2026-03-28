import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdPaymentWebViewPage extends StatefulWidget {
  final String url;
  final int orderId;
  final VoidCallback? onSuccess;
  final VoidCallback? onFailure;

  const AdPaymentWebViewPage({
    Key? key, 
    required this.url,
    required this.orderId,
    this.onSuccess,
    this.onFailure,
  }) : super(key: key);

  @override
  State<AdPaymentWebViewPage> createState() => _AdPaymentWebViewPageState();
}

class _AdPaymentWebViewPageState extends State<AdPaymentWebViewPage> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    
    
    context.read<OperationalCubit>().verifyAdPayment(widget.orderId.toString());

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<OperationalCubit, OperationalState>(
      listener: (context, state) {
        if (state is AdPaymentSuccess) {
           if (widget.onSuccess != null) {
             widget.onSuccess!();
           } else {
             Navigator.of(context).pop(true);
           }
        } else if (state is AdPaymentFailure) {
           if (widget.onFailure != null) {
             widget.onFailure!();
           }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إتمام الدفع'),
          backgroundColor: Color(0xFF2596FA),
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
