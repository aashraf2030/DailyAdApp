import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Category{
  final int id;
  final String name;
  final IconData icon;

  Category(this.id, this.name, this.icon);
}

final categories = [
  Category(0, "ابرز الإعلانات", FontAwesomeIcons.turnUp),
  Category(1, "السيارات", FontAwesomeIcons.car),
  Category(2, "الكتب والمجلات", FontAwesomeIcons.book),
  Category(3, "الحواسيب", FontAwesomeIcons.computer),
  Category(4, "الموضة والازياء", FontAwesomeIcons.shirt),
  Category(5, "الترفيه والالعاب", FontAwesomeIcons.gamepad),
  Category(6, "البقالة والادوات المنزلية", FontAwesomeIcons.basketShopping),
  Category(7, "الصحة", FontAwesomeIcons.suitcaseMedical),
  Category(8, "المنزل والاثاث", FontAwesomeIcons.house),
  Category(9, "الحيوانات الاليفة", FontAwesomeIcons.dog),
  Category(10, "طعام", FontAwesomeIcons.burger),
  Category(11, "متنوع", FontAwesomeIcons.layerGroup),
];