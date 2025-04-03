import 'package:ads_app/Models/auth_models.dart';
import 'package:ads_app/Web/auth_web.dart';

class AuthRepo{
  late final AuthServices web;

  AuthRepo() {
    web = AuthServices();
  }

  Future<AuthResult> login(String user, String pass) async{
    final res = await web.tryLogin(user, pass);

    return AuthResult.fromJson(res);
  }

  Future<AuthResult> logout(String id, String session) async{
    final res = await web.logout(id, session);

    return AuthResult.fromJson(res);
  }


  Future<UserProfile> profile(String id, String session) async{
    final res = await web.getProfile(session, id);

    if (res["name"] == null) {
      throw Exception("Can't Retrieve Data");
    }

    return UserProfile.fromJson(res);
  }

  Future<AuthResult> register(String name, String user,
      String pass, String email, String? phone) async {
    final res = await web.tryRegister(name, user, pass, email, phone);

    return AuthResult.fromJson(res);
  }

  Future<AuthResult> isAdmin(String id, String session) async {
    final res = await web.isAdmin(id, session);

    if (res is String) {
      return AuthResult("Error");
    }

    return AuthResult.fromJson(res);
  }

  Future<AuthResult> isLoggedIn(String id, String session) async {
    final res = await web.isLoggedIn(id, session);

    return AuthResult.fromJson(res);
  }

  Future<AuthResult> verify(String id, String session, String code) async {
    final res = await web.tryVerify(id, session, code);

    return AuthResult.fromJson(res);
  }

  Future<AuthResult> verifyCheck(String id, String session) async {
    final res = await web.tryVerifyCheck(id, session);

    return AuthResult.fromJson(res);
  }

  Future<AuthResult> sendCode(String id, String session, bool passReset) async {
    final res = await web.sendCode(id, session, passReset);

    return AuthResult.fromJson(res);
  }

  Future<AuthResult> changePass(String id, String session, String pass) async {
    final res = await web.changePass(id, session, pass);

    return AuthResult.fromJson(res);
  }

  Future<AuthResult> resetPass(String email) async {
    final res = await web.resetPass(email);

    return AuthResult.fromJson(res);
  }

  Future<AuthResult> validateResetPass(String email, String session, String code) async {
    final res = await web.validateResetPass(email, session, code);

    return AuthResult.fromJson(res);
  }
}