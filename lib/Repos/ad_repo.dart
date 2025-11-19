import 'package:ads_app/Models/ad_models.dart';
import 'package:ads_app/Web/ad_web.dart';

class AdsRepo {
  final AdsWebServices web;

  AdsRepo(this.web);

  Future<String> createAd (String session, String id, String name,
      String image, String imName, String path, String type, int targetViews,
      int category,String keywords) async
  {
    final response = await web.createAd(session, id, name, image, imName, path,
        type, targetViews,
        category, keywords);

    // Check if response is a Map (error from _handleError) or Response object
    if (response is Map) {
      return response['status'] ?? 'Error';
    }
    
    // Response object from successful request
    if (response.data != null && response.data is Map) {
      return response.data['status'] ?? 'Error';
    }
    
    return 'Error';
  }
  
  Future<String> createAdWithBytes (String session, String id, String name,
      List<int> imageBytes, String imName, String path, String type, int targetViews,
      int category,String keywords) async
  {
    final response = await web.createAdWithBytes(session, id, name, imageBytes, imName, path,
        type, targetViews,
        category, keywords);

    // Check if response is a Map (error from _handleError) or Response object
    if (response is Map) {
      return response['status'] ?? 'Error';
    }
    
    // Response object from successful request
    if (response.data != null && response.data is Map) {
      return response.data['status'] ?? 'Error';
    }
    
    return 'Error';
  }

  Future<String> editAd (String session, String id, String ad, String name,
      String type, int targetViews, String? image, String imName, String path,
      int category,String keywords) async
  {
    final response = await web.editAd(session, id, ad, name, image, imName, path,
        type, targetViews, category, keywords);

    // Check if response is a Map (error from _handleError) or Response object
    if (response is Map) {
      return response['status'] ?? 'Error';
    }
    
    // Response object from successful request
    if (response.data != null && response.data is Map) {
      return response.data['status'] ?? 'Error';
    }
    
    return 'Error';
  }

  Future<String> watch (String session, String id, String ad) async
  {
    try {
      final response = await web.watchAd(session, id, ad);
      
      // Check if response is a Map (error from _handleError) or Response object
      if (response is Map) {
        return response['status'] ?? 'Error';
      }
      
      // Response object from successful request
      if (response.data != null && response.data is Map) {
        return response.data['status'] ?? 'Error';
      }
      
      return 'Error';
    } catch (e) {
      print("Error watching ad: $e");
      return 'Error';
    }
  }

  Future<String> renew(String session, String id, String ad, String tier) async
  {
    final response = await web.renew(session, id, ad, tier);

    return response.toString();
  }

  Future<List<AdData>> getUserAds (String session ,String id) async
  {
    final response = await web.getUserAds(session, id);

    return response.map((x) => AdData.fromJson(x)).toList();
  }

  Future<List<AdData>> fetchCatAds (String session ,String id, int cat, bool? full, {String? adType}) async
  {
    final response = await web.fetchCategoryAds(session, id, cat, full, adType: adType);

    return response.map((x) => AdData.fromJson(x)).toList();
  }
}