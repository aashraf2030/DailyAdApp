import 'package:ads_app/API/base.dart';
import 'package:ads_app/network/interceptors.dart';
import 'package:dio/dio.dart';

class AuthorityWeb{

  late final Dio dio;
  AuthorityWeb()
  {
    final options = BaseOptions(
      receiveTimeout: Duration(seconds: 30),
      sendTimeout: Duration(seconds: 30),
      connectTimeout: Duration(minutes: 1),
      receiveDataWhenStatusError: true,
    );

    dio = Dio(options)..interceptors.addAll([LoggerInterceptor()]);
  }

  Future<List<dynamic>> getDefaultReq(String session, String id, String? tier) async
  {
    Object fd;

    if (tier != null)
      {
        fd = {"session": session,
          "id": id, "tier": tier};
      }
    else
      {
        fd = {"session": session,
          "id": id};
      }

    try
    {
      final res = await dio.post(BackendAPI.defaultReq, data: fd);

      // التأكد من أن الـ response عبارة عن array
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
    Object fd;

    if (tier != null)
    {
      fd = {"session": session,
        "id": id, "tier": tier};
    }
    else
    {
      fd = {"session": session,
        "id": id};
    }

    try
    {
      final res = await dio.post(BackendAPI.renewReq, data: fd);

      // التأكد من أن الـ response عبارة عن array
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
      final res = await dio.post(BackendAPI.moneyReq, data: {"session": session,
        "id": id});

      // التأكد من أن الـ response عبارة عن array
      if (res.data is List) {
        return res.data;
      } else {
        return [];
      }
    }
    on Exception {
      return [];
    }
  }

  Future<List<dynamic>> getMyRequest(String session, String id) async
  {
    try
    {
      // Try POST first (for updated backend)
      try {
        final res = await dio.post(BackendAPI.myReq, data: {"session": session, "id": id});
        if (res.data is List) {
          return res.data;
        }
      } catch (e) {
        print("POST failed, trying GET with query parameters...");
      }
      
      // Fallback to GET with query parameters (for old backend)
      final res = await dio.get(
        BackendAPI.myReq,
        queryParameters: {"session": session, "id": id},
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      // التأكد من أن الـ response عبارة عن array
      if (res.data is List) {
        return res.data;
      } else {
        // لو الـ response مش array (مثلاً error message)، نرجع empty array
        return [];
      }
    }
    on Exception catch (e) {
      print("Error getting my requests: $e");
      return [];
    }
  }

  Future<dynamic> handleRequest(String session, String id,
      String req, bool state) async
  {
    try
    {
      // Changed to POST for better CORS compatibility
      final res = await dio.post(BackendAPI.handleReq, data: {"session": session,
        "id": id, "reqID": req, "state": state});
      return res.data;
    }
    on Exception{
      return [];
    }
  }

  Future<dynamic> deleteRequest(String session, String id, String req) async
  {
    try
    {
      final res = await dio.delete(BackendAPI.deleteReq, data: {"session": session,
        "id": id, "reqID": req});

      return res.data;
    }
    on Exception {
      return [];
    }
  }

  Future<dynamic> exchangeRequest(String session, String id) async
  {
    try
    {
      final res = await dio.put(BackendAPI.pointExchange, data: {"session": session,
        "id": id});
      return res.data;
    }
    on Exception{
      return [];
    }
  }

  Future<List<dynamic>> getLeaderboard(String session, String user)
  async
  {
    try{
      final response = await dio.post(BackendAPI.leaderboard, data: {
        "session": session, "id":user
      });

      // التأكد من أن الـ response عبارة عن array
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
