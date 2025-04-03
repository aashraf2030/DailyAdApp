import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ads_app/API/base.dart';
import 'package:dio/io.dart';

class AdWebService {

  late final Dio dio;

  AdWebService()
  {
    final options = BaseOptions(
        connectTimeout: Duration(seconds: 30),
        receiveDataWhenStatusError: true,
        receiveTimeout: Duration(minutes: 1)
    );

    dio = Dio(options);

  }

  Future<dynamic> createAd (String session, String id, String name,
      String image, String imName, String path, int tier, int category,String keywords) async
  {
    MultipartFile file = await MultipartFile.fromFile(image, filename: imName);
    
    FormData imageObj = FormData.fromMap({
      "file": file,
      "session": session, "id": id, "name": name,
      "path": path, "tier": tier, "category": category, "keywords": keywords
    }); 

    try
    {
      final response = await dio.put(BackendAPI.create_ad,
          data: imageObj);

      return response;
    }
    on Exception catch (e)
    {
      print(e.toString());
      return "Error";
    }
  }

  Future<dynamic> editAd(String session, String id, String ad, String name,
      String? image, String imName, String path, int category,String keywords)
  async {

    FormData imageObj;

    if (image != null)
      {
        MultipartFile file = await MultipartFile.fromFile(image, filename: imName);

        imageObj = FormData.fromMap({
          "file": file,
          "session": session, "id": id, "name": name, "ad": ad,
          "path": path, "category": category, "keywords": keywords
        });
      }
    else
      {
        imageObj = FormData.fromMap({
          "session": session, "id": id, "name": name, "ad": ad,
          "path": path, "category": category, "keywords": keywords
        });
      }

    try
    {
      final response = await dio.put(BackendAPI.edit_ad,
          data: imageObj);

      return response;
    }
    on Exception catch (e)
    {
      print(e.toString());
      return "Error";
    }
  }

  Future<List<dynamic>> getUserAds (String session, String id) async
  {
    try
    {
      final response = await dio.get(BackendAPI.get_user_ad,
          data: {"session": session, "id": id});

      return response.data;
    }
    on Exception catch (e)
    {
      print(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> fetchCategoryAds (String session, String id,
      int category, bool? full) async
  {
    try
    {
      final response = await dio.get(BackendAPI.fetch_cat_ad,
          data: {"session": session, "id": id, "category": category,
            "full": full});

      return response.data;
    }
    on Exception catch (e)
    {
      print(e.toString());
      return [];
    }
  }

  Future<dynamic> renew (String session, String id, String ad, String tier)
  async {
    try
    {
      final response = await dio.post(BackendAPI.renew_ad,
          data: {"session": session, "id": id, "ad": ad, "tier": tier});

      return response;
    }
    on Exception catch (e)
    {
      print(e.toString());
      return "Error";
    }
  }

  Future<dynamic> watchAd(String session, String id, String ad) async {

    try
    {
      final response = await dio.post(BackendAPI.watch,
          data: {"session": session, "id": id, "ad": ad});

      return response;
    }
    on Exception catch (e)
    {
      print(e.toString());
      return "Error";
    }
  }
}