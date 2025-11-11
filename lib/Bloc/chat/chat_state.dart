import 'package:equatable/equatable.dart';
import '../../Models/chat_message.dart';

class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool sending;
  final String? error;

  const ChatState({this.messages = const [], this.sending = false, this.error});

  ChatState copyWith(
      {List<ChatMessage>? messages, bool? sending, String? error}) {
    return ChatState(
      messages: messages ?? this.messages,
      sending: sending ?? this.sending,
      error: error,
    );
  }

  @override
  List<Object?> get props => [messages, sending, error];
}
