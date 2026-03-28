import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthInterceptor extends Interceptor {
  final SharedPreferences prefs;

  AuthInterceptor(this.prefs);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    
    final session = prefs.getString("session") ?? "";
    
    
    if (session.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $session';
    }
    
    
    handler.next(options);
  }
}

class LoggerInterceptor extends Interceptor {
  Logger logger = Logger(printer: PrettyPrinter(methodCount: 0));

  @override
  void onError(final DioException err, final ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';
    
    
    String errorDetails = 'Error type: ${err.error} \n Error message: ${err.message}';
    
    if (err.response != null) {
      errorDetails += '\n STATUSCODE: ${err.response?.statusCode}';
      errorDetails += '\n STATUSMESSAGE: ${err.response?.statusMessage}';
      errorDetails += '\n HEADERS: ${err.response?.headers}';
      
      
      if (err.response?.data != null) {
        try {
          final responseData = err.response!.data;
          if (responseData is Map) {
            errorDetails += '\n Data: $responseData';
          } else {
            errorDetails += '\n Data: ${responseData.toString()}';
          }
        } catch (e) {
          errorDetails += '\n Data: (could not parse)';
        }
      }
    }
    
    logger
      ..e('${options.method} request ==> $requestPath')
      ..d(errorDetails);
    
    handler.next(err);
  }

  @override
  void onRequest(
    final RequestOptions options,
    final RequestInterceptorHandler handler,
  ) {
    final requestPath = '${options.baseUrl}${options.path}';
    logger.i('${options.method} request ==> $requestPath');
    handler.next(options);
  }

  @override
  void onResponse(
    final Response response,
    final ResponseInterceptorHandler handler,
  ) {
    logger.d(
      'STATUSCODE: ${response.statusCode} \n '
      'STATUSMESSAGE: ${response.statusMessage} \n'
      'HEADERS: ${response.headers} \n'
      'Data: ${response.data}',
    );
    handler.next(response);
  }
}
