import 'dart:convert';
import 'dart:async';

import 'package:ads_app/API/base.dart';
import 'package:ads_app/core/constants/app_constants.dart';
import 'package:ads_app/core/exceptions/app_exceptions.dart';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';

class AuthServices {
  final Dio dio;

  AuthServices(this.dio);

  /// Hashes password using SHA-256
  String _hashPassword(String password) {
    return base64.encode(sha256.convert(utf8.encode(password)).bytes);
  }

  /// Handles Dio exceptions and converts them to meaningful responses
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

  Future<dynamic> tryLogin(String user, String pass) async {
    try {
      final hash = _hashPassword(pass);
      final res = await dio.post(
        BackendAPI.login,
        data: {"user": user, "pass": hash},
        options: Options(
          validateStatus: (status) {
            // Accept 200 (success), 201 (created), and 403 (Unverified users)
            // This allows us to read the response body even for 403 status
            return status != null && ((status >= 200 && status < 300) || status == 403);
          },
        ),
      );
      return res.data;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> getProfile(String session, String id) async {
    try {
      // Token is automatically added by AuthInterceptor
      final res = await dio.post(
        BackendAPI.profile,
        data: {"id": id},
      );
      return res.data;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> tryRegister(
    String name,
    String user,
    String pass,
    String email,
    String? phone,
  ) async {
    try {
      final hash = _hashPassword(pass);
      
      final Map<String, dynamic> userdata = {
        "user": user,
        "pass": hash,
        "name": name,
        "email": email,
      };
      
      if (phone != null) {
        userdata["phone"] = phone;
      }

      final res = await dio.post(BackendAPI.register, data: userdata);
      return res.data;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> isAdmin(String id, String session) async {
    try {
      // Token is automatically added by AuthInterceptor
      final res = await dio.post(
        BackendAPI.is_admin,
        data: {"id": id},
      );
      return res.data;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> isLoggedIn(String id, String session) async {
    try {
      // Token is automatically added by AuthInterceptor
      final res = await dio.post(
        BackendAPI.is_loggedin,
        data: {"id": id},
      );
      return res.data;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> logout(String id, String session) async {
    try {
      // Token is automatically added by AuthInterceptor
      final res = await dio.post(
        BackendAPI.logout,
        data: {"id": id},
      );
      return res.data;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> delete(String id, String session) async {
    try {
      // Token is automatically added by AuthInterceptor
      // Use POST instead of DELETE because Laravel doesn't support body in DELETE
      final res = await dio.post(
        BackendAPI.delete_user,
        data: {"id": id},
      );
      return res.data;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> tryVerify(String id, String session, String code) async {
    try {
      // Token is automatically added by AuthInterceptor
      final res = await dio.post(
        BackendAPI.verify,
        data: {"code": code},
      );
      return res.data;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> sendCode(String id, String session, bool passReset) async {
    try {
      // Token is automatically added by AuthInterceptor
      // For password reset, send email in body; otherwise, user is authenticated via token
      final idName = passReset ? "email" : "id";
      final res = await dio.post(
        BackendAPI.send_code,
        data: {idName: id},
      );
      return res.data;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> tryVerifyCheck(String id, String session) async {
    try {
      // Token is automatically added by AuthInterceptor
      final res = await dio.post(
        BackendAPI.verify_check,
      );
      return res.data;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> changePass(String session, String pass) async {
    try {
      final hash = _hashPassword(pass);
      // Token is automatically added by AuthInterceptor
      final res = await dio.post(
        BackendAPI.change_pass,
        data: {"pass": hash},
      );
      return res.data;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> resetPass(String email) async {
    try {
      final res = await dio.post(
        BackendAPI.pass_reset,
        data: {"email": email},
      );
      return res.data;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> validateResetPass(
    String session,
    String code,
  ) async {
    try {
      // Token is automatically added by AuthInterceptor
      final res = await dio.post(
        BackendAPI.validate_reset,
        data: {"code": code},
      );
      return res.data;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }
}
