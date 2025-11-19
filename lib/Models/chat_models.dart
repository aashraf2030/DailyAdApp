class ConversationModel {
  final String id;
  final String userId;
  final String? adminId;
  final String subject;
  final int unreadCount;
  final MessageModel? lastMessage;
  final String? userName;
  final String? userEmail;
  final String? adminName;
  final String? lastMessageAt;
  final String createdAt;

  ConversationModel({
    required this.id,
    required this.userId,
    this.adminId,
    required this.subject,
    required this.unreadCount,
    this.lastMessage,
    this.userName,
    this.userEmail,
    this.adminName,
    this.lastMessageAt,
    required this.createdAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    try {
      return ConversationModel(
        id: json["id"]?.toString() ?? "",
        userId: json["user_id"]?.toString() ?? json["userId"]?.toString() ?? "",
        adminId: json["admin_id"]?.toString() ?? json["adminId"]?.toString(),
        subject: json["subject"]?.toString() ?? "دردشة مع الإدارة",
        unreadCount: (json["unread_count"] ?? json["unreadCount"] ?? 0) as int,
        lastMessage: json["last_message"] != null && json["last_message"] is Map
            ? MessageModel.fromJson(json["last_message"] as Map<String, dynamic>)
            : null,
        userName: json["user_name"]?.toString() ?? json["userName"]?.toString(),
        userEmail: json["user_email"]?.toString() ?? json["userEmail"]?.toString(),
        adminName: json["admin_name"]?.toString() ?? json["adminName"]?.toString(),
        lastMessageAt: json["last_message_at"]?.toString() ?? json["lastMessageAt"]?.toString(),
        createdAt: json["created_at"]?.toString() ?? json["createdAt"]?.toString() ?? "",
      );
    } catch (e) {
      print("Error parsing ConversationModel: $e");
      print("JSON data: $json");
      rethrow;
    }
  }
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderType; // 'user' or 'admin'
  final String senderName;
  final String content;
  final bool isRead;
  final String createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    required this.senderName,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    try {
      return MessageModel(
        id: json["id"]?.toString() ?? "",
        conversationId: json["conversation_id"]?.toString() ?? json["conversationId"]?.toString() ?? "",
        senderId: json["sender_id"]?.toString() ?? json["senderId"]?.toString() ?? "",
        senderType: json["sender_type"]?.toString() ?? json["senderType"]?.toString() ?? "user",
        senderName: json["sender_name"]?.toString() ?? json["senderName"]?.toString() ?? "Unknown",
        content: json["content"]?.toString() ?? "",
        isRead: (json["is_read"] ?? json["isRead"] ?? false) as bool,
        createdAt: json["created_at"]?.toString() ?? json["createdAt"]?.toString() ?? "",
      );
    } catch (e) {
      print("Error parsing MessageModel: $e");
      print("JSON data: $json");
      rethrow;
    }
  }

  bool get isFromUser => senderType == 'user';
  bool get isFromAdmin => senderType == 'admin';
}

