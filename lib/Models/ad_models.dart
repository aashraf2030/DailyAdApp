import 'package:ads_app/Models/category_manager.dart';
import 'package:ads_app/Models/category_model.dart';

class AdData {
  late final String id;
  late final String name;
  late final String path;
  late final String image;
  late final bool isFixed;
  late final int views;
  late final int targetViews;
  late final Category category;
  late final String lastUpdate;
  late final bool isPublished;
  late final String keywords;

  AdData.fromJson(Map<String, dynamic> json)
  {
    id = json["id"];
    name = json["name"];
    path = json["path"];
    image = json["image"];
    views = json["views"];
    targetViews = json["targetViews"];
    category = CategoryManager.getCategoryById(json["category"]);
    lastUpdate = json["lastUpdate"];
    isPublished = json["isPublished"];
    keywords = json["keywords"];
    isFixed = json["type"] == "Fixed";
  }

  AdData.InvalidAd()
  {
    id = "No Id";
    name = "Invalid Ad";
    path = "No Path";
    image = "";
    views = 0;
    category = CategoryManager.getCategoryById(0);
    lastUpdate = "";
    isPublished = false;
    keywords = "";
  }
}