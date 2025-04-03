import 'package:ads_app/Models/ad_models.dart';
import 'package:ads_app/Web/ad_web.dart';

class AdsRepo {

  late final AdWebService web;

  AdsRepo()
  {
    web = AdWebService();
  }

  Future<String> createAd (String session, String id, String name,
      String image, String imName, String path, int tier,
      int category,String keywords) async
  {
    final response = await web.createAd(session, id, name, image, imName, path, tier,
        category, keywords);

    return response.toString();
  }

  Future<String> editAd (String session, String id, String ad, String name,
      String? image, String imName, String path,
      int category,String keywords) async
  {
    final response = await web.editAd(session, id, ad, name, image, imName, path,
        category, keywords);

    return response.toString();
  }

  Future<String> watch (String session, String id, String ad) async
  {
    final response = await web.watchAd(session, id, ad);

    return response.toString();
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

  Future<List<AdData>> fetchCatAds (String session ,String id, int cat, bool? full) async
  {
    final response = await web.fetchCategoryAds(session, id, cat, full);

    return response.map((x) => AdData.fromJson(x)).toList();
  }
}