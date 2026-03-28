import 'package:ads_app/API/base.dart';
import 'package:ads_app/core/constants/app_constants.dart';
import 'package:dio/dio.dart';

class AuthorityWebServices {
  final Dio dio;

  AuthorityWebServices(this.dio);

  
  Map<String, dynamic> _handleError(Object error, StackTrace stackTrace) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return {"status": AppConstants.statusError, "message": AppConstants.errorTimeout};
        
        case DioExceptionType.connectionError:
          return {"status": AppConstants.statusError, "message": AppConstants.errorNetwork};
        
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode != null && statusCode >= 500) {
            return {"status": AppConstants.statusError, "message": AppConstants.errorServer};
          }
          return {"status": AppConstants.statusError, "message": "خطأ في الاستجابة: $statusCode"};
        
        default:
          return {"status": AppConstants.statusError, "message": AppConstants.errorGeneric};
      }
    }
    return {"status": AppConstants.statusError, "message": AppConstants.errorGeneric};
  }

  Future<List<dynamic>> getDefaultReq(String session, String id, String? tier) async
  {
    Map<String, dynamic> fd;

    if (tier != null)
      {
        fd = {"id": id, "tier": tier};
      }
    else
      {
        fd = {"id": id};
      }

    try
    {
      
      final res = await dio.post(
        BackendAPI.defaultReq, 
        data: fd,
      );

      
      if (res.data is List) {
        return res.data;
      } else {
        return [];
      }
    }
      on Exception{
      return [];
    }
  }

  Future<List<dynamic>> getRenewRequest(String session, String id, String? tier) async
  {
    Map<String, dynamic> fd;

    if (tier != null)
    {
      fd = {"id": id, "tier": tier};
    }
    else
    {
      fd = {"id": id};
    }

    try
    {
      
      final res = await dio.post(
        BackendAPI.renewReq, 
        data: fd,
      );

      
      if (res.data is List) {
        return res.data;
      } else {
        return [];
      }
    }
    on Exception{
      return [];
    }
  }

  Future<List<dynamic>> getMoneyRequest(String session, String id) async
  {
    try
    {
      
      final res = await dio.post(
        BackendAPI.moneyReq,
      );

      
      if (res.data is List) {
        return res.data;
      } else {
        return [];
      }
    }
    catch (e, stackTrace) {
      print("Error getting money requests: ${_handleError(e, stackTrace)}");
      return [];
    }
  }

  Future<List<dynamic>> getMyRequest(String session, String id) async
  {
    try
    {
      
      final res = await dio.post(
        BackendAPI.myReq,
      );
      
      
      if (res.data is List) {
        return res.data;
      } else {
        return [];
      }
    }
    catch (e, stackTrace) {
      print("Error getting my requests: ${_handleError(e, stackTrace)}");
      return [];
    }
  }

  Future<dynamic> handleRequest(String session, String id,
      String req, bool state) async
  {
    try
    {
      
      final res = await dio.post(
        BackendAPI.handleReq, 
        data: {"req": req, "state": state},
      );
      return res.data;
    }
    catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> deleteRequest(String session, String id, String req) async
  {
    try
    {
      
      
      final res = await dio.post(
        BackendAPI.deleteReq, 
        data: {"req": req},
      );

      return res.data;
    }
    catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> exchangeRequest(String session, String id) async
  {
    try
    {
      
      final res = await dio.post(
        BackendAPI.pointExchange,
      );
      return res.data;
    }
    catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<List<dynamic>> getLeaderboard(String session, String user)
  async
  {
    try{
      
      
      final response = await dio.post(BackendAPI.leaderboard, data: {
        "id": user
      });

      
      if (response.data is List) {
        return response.data;
      } else {
        return [];
      }
    }
    on Exception{

      return [];
    }
  }
}
