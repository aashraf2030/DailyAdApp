import 'package:ads_app/Models/chat_models.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitialState extends ChatState {}

class ChatLoadingState extends ChatState {}

class ChatLoadedState extends ChatState {
  final ConversationModel conversation;

  ChatLoadedState({required this.conversation});

  @override
  List<Object?> get props => [conversation];
}

class ChatMessagesLoadedState extends ChatState {
  final List<MessageModel> messages;
  final bool sending;

  ChatMessagesLoadedState({required this.messages, this.sending = false});

  @override
  List<Object?> get props => [messages, sending];
}

class ChatAdminConversationsLoadedState extends ChatState {
  final List<ConversationModel> conversations;

  ChatAdminConversationsLoadedState({required this.conversations});

  @override
  List<Object?> get props => [conversations];
}

class ChatErrorState extends ChatState {
  final String message;

  ChatErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
