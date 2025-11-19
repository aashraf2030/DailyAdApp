import 'package:ads_app/Models/chat_models.dart';
import 'package:ads_app/Web/chat_web.dart';

class ChatRepo {
  final ChatWebServices web;

  ChatRepo(this.web);

  Future<ConversationModel?> getOrCreateConversation() async {
    final response = await web.getOrCreateConversation();
    
    if (response['status'] == 'Success' && response['data'] != null) {
      return ConversationModel.fromJson(response['data']);
    }
    return null;
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    final response = await web.getMessages(conversationId);
    return response.map((x) => MessageModel.fromJson(x)).toList();
  }

  Future<bool> sendMessage(String conversationId, String content) async {
    final response = await web.sendMessage(conversationId, content);
    return response['status'] == 'Success';
  }

  Future<List<ConversationModel>> getAdminConversations() async {
    final response = await web.getAdminConversations();
    print("ChatRepo: getAdminConversations response length: ${response.length}");
    if (response.isNotEmpty) {
      print("ChatRepo: First conversation: ${response[0]}");
    }
    try {
      return response.map((x) => ConversationModel.fromJson(x)).toList();
    } catch (e) {
      print("ChatRepo: Error parsing conversations: $e");
      return [];
    }
  }

  Future<bool> assignConversation(String conversationId) async {
    final response = await web.assignConversation(conversationId);
    return response['status'] == 'Success';
  }
}

