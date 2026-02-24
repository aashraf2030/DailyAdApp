import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// HIG-compliant Apple Pay inline mark for use inside payment selection rows.
///
/// Apple HIG prohibits using the Apple Pay button (RawApplePayButton) as a
/// decorative icon inside list rows — that button is only for triggering payment.
/// For inline display, the correct approach is to render the  Pay text mark
/// using the system font, on a plain white or black background pill.
///
/// Reference: https://developer.apple.com/design/human-interface-guidelines/apple-pay
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
    // ✅ Render the Apple Pay text mark as a black pill.
    // This mirrors how Apple displays the mark in their own HIG examples
    // for payment method selection lists.
    // The Apple logo character () is part of the iOS system font (SF Pro).
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          ' Pay',
          style: TextStyle(
            fontFamily: '.SF Pro Display', // iOS system font — renders  correctly
            fontSize: height * 0.45,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
