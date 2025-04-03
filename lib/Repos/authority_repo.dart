import 'package:ads_app/Models/authority_models.dart';
import 'package:ads_app/Models/user_models.dart';
import 'package:ads_app/Web/authority_web.dart';

class AuthorityRepo {

  late final AuthorityWeb web;

  AuthorityRepo()
  {
    web = AuthorityWeb();
  }

  Future<List<UserRequest>> getDefaultReq(String session, String id, String? tier) async
  {
    return (await web.getDefaultReq(session, id, tier)).map(
          (x) => DefaultRequest.fromJson(x),).toList();
  }

  Future<List<UserRequest>> getRenewReq(String session, String id, String? tier) async
  {
    return (await web.getRenewRequest(session, id, tier)).map(
          (x) => RenewRequest.fromJson(x),).toList();
  }


  Future<List<MoneyRequest>> getMoneyReq(String session, String id) async
  {
    return (await web.getMoneyRequest(session, id)).map(
          (x) => MoneyRequest.fromJson(x),).toList();
  }

  Future<List<MyRequest>> getMyReq(String session, String id) async
  {
    return (await web.getMyRequest(session, id)).map(
          (x) => MyRequest.fromJson(x),).toList();
  }

  Future<String> handleRequest(String session, String id, String req,
      bool state) async
  {
    return (await web.handleRequest(session, id, req, state)).toString();
  }

  Future<String> deleteRequest(String session, String id, String req) async
  {
    return (await web.deleteRequest(session, id, req)).toString();
  }

  Future<String> exchangeRequest(String session, String id) async
  {
    return (await web.exchangeRequest(session, id)).toString();
  }

  Future<List<LeaderboardUser>> getLeaderboard(String session, String user) async
  {
    final response = await web.getLeaderboard(session, user);

    return response.map((x) => LeaderboardUser.fromJson(x)).toList();
  }
}