import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    return Container(
      height: height,
      width: width, // Optional width, or let it fit content
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4), // Rounded square
        border: Border.all(
          color: Colors.grey.shade300, // Very light gray thin border
          width: 0.5,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center, // Center content
          children: [
            const Icon(
              FontAwesomeIcons.apple,
              color: Colors.black, // Pure black
              size: 16, // Adjust size relative to height
            ),
            const SizedBox(width: 4),
            Text(
              "Pay",
              style: const TextStyle(
                fontFamily: '.SF Pro Text', // Try to use SF Pro if available, or let OS default handling it on iOS
                fontSize: 16,
                fontWeight: FontWeight.w500, // Medium weight to match standard look
                color: Colors.black, // Pure black
                letterSpacing: -0.2, // Tweak to match Apple Pay mark
                height: 1.0, // Tight height for alignment
              ),
            ),
          ],
        ),
      ),
    );
  }
}
