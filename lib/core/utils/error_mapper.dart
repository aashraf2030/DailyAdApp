import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../exceptions/app_exceptions.dart';

/// Failure class for UI consumption
class AppFailure {
  final String message;
  final String? details;

  const AppFailure({required this.message, this.details});

  @override
  String toString() => message;
}

class ErrorMapper {
  static AppFailure map(dynamic error) {
    if (error is AppException) {
      return AppFailure(message: error.message, details: error.details);
    }
    
    if (error is DioException) {
      return _mapDioError(error);
    }
    
    return const AppFailure(message: AppConstants.errorGeneric);
  }

  static AppFailure _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppFailure(message: AppConstants.errorTimeout);
        
      case DioExceptionType.connectionError:
        return AppFailure(message: AppConstants.errorNetwork);
        
      case DioExceptionType.badResponse:
        return _mapBadResponse(error.response);
        
      case DioExceptionType.cancel:
        return const AppFailure(message: "تم إلغاء الطلب");
        
      default:
        return const AppFailure(message: AppConstants.errorGeneric);
    }
  }

  static AppFailure _mapBadResponse(Response? response) {
    if (response == null) {
      return const AppFailure(message: AppConstants.errorServer);
    }
    
    final int statusCode = response.statusCode ?? 500;
    final dynamic data = response.data;
    
    // Custom backend error messages if available
    String? backendMessage;
    if (data is Map<String, dynamic>) {
       backendMessage = data['message'] ?? data['error'];
    }

    // You can customize this switch based on backend status codes
    switch (statusCode) {
      case 400:
        return AppFailure(message: backendMessage ?? "طلب غير صحيح");
      case 401:
        return AppFailure(message: AppConstants.errorInvalidAuth);
      case 403:
        return AppFailure(message: "ليس لديك صلاحية للقيام بهذا الإجراء");
      case 404:
        return AppFailure(message: "المورد غير موجود");
      case 422:
        return AppFailure(message: backendMessage ?? "بيانات غير صالحة");
      case 500:
        return AppFailure(message: AppConstants.errorServer);
      case 503:
        return AppFailure(message: "الخدمة غير متاحة حالياً");
      default:
        if (backendMessage != null && backendMessage.isNotEmpty) {
           return AppFailure(message: backendMessage); // Use server error message if present and specific
        }
        return const AppFailure(message: AppConstants.errorGeneric);
    }
  }
}
