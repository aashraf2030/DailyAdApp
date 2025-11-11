import 'dart:convert';

import 'package:ads_app/API/base.dart';
import 'package:ads_app/network/interceptors.dart';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';

class AuthServices {
  late Dio dio;

  AuthServices() {
    final options = BaseOptions(
        connectTimeout: Duration(seconds: 30),
        receiveDataWhenStatusError: true,
        receiveTimeout: Duration(minutes: 1));

    dio = Dio(options)..interceptors.addAll([LoggerInterceptor()]);
  }

  Future<dynamic> tryLogin(String user, String pass) async {
    final hash = base64.encode((sha256.convert(utf8.encode(pass))).bytes);

    try {
      final res =
          await dio.post(BackendAPI.login, data: {"user": user, "pass": hash});
      return res.data;
    } on Exception catch (e) {
      print(e);
      return <String, dynamic>{"status": "Error"};
    }
  }

  Future<dynamic> getProfile(String session, String id) async {
    try {
      final res = await dio
          .post(BackendAPI.profile, data: {"session": session, "id": id});
      return res.data;
    } on Exception catch (e) {
      print(e);
      return <String, dynamic>{"status": "Error"};
    }
  }

  Future<dynamic> tryRegister(String name, String user, String pass,
      String email, String? phone) async {
    final hash = base64.encode((sha256.convert(utf8.encode(pass))).bytes);

    Object userdata;

    if (phone == null) {
      userdata = {"user": user, "pass": hash, "name": name, "email": email};
    } else {
      userdata = {
        "user": user,
        "pass": hash,
        "name": name,
        "email": email,
        "phone": phone
      };
    }

    try {
      final res = await dio.post(BackendAPI.register, data: userdata);
      return res.data;
    } on Exception {
      return <String, dynamic>{"status": "Error"};
    }
  }

  Future<dynamic> isAdmin(String id, String session) async {
    try {
      final res = await dio
          .post(BackendAPI.is_admin, data: {"id": id, "session": session});

      return res.data;
    } on Exception catch (e) {
      print("Error : ${e.toString()}");
      return <String, dynamic>{"status": "Error"};
    }
  }

  Future<dynamic> isLoggedIn(String id, String session) async {
    try {
      final res = await dio
          .post(BackendAPI.is_loggedin, data: {"id": id, "session": session});

      return res.data;
    } on Exception catch (e) {
      print("Error : ${e.toString()}");
      return <String, dynamic>{"status": "Error"};
    }
  }

  Future<dynamic> logout(String id, String session) async {
    try {
      final res = await dio
          .post(BackendAPI.logout, data: {"id": id, "session": session});

      return res.data;
    } on Exception catch (e) {
      print("Error : ${e.toString()}");
      return <String, dynamic>{"status": "Error"};
    }
  }

  Future<dynamic> delete(String id, String session) async {
    try {
      final res = await dio
          .delete(BackendAPI.delete_user, data: {"id": id, "session": session});

      return res.data;
    } on Exception catch (e) {
      print("Error : ${e.toString()}");
      return <String, dynamic>{"status": "Error"};
    }
  }

  Future<dynamic> tryVerify(String id, String session, String code) async {
    try {
      final res = await dio.post(BackendAPI.verify,
          data: {"id": id, "session": session, "code": code});
      return res.data;
    } on Exception {
      return <String, dynamic>{"status": "Error"};
    }
  }

  Future<dynamic> sendCode(String id, String session, bool passReset) async {
    final idName = passReset ? "email" : "id";
    try {
      final res = await dio.post(BackendAPI.send_code,
          data: {"${idName}": id, "session": session});
      return res.data;
    } on Exception {
      return <String, dynamic>{"status": "Error"};
    }
  }

  Future<dynamic> tryVerifyCheck(String id, String session) async {
    try {
      final res = await dio
          .post(BackendAPI.verify_check, data: {"id": id, "session": session});
      return res.data;
    } on Exception catch (e) {
      print("Error : ${e.toString()}");
      return <String, dynamic>{"status": "Error"};
    }
  }

  Future<dynamic> changePass(String id, String session, String pass) async {
    final hash = base64.encode(sha256.convert(utf8.encode(pass)).bytes);

    try {
      final res = await dio.post(BackendAPI.change_pass,
          data: {"email": id, "session": session, "pass": hash});
      return res.data;
    } on Exception catch (e) {
      print("Error : ${e.toString()}");
      return <String, dynamic>{"status": "Error"};
    }
  }

  Future<dynamic> resetPass(String email) async {
    try {
      final res = await dio.post(BackendAPI.pass_reset, data: {"email": email});
      return res.data;
    } on Exception catch (e) {
      print("Error : ${e.toString()}");
      return <String, dynamic>{"status": "Error"};
    }
  }

  Future<dynamic> validateResetPass(
      String email, String session, String code) async {
    try {
      final res = await dio.post(BackendAPI.validate_reset,
          data: {"email": email, "session": session, "code": code});
      return res.data;
    } on Exception catch (e) {
      print("Error : ${e.toString()}");
      return <String, dynamic>{"status": "Error"};
    }
  }
}
