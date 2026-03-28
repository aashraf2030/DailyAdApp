import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';









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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          ' Pay',
          style: TextStyle(
            fontFamily: '.SF Pro Display', 
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
