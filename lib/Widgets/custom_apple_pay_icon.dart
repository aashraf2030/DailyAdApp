import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.5,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SvgPicture.asset(
          'assets/imgs/apple_pay_mark.svg',
          height: height * 0.5, // SVG usually needs sizing adjustments
          placeholderBuilder: (context) => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
