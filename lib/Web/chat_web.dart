import 'package:ads_app/API/base.dart';
import 'package:ads_app/core/constants/app_constants.dart';
import 'package:dio/dio.dart';

class ChatWebServices {
  final Dio dio;

  ChatWebServices(this.dio);

  
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

  
  Future<Map<String, dynamic>> getOrCreateConversation() async {
    try {
      
      final response = await dio.post(BackendAPI.getConversation);
      return response.data;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  
  Future<List<dynamic>> getMessages(String conversationId) async {
    try {
      
      final response = await dio.post(
        BackendAPI.getMessages,
        data: {"conversation_id": conversationId},
      );
      return response.data is List ? response.data : [];
    } catch (e, stackTrace) {
      return [];
    }
  }

  
  Future<Map<String, dynamic>> sendMessage(String conversationId, String content) async {
    try {
      
      final response = await dio.post(
        BackendAPI.sendMessage,
        data: {
          "conversation_id": conversationId,
          "content": content,
        },
      );
      return response.data;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }

  
  Future<List<dynamic>> getAdminConversations() async {
    try {
      
      final response = await dio.get(BackendAPI.adminConversations);
      
      
      if (response.data is List) {
        return response.data;
      }
      
      
      if (response.data is Map && response.data.containsKey('data')) {
        final data = response.data['data'];
        return data is List ? data : [];
      }
      
      return [];
    } catch (e, stackTrace) {
      print("Error in getAdminConversations: $e");
      return [];
    }
  }

  
  Future<Map<String, dynamic>> assignConversation(String conversationId) async {
    try {
      
      final response = await dio.post(
        BackendAPI.assignConversation,
        data: {"conversation_id": conversationId},
      );
      return response.data;
    } catch (e, stackTrace) {
      return _handleError(e, stackTrace);
    }
  }
}

