import 'dart:io';
import 'package:ads_app/core/constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:ads_app/API/base.dart';

class AdsWebServices {
  final Dio dio;

  AdsWebServices(this.dio);

  
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
          
          if (statusCode == 422 && error.response?.data != null) {
            final errorData = error.response!.data;
            String errorMessage = "خطأ في التحقق من البيانات";
            if (errorData is Map && errorData.containsKey('errors')) {
              final errors = errorData['errors'];
              if (errors is Map && errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  errorMessage = firstError.first.toString();
                }
              }
            } else if (errorData is Map && errorData.containsKey('message')) {
              errorMessage = errorData['message'].toString();
            }
            return {"status": AppConstants.statusError, "message": errorMessage};
          }
          return {"status": AppConstants.statusError, "message": "خطأ في الاستجابة: $statusCode"};
        
        default:
          return {"status": AppConstants.statusError, "message": AppConstants.errorGeneric};
      }
    }
    return {"status": AppConstants.statusError, "message": AppConstants.errorGeneric};
  }

  Future<List<int>> _readFileAsBytes(String filePath) async {
    try {
      final file = File(filePath);
      return await file.readAsBytes();
    } catch (e) {
      throw Exception("Cannot read file: $e");
    }
  }

  Future<dynamic> createAd(
    String session,
    String id,
    String name,
    String image,
    String imName,
    String path,
    String type,
    int targetViews,
    int category,
    String keywords,
  ) async {
    try {
      final bytes = await _readFileAsBytes(image);
      final file = MultipartFile.fromBytes(bytes, filename: imName);
      
      final imageObj = FormData.fromMap({
        "file": file,
        "id": id,
        "name": name,
        "targetViews": targetViews,
        "path": path,
        "type": type,
        "category": category,
        "keywords": keywords,
      });

      
      
      final response = await dio.post(
        BackendAPI.create_ad,
        data: imageObj,
        options: Options(
          validateStatus: (status) {
            
            return status != null && (status >= 200 && status < 300) || status == 422;
          },
        ),
      );
      
      
      if (response.statusCode == 422) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
      
      return response;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> createAdWithBytes(
    String session,
    String id,
    String name,
    List<int> imageBytes,
    String imName,
    String path,
    String type,
    int targetViews,
    int category,
    String keywords,
  ) async {
    try {
      final file = MultipartFile.fromBytes(imageBytes, filename: imName);
      
      final imageObj = FormData.fromMap({
        "file": file,
        "session": session, 
        "id": id,
        "name": name,
        "targetViews": targetViews,
        "path": path,
        "type": type,
        "category": category,
        "keywords": keywords,
      });

      
      
      final response = await dio.post(
        BackendAPI.create_ad,
        data: imageObj,
        options: Options(
          headers: {
            'Authorization': 'Bearer $session',
          },
          validateStatus: (status) {
            
            return status != null && (status >= 200 && status < 300) || status == 422;
          },
        ),
      );
      
      
      if (response.statusCode == 422) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
      
      return response;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> editAd(
    String session,
    String id,
    String ad,
    String name,
    String? image,
    String imName,
    String path,
    String type,
    int targets,
    int category,
    String keywords,
  ) async {
    try {
      final Map<String, dynamic> formData = {
        "id": id,
        "name": name,
        "ad": ad,
        "path": path,
        "category": category,
        "keywords": keywords,
        "type": type,
        "targetViews": targets,
      };

      if (image != null) {
        final file = await MultipartFile.fromFile(image, filename: imName);
        formData["file"] = file;
      }

      final imageObj = FormData.fromMap(formData);
      
      
      final response = await dio.post(
        BackendAPI.edit_ad,
        data: imageObj,
        options: Options(
          validateStatus: (status) {
            
            return status != null && (status >= 200 && status < 300) || status == 422;
          },
        ),
      );
      
      
      if (response.statusCode == 422) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
      return response;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<List<dynamic>> getUserAds(String session, String id) async {
    try {
      
      final response = await dio.post(
        BackendAPI.get_user_ad,
        data: {"id": id},
      );
      return response.data;
    } catch (e, stackTrace) {
      return [];
    }
  }

  Future<List<dynamic>> fetchCategoryAds(
    String session,
    String id,
    int category,
    bool? full, {
    String? adType,
  }) async {
    try {
      
      
      final Map<String, dynamic> requestData = {
        "id": id,
        "category": category,
        "full": full,
      };
      
      
      if (adType != null) {
        requestData["adType"] = adType;
      }
      
      final response = await dio.post(
        BackendAPI.fetch_cat_ad,
        data: requestData,
      );
      return response.data;
    } catch (e, stackTrace) {
      return [];
    }
  }

  Future<dynamic> renew(
    String session,
    String id,
    String ad,
    String tier,
  ) async {
    try {
      
      final response = await dio.post(
        BackendAPI.renew_ad,
        data: {"id": id, "ad": ad, "tier": tier},
      );
      return response;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> watchAd(String session, String id, String ad) async {
    try {
      
      final response = await dio.post(
        BackendAPI.watch,
        data: {"id": id, "ad": ad},
      );
      return response;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> initializeAdPayment({
    required String name,
    required String imagePath,
    required String imageName,
    required String adLink,
    required String type,
    required int targetViews,
    required int category,
    required String keywords,
    required String paymentMethod,
    required String platform,
    String? couponCode,
  }) async {
    try {
      final bytes = await _readFileAsBytes(imagePath);
      final file = MultipartFile.fromBytes(bytes, filename: imageName);

      final formDataMap = {
        "file": file,
        "name": name,
        "path": adLink, 
        "type": type,
        "targetViews": targetViews,
        "category": category,
        "keywords": keywords,
        "payment_method": paymentMethod,
        "platform": platform,
      };

      if (couponCode != null && couponCode.isNotEmpty) {
        formDataMap["coupon_code"] = couponCode;
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await dio.post(
        BackendAPI.ad_payment_initialize,
        data: formData,
        options: Options(
          validateStatus: (status) {
            return status != null && (status >= 200 && status < 300) || status == 422;
          },
        ),
      );

      if (response.statusCode == 422) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }

      return response;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> checkAdPaymentStatus(String paymentId) async {
    try {
      final response = await dio.post(
        BackendAPI.ad_payment_status,
        data: {"payment_id": paymentId},
      );
      return response;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> confirmAdApplePay(String paymentId, String paymentToken) async {
    try {
      final response = await dio.post(
        BackendAPI.ad_payment_confirm_apple,
        data: {
          "payment_id": paymentId,
          "apple_pay_token": paymentToken, 
        },
      );
      return response;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  Future<dynamic> validateCoupon(String code, double amount) async {
    try {
      final response = await dio.post(
        BackendAPI.validate_coupon,
        data: {
          "code": code,
          "amount": amount,
        },
      );
      return response;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }
  Future<dynamic> fetchPricing() async {
    try {
      final response = await dio.get(BackendAPI.ad_payment_pricing);
      return response;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }
}