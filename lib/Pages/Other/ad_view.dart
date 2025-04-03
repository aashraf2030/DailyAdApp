import 'dart:async';

import 'package:ads_app/Models/ad_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdView extends StatefulWidget {
  final AdData ad;

  const AdView({
    super.key,
    required this.ad,
  });

  @override
  AdViewState createState() => AdViewState();
}

class AdViewState extends State<AdView> {
  late final WebViewController _webViewController;
  late Timer timer;
  late Timer counter;
  int counterText = 15;
  bool showBackButton = true;
  @override
  void initState() { 
    super.initState();
    _webViewController = WebViewController()
      ..setUserAgent(
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
              'AppleWebKit/537.36 (KHTML, like Gecko)'
              ' Chrome/91.0.4472.124 Safari/537.36'
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onNavigationRequest: (NavigationRequest request) async {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.ad.path));

    // timer = Timer(Duration(seconds: 15), () {setState(() {
    //   showBackButton = true;
    // });});
    //
    // timer = Timer.periodic(Duration(seconds: 1), (x) {
    //   setState(() {
    //     counterText--;
    //
    //   });
    //
    //   if (counterText == 0)
    //     x.cancel();
    //
    // });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: GradientAppBar(
        automaticallyImplyLeading: false,
        title: Text("مشاهدة ${widget.ad.name}", style: GoogleFonts.cairo(),
          textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.rtl,),
        gradient: LinearGradient(colors: [Color.fromRGBO(37, 150, 250, 1),
          Color.fromRGBO(54, 74, 98, 0.85)], transform: GradientRotation(0.5)),
            actions: [
              if (showBackButton)
                IconButton(onPressed: (){Navigator.pop(context);},
                    icon: Icon(FontAwesomeIcons.x))
            ]
        ),
        body: Column(
          children: [

            // Text("الوقت المتبقي هو $counterText",
            //   style: GoogleFonts.cairo(color: Colors.blueAccent, fontSize: 20),
            //   textDirection: TextDirection.rtl,
            // ),
            Expanded(child:
            Stack(

              alignment: Alignment.center,
              children: [
                WebViewWidget(
                  controller: _webViewController,
                ),
              ],
            ),)

          ],
        ),
      ),
    );
  }
}
