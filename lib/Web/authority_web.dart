import 'package:ads_app/API/base.dart';
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

    dio = Dio(options);
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
      final res = await dio.get(BackendAPI.default_req, data: fd);

      return res.data;
    }
      on Exception catch (e)
    {
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
      final res = await dio.get(BackendAPI.renew_req, data: fd);

      return res.data;
    }
    on Exception catch (e)
    {
      return [];
    }
  }

  Future<List<dynamic>> getMoneyRequest(String session, String id) async
  {
    try
    {
      final res = await dio.get(BackendAPI.money_req, data: {"session": session,
        "id": id});

      return res.data;
    }
    on Exception catch (e)
    {
      return [];
    }
  }

  Future<List<dynamic>> getMyRequest(String session, String id) async
  {
    try
    {
      final res = await dio.get(BackendAPI.my_req, data: {"session": session,
        "id": id});

      return res.data;
    }
    on Exception catch (e)
    {
      return [];
    }
  }

  Future<dynamic> handleRequest(String session, String id,
      String req, bool state) async
  {
    try
    {
      final res = await dio.put(BackendAPI.handle_req, data: {"session": session,
        "id": id, "reqID": req, "state": state});
      return res.data;
    }
    on Exception catch (e)
    {
      return [];
    }
  }

  Future<dynamic> deleteRequest(String session, String id, String req) async
  {
    try
    {
      final res = await dio.delete(BackendAPI.delete_req, data: {"session": session,
        "id": id, "reqID": req});

      return res.data;
    }
    on Exception catch (e)
    {
      return [];
    }
  }

  Future<dynamic> exchangeRequest(String session, String id) async
  {
    try
    {
      final res = await dio.put(BackendAPI.point_exchange, data: {"session": session,
        "id": id});
      return res.data;
    }
    on Exception catch (e)
    {
      return [];
    }
  }

  Future<List<dynamic>> getLeaderboard(String session, String user)
  async
  {
    try{
      final response = await dio.get(BackendAPI.leaderboard, data: {
        "session": session, "id":user
      });

      return response.data;
    }
    on Exception catch (e){

      return [];
    }
  }
}
