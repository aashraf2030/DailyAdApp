import '../constants/app_constants.dart';

/// Base exception class for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final String? details;
  final int? statusCode;

  AppException({
    required this.message,
    this.details,
    this.statusCode,
  });

  @override
  String toString() {
    if (details != null) {
      return '$message: $details';
    }
    return message;
  }
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException({
    String? message,
    String? details,
    int? statusCode,
  }) : super(
          message: message ?? AppConstants.errorNetwork,
          details: details,
          statusCode: statusCode,
        );
}

/// Timeout exceptions
class TimeoutException extends AppException {
  TimeoutException({
    String? message,
    String? details,
  }) : super(
          message: message ?? AppConstants.errorTimeout,
          details: details,
        );
}

/// Server error exceptions
class ServerException extends AppException {
  ServerException({
    String? message,
    String? details,
    int? statusCode,
  }) : super(
          message: message ?? AppConstants.errorServer,
          details: details,
          statusCode: statusCode,
        );
}

/// Authentication exceptions
class AuthException extends AppException {
  AuthException({
    String? message,
    String? details,
  }) : super(
          message: message ?? AppConstants.errorInvalidAuth,
          details: details,
        );
}

/// Session expired exception
class SessionExpiredException extends AppException {
  SessionExpiredException({
    String? message,
    String? details,
  }) : super(
          message: message ?? AppConstants.errorSessionExpired,
          details: details,
        );
}

/// Data parsing exceptions
class DataParsingException extends AppException {
  DataParsingException({
    String? message,
    String? details,
  }) : super(
          message: message ?? "خطأ في معالجة البيانات",
          details: details,
        );
}

/// Cache exceptions
class CacheException extends AppException {
  CacheException({
    String? message,
    String? details,
  }) : super(
          message: message ?? "خطأ في التخزين المؤقت",
          details: details,
        );
}

/// Validation exceptions
class ValidationException extends AppException {
  ValidationException({
    String? message,
    String? details,
  }) : super(
          message: message ?? "خطأ في التحقق من البيانات",
          details: details,
        );
}

