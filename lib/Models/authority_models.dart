import 'package:ads_app/Models/category_model.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class UserRequest {}

class DefaultRequest extends UserRequest{
  late String id;
  late String adName;
  late String username;
  late String path;
  late String image;
  late int target;
  late String tier;
  late Category category;
  
  DefaultRequest.fromJson(Map<String, dynamic> json)
  {
    id = json["reqid"];
    adName = json["adname"];
    username = json["username"];
    path = json["path"];
    image = json["image"];
    target = json["target"];
    tier = json["tier"];
    category = categories[json["category"]];
  }
}

class RenewRequest extends UserRequest{
  late String id;
  late String adName;
  late String username;
  late String userPhone;
  late String path;
  late String image;
  late int views;
  late int target;
  late String tier;
  late Category category;
  late String creation;
  late String lastUpdate;
  RenewRequest.fromJson(Map<String, dynamic> json)
  {
    id = json["reqid"];
    adName = json["adname"];
    username = json["username"];
    userPhone = json["userphone"];
    path = json["path"];
    image = json["image"];
    views = json["views"];
    target = json["target"];
    tier = json["tier"];
    category = categories[json["category"]];
    creation = json["creation"];
    lastUpdate = json["lastUpdate"];
  }
}

class MoneyRequest extends UserRequest{
  late String id;
  late String username;
  late String userPhone;
  late int views;
  late int money;
  late String join;

  MoneyRequest.fromJson(Map<String, dynamic> json)
  {
    id = json["id"];
    username = json["username"];
    userPhone = json["userphone"];
    views = json["views"];
    money = json["money"];
    join = json["join"];
  }
}


class MyRequest extends UserRequest{
  late String id;
  late String adName;
  late String type;
  late String creation;

  MyRequest.fromJson(Map<String, dynamic> json)
  {
    id = json["id"];
    adName = json["adName"];
    type = json["type"];
    creation = json["creation"];
  }
}