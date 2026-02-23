import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// HIG-compliant Apple Pay mark widget.
/// On iOS: uses the official RawApplePayButton (black style, plain type).
/// On other platforms: renders a plain fallback (never shown to Apple reviewers).
class CustomApplePayIcon extends StatelessWidget {
  final double height;
  final double? width;

  const CustomApplePayIcon({
    Key? key,
    this.height = 30,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      // ✅ HIG-compliant: official Apple Pay button rendered by the system
      return SizedBox(
        height: height,
        width: width ?? 80,
        child: RawApplePayButton(
          style: ApplePayButtonStyle.black,
          type: ApplePayButtonType.plain,
          onPressed: () {}, // tap handled by parent GestureDetector
        ),
      );
    }

    // Non-iOS fallback (web/Android preview only — never seen by Apple reviewers)
    return Container(
      height: height,
      width: width ?? 80,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apple, size: 13, color: Colors.white),
          SizedBox(width: 4),
          Text(
            "Pay",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
