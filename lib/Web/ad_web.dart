import 'dart:io';
import 'package:ads_app/network/interceptors.dart';
import 'package:dio/dio.dart';
import 'package:ads_app/API/base.dart';

class AdWebService {

  late Dio dio;

  AdWebService() {
    final options = BaseOptions(
        connectTimeout: Duration(seconds: 30),
        receiveDataWhenStatusError: true,
        receiveTimeout: Duration(minutes: 1));

    dio = Dio(options)..interceptors.addAll([LoggerInterceptor()]);
  }

  Future<dynamic> createAd (String session, String id, String name,
      String image, String imName, String path, String type, int targetViews
      , int category,String keywords) async
  {
    MultipartFile file;
    
    // Web platform: use fromBytes
    // Mobile platform: use fromFile
    try {
      // Try to read file as bytes (works on all platforms)
      final bytes = await _readFileAsBytes(image);
      file = MultipartFile.fromBytes(bytes, filename: imName);
    } catch (e) {
      print("Error reading file: $e");
      return "Error";
    }
    
    FormData imageObj = FormData.fromMap({
      "file": file,
      "session": session, "id": id, "name": name, "targetViews": targetViews,
      "path": path, "type": type, "category": category, "keywords": keywords
    }); 

    try
    {
      final response = await dio.put(BackendAPI.create_ad,
          data: imageObj);

      print("Response : ${response.toString()}");

      return response;
    }
    on Exception catch (e)
    {
      print(e.toString());
      return "Error";
    }
  }
  
  Future<dynamic> createAdWithBytes (String session, String id, String name,
      List<int> imageBytes, String imName, String path, String type, int targetViews
      , int category,String keywords) async
  {
    MultipartFile file = MultipartFile.fromBytes(imageBytes, filename: imName);
    
    FormData imageObj = FormData.fromMap({
      "file": file,
      "session": session, "id": id, "name": name, "targetViews": targetViews,
      "path": path, "type": type, "category": category, "keywords": keywords
    }); 

    try
    {
      final response = await dio.put(BackendAPI.create_ad,
          data: imageObj);

      print("Response : ${response.toString()}");

      return response;
    }
    on Exception catch (e)
    {
      print(e.toString());
      return "Error";
    }
  }
  
  Future<List<int>> _readFileAsBytes(String filePath) async {
    // For mobile platforms, read file using dart:io
    try {
      final file = File(filePath);
      return await file.readAsBytes();
    } catch (e) {
      throw Exception("Cannot read file: $e");
    }
  }

  Future<dynamic> editAd(String session, String id, String ad, String name,
      String? image, String imName, String path, String type, int targets
      , int category,String keywords)
  async {

    FormData imageObj;

    if (image != null)
      {
        MultipartFile file = await MultipartFile.fromFile(image, filename: imName);

        imageObj = FormData.fromMap({
          "file": file,
          "session": session, "id": id, "name": name, "ad": ad,
          "path": path, "category": category, "keywords": keywords,
          "type": type, "targetViews": targets
        });
      }
    else
      {
        imageObj = FormData.fromMap({
          "session": session, "id": id, "name": name, "ad": ad,
          "path": path, "category": category, "keywords": keywords,
          "type": type, "targetViews": targets
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
      final response = await dio.post(BackendAPI.get_user_ad,
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
      final response = await dio.post(BackendAPI.fetch_cat_ad,
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