enum ChatRole { user, assistant, system }

class ChatMessage {
  final ChatRole role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        "role": role.name,
        "content": content,
      };

  static ChatMessage fromJson(Map<String, dynamic> j) => ChatMessage(
        role: ChatRole.values.firstWhere((r) => r.name == j["role"],
            orElse: () => ChatRole.assistant),
        content: j["content"] ?? "",
      );
}
