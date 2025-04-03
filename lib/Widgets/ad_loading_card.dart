import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdLoadingCard extends StatelessWidget{
  
  const AdLoadingCard({super.key});
  
  @override
  Widget build(BuildContext context) 
  {
    return Card(
      margin: EdgeInsets.all(10),
      color: Colors.white,
      child: Image(image: AssetImage("assets/imgs/LoadingImage.gif")),
    );    
  }
}