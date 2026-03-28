import 'package:ads_app/Models/chat_models.dart';
import 'package:ads_app/Repos/chat_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo repo;
  final SharedPreferences prefs;
  Timer? _pollingTimer;
  String? _currentConversationId;
  bool _isAdmin = false;
  DateTime? _loadingStartTime;
  
  
  List<MessageModel>? _cachedMessages;
  DateTime? _lastMessagesFetch;
  String? _lastConversationId;
  bool _isLoadingMessages = false;
  
  
  List<ConversationModel>? _cachedAdminConversations;
  DateTime? _lastAdminConversationsFetch;
  
  
  int _consecutiveEmptyPolls = 0;
  static const int _maxEmptyPolls = 5; 
  
  
  static const Duration _loadingTimeout = Duration(seconds: 3);
  static const Duration _pollingInterval = Duration(seconds: 3);
  static const Duration _cacheValidity = Duration(seconds: 2); 

  ChatCubit(this.repo, this.prefs) : super(ChatInitialState()) {
    _checkAdminStatus();
    
    
    _clearCache();
    _currentConversationId = null;
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = prefs.getBool("isAdmin") ?? false;
    _isAdmin = isAdmin;
  }

  
  void _safeEmit(ChatState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  
  
  Future<void> loadConversation() async {
    if (isClosed) return;
    
    
    _clearCache();
    _currentConversationId = null;
    
    
    if (_isLoadingMessages) return;
    
    _loadingStartTime = DateTime.now();
    _safeEmit(ChatLoadingState());
    
    try {
      
      
      final conversation = await repo.getOrCreateConversation();
      
      if (conversation != null) {
        
        final currentUserId = prefs.getString("id");
        if (currentUserId != null && conversation.userId != currentUserId) {
          print("Security Warning: Conversation user ID mismatch!");
          _safeEmit(ChatErrorState("خطأ في الوصول إلى المحادثة"));
          return;
        }
        
        _currentConversationId = conversation.id;
        
        await loadMessages(conversation.id, forceRefresh: false);
      } else {
        
        final loadingDuration = DateTime.now().difference(_loadingStartTime!);
        if (loadingDuration < _loadingTimeout) {
          await Future.delayed(_loadingTimeout - loadingDuration);
        }
        
        if (!isClosed) {
          _safeEmit(ChatMessagesLoadedState(messages: []));
        }
      }
    } catch (e) {
      
      final loadingDuration = _loadingStartTime != null 
          ? DateTime.now().difference(_loadingStartTime!)
          : Duration.zero;
      
      if (loadingDuration < _loadingTimeout) {
        await Future.delayed(_loadingTimeout - loadingDuration);
      }
      
      if (isClosed) return;
      
      
      _safeEmit(ChatMessagesLoadedState(messages: []));
    }
  }

  
  Future<void> loadMessages(String conversationId, {bool forceRefresh = false}) async {
    if (isClosed) return;
    
    
    if (_isLoadingMessages && !forceRefresh) return;
    
      
      if (!forceRefresh && 
          _cachedMessages != null && 
          _lastConversationId == conversationId &&
          _lastMessagesFetch != null &&
          DateTime.now().difference(_lastMessagesFetch!) < _cacheValidity) {
        if (!isClosed) {
          _safeEmit(ChatMessagesLoadedState(messages: _cachedMessages!));
        }
        
        return;
      }
    
    _isLoadingMessages = true;
    final startTime = DateTime.now();
    
    
    if (_cachedMessages == null || forceRefresh) {
      _safeEmit(ChatLoadingState());
    }
    
    try {
      final messages = await repo.getMessages(conversationId);
      
      if (isClosed) {
        _isLoadingMessages = false;
        return;
      }
      
      _currentConversationId = conversationId;
      
      
      _cachedMessages = messages;
      _lastMessagesFetch = DateTime.now();
      _lastConversationId = conversationId;
      
      
      final apiDuration = DateTime.now().difference(startTime);
      
      
      if (messages.isEmpty && apiDuration < _loadingTimeout && _cachedMessages == null) {
        final remainingTime = _loadingTimeout - apiDuration;
        await Future.delayed(remainingTime);
      }
      
      if (isClosed) {
        _isLoadingMessages = false;
        return;
      }
      
      
      _safeEmit(ChatMessagesLoadedState(messages: messages));
      
      
      
    } catch (e) {
      if (isClosed) {
        _isLoadingMessages = false;
        return;
      }
      
      
      final apiDuration = DateTime.now().difference(startTime);
      
      if (apiDuration < _loadingTimeout && _cachedMessages == null) {
        final remainingTime = _loadingTimeout - apiDuration;
        await Future.delayed(remainingTime);
      }
      
      if (isClosed) {
        _isLoadingMessages = false;
        return;
      }
      
      
      if (_cachedMessages != null && _lastConversationId == conversationId) {
        _safeEmit(ChatMessagesLoadedState(messages: _cachedMessages!));
      } else {
        _safeEmit(ChatMessagesLoadedState(messages: []));
      }
    } finally {
      _isLoadingMessages = false;
    }
  }

  
  
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || isClosed) return;
    
    
    
    if (_currentConversationId == null) {
      try {
        final conversation = await repo.getOrCreateConversation();
        if (isClosed) return;
        
        if (conversation != null) {
          
          final currentUserId = prefs.getString("id");
          if (currentUserId != null && conversation.userId != currentUserId) {
            print("Security Warning: Cannot send message to another user's conversation!");
            _safeEmit(ChatErrorState("خطأ في الوصول إلى المحادثة"));
            return;
          }
          
          _currentConversationId = conversation.id;
        } else {
          _safeEmit(ChatErrorState("فشل في إنشاء المحادثة"));
          return;
        }
      } catch (e) {
        if (isClosed) return;
        _safeEmit(ChatErrorState("حدث خطأ: $e"));
        return;
      }
    }

    final currentState = state;
    List<MessageModel> currentMessages = [];
    
    
    if (currentState is ChatMessagesLoadedState) {
      currentMessages = List<MessageModel>.from(currentState.messages);
    } else if (currentState is ChatLoadingState || currentState is ChatErrorState) {
      currentMessages = _cachedMessages ?? [];
    }

    
    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: _currentConversationId!,
      senderId: prefs.getString("id") ?? "",
      senderType: _isAdmin ? 'admin' : 'user',
      senderName: prefs.getString("username") ?? "User",
      content: content,
      isRead: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    final updatedMessages = List<MessageModel>.from(currentMessages)..add(newMessage);
    
    
    _cachedMessages = updatedMessages;
    _lastMessagesFetch = DateTime.now();
    
    if (isClosed) return;
    _safeEmit(ChatMessagesLoadedState(messages: updatedMessages, sending: true));
    
    

    try {
      final success = await repo.sendMessage(_currentConversationId!, content);
      
      if (isClosed) return;
      
      if (success) {
        
        
        await loadMessages(_currentConversationId!, forceRefresh: true);
        
        
      } else {
        
        final messages = List<MessageModel>.from(updatedMessages);
        if (messages.isNotEmpty && messages.last.content == content) {
          messages.removeLast();
          _cachedMessages = messages;
          _safeEmit(ChatMessagesLoadedState(messages: messages));
        }
        _safeEmit(ChatErrorState("فشل في إرسال الرسالة"));
      }
    } catch (e) {
      if (isClosed) return;
      
      
      final messages = List<MessageModel>.from(updatedMessages);
      if (messages.isNotEmpty && messages.last.content == content) {
        messages.removeLast();
        _cachedMessages = messages;
        _safeEmit(ChatMessagesLoadedState(messages: messages));
      }
      _safeEmit(ChatErrorState("حدث خطأ: $e"));
    }
  }

  
  void _startPolling(String conversationId) {
    if (isClosed) return;
    
    _pollingTimer?.cancel();
    _consecutiveEmptyPolls = 0; 
    
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) async {
      
      if (isClosed) {
        timer.cancel();
        _pollingTimer = null;
        return;
      }
      
      
      if (_currentConversationId != conversationId) {
        timer.cancel();
        _pollingTimer = null;
        return;
      }
      
      
      if (_consecutiveEmptyPolls >= _maxEmptyPolls) {
        timer.cancel();
        _pollingTimer = null;
        return;
      }
      
      
      if (_isLoadingMessages) return;
      
      try {
        final messages = await repo.getMessages(conversationId);
        
        if (isClosed) {
          timer.cancel();
          _pollingTimer = null;
          return;
        }
        
        final currentState = state;
        
        if (currentState is ChatMessagesLoadedState) {
          
          final hasNewMessages = messages.length != currentState.messages.length ||
              (messages.isNotEmpty && 
               currentState.messages.isNotEmpty &&
               messages.last.id != currentState.messages.last.id);
          
          if (hasNewMessages) {
            
            _cachedMessages = messages;
            _lastMessagesFetch = DateTime.now();
            _consecutiveEmptyPolls = 0; 
            
            
            if (!currentState.sending) {
              _safeEmit(ChatMessagesLoadedState(messages: messages));
            } else {
              
              final serverMessageIds = messages.map((m) => m.id).toSet();
              final optimisticMessages = currentState.messages.where((m) => 
                !serverMessageIds.contains(m.id)
              ).toList();
              
              
              final mergedMessages = [...messages, ...optimisticMessages];
              _safeEmit(ChatMessagesLoadedState(messages: mergedMessages, sending: false));
            }
          } else {
            
            if (currentState.sending) {
              _safeEmit(ChatMessagesLoadedState(messages: currentState.messages, sending: false));
            }
            _consecutiveEmptyPolls++;
          }
        } else {
          
          _cachedMessages = messages;
          _lastMessagesFetch = DateTime.now();
          _safeEmit(ChatMessagesLoadedState(messages: messages));
        }
      } catch (e) {
        
        _consecutiveEmptyPolls++;
      }
    });
  }

  
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _consecutiveEmptyPolls = 0;
  }

  
  void _clearCache() {
    _cachedMessages = null;
    _lastMessagesFetch = null;
    _lastConversationId = null;
    
  }

  
  Future<void> loadAdminConversations({bool forceRefresh = false}) async {
    
    
    
    if (isClosed) return;
    
    
    if (!forceRefresh && 
        _cachedAdminConversations != null &&
        _lastAdminConversationsFetch != null &&
        DateTime.now().difference(_lastAdminConversationsFetch!) < Duration(minutes: 1)) {
      
      if (!isClosed) {
        _safeEmit(ChatAdminConversationsLoadedState(conversations: _cachedAdminConversations!));
      }
      
      _refreshAdminConversationsInBackground();
      return;
    }
    
    _loadingStartTime = DateTime.now();
    _safeEmit(ChatLoadingState());
    
    try {
      final conversations = await repo.getAdminConversations();
      
      if (isClosed) return;
      
      print("ChatCubit: Loaded ${conversations.length} conversations");
      
      
      _cachedAdminConversations = conversations;
      _lastAdminConversationsFetch = DateTime.now();
      
      
      _isAdmin = true;
      prefs.setBool("isAdmin", true);
      
      
      final loadingDuration = _loadingStartTime != null 
          ? DateTime.now().difference(_loadingStartTime!)
          : Duration.zero;
      
      
      if (conversations.isNotEmpty) {
        print("ChatCubit: Emitting ChatAdminConversationsLoadedState with ${conversations.length} conversations");
        _safeEmit(ChatAdminConversationsLoadedState(conversations: conversations));
        return;
      }
      
      
      if (loadingDuration < _loadingTimeout) {
        await Future.delayed(_loadingTimeout - loadingDuration);
      }
      
      if (isClosed) return;
      
      print("ChatCubit: Emitting ChatAdminConversationsLoadedState with empty list");
      _safeEmit(ChatAdminConversationsLoadedState(conversations: conversations));
    } catch (e) {
      print("Error loading admin conversations: $e");
      
      if (isClosed) return;
      
      
      if (_cachedAdminConversations != null && _cachedAdminConversations!.isNotEmpty) {
        _safeEmit(ChatAdminConversationsLoadedState(conversations: _cachedAdminConversations!));
        return;
      }
      
      
      
      _isAdmin = false;
      prefs.setBool("isAdmin", false);
      
      
      final loadingDuration = _loadingStartTime != null 
          ? DateTime.now().difference(_loadingStartTime!)
          : Duration.zero;
      
      if (loadingDuration < _loadingTimeout) {
        await Future.delayed(_loadingTimeout - loadingDuration);
      }
      
      if (isClosed) return;
      
      _safeEmit(ChatAdminConversationsLoadedState(conversations: []));
    }
  }
  
  
  Future<void> _refreshAdminConversationsInBackground() async {
    if (isClosed) return;
    
    try {
      final conversations = await repo.getAdminConversations();
      
      if (isClosed) return;
      
      
      _cachedAdminConversations = conversations;
      _lastAdminConversationsFetch = DateTime.now();
      
      
      final currentState = state;
      if (currentState is ChatAdminConversationsLoadedState) {
        _safeEmit(ChatAdminConversationsLoadedState(conversations: conversations));
      }
    } catch (e) {
      
      print("Background refresh failed: $e");
    }
  }

  
  Future<void> loadAdminConversationMessages(String conversationId) async {
    
    if (_lastConversationId != conversationId) {
      _clearCache();
    }
    await loadMessages(conversationId, forceRefresh: false);
  }

  
  Future<void> assignConversation(String conversationId) async {
    if (!_isAdmin || isClosed) return;
    
    try {
      final success = await repo.assignConversation(conversationId);
      if (isClosed) return;
      
      if (success) {
        await loadAdminConversations(); 
      }
    } catch (e) {
      if (isClosed) return;
      _safeEmit(ChatErrorState("فشل في تعيين المحادثة"));
    }
  }

  @override
  Future<void> close() {
    stopPolling();
    _clearCache();
    return super.close();
  }
}
