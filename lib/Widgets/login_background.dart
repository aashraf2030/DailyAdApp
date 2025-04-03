import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginBG extends StatelessWidget{

  const LoginBG({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context)
  {
    return Stack(
      children: <Widget>[
        SvgPicture.asset('assets/imgs/Background.svg',
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.8,
          fit: BoxFit.fitHeight,
        ),
        child
      ]
    );
  }
}