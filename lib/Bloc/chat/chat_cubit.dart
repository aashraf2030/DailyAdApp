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
  
  // Caching
  List<MessageModel>? _cachedMessages;
  DateTime? _lastMessagesFetch;
  String? _lastConversationId;
  bool _isLoadingMessages = false;
  
  // Cache for admin conversations
  List<ConversationModel>? _cachedAdminConversations;
  DateTime? _lastAdminConversationsFetch;
  
  // Polling optimization
  int _consecutiveEmptyPolls = 0;
  static const int _maxEmptyPolls = 5; // Stop polling after 5 empty checks (15 seconds)
  
  // Timeouts and intervals
  static const Duration _loadingTimeout = Duration(seconds: 3);
  static const Duration _pollingInterval = Duration(seconds: 3);
  static const Duration _cacheValidity = Duration(seconds: 2); // Cache valid for 2 seconds

  ChatCubit(this.repo, this.prefs) : super(ChatInitialState()) {
    _checkAdminStatus();
    // Clear any cached conversation when cubit is created
    // This ensures each user gets their own conversation
    _clearCache();
    _currentConversationId = null;
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = prefs.getBool("isAdmin") ?? false;
    _isAdmin = isAdmin;
  }

  /// Safe emit - checks if cubit is closed before emitting
  void _safeEmit(ChatState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  /// Get or create conversation for user
  /// This always gets the conversation for the currently authenticated user
  Future<void> loadConversation() async {
    if (isClosed) return;
    
    // Clear cache to ensure we get fresh data for the current user
    _clearCache();
    _currentConversationId = null;
    
    // Prevent duplicate calls
    if (_isLoadingMessages) return;
    
    _loadingStartTime = DateTime.now();
    _safeEmit(ChatLoadingState());
    
    try {
      // This will always get/create conversation for the authenticated user
      // The backend uses the JWT token to identify the user
      final conversation = await repo.getOrCreateConversation();
      
      if (conversation != null) {
        // Verify conversation belongs to current user (extra security check)
        final currentUserId = prefs.getString("id");
        if (currentUserId != null && conversation.userId != currentUserId) {
          print("Security Warning: Conversation user ID mismatch!");
          _safeEmit(ChatErrorState("خطأ في الوصول إلى المحادثة"));
          return;
        }
        
        _currentConversationId = conversation.id;
        // loadMessages will emit ChatMessagesLoadedState
        await loadMessages(conversation.id, forceRefresh: false);
      } else {
        // If no conversation, wait for timeout then show empty state
        final loadingDuration = DateTime.now().difference(_loadingStartTime!);
        if (loadingDuration < _loadingTimeout) {
          await Future.delayed(_loadingTimeout - loadingDuration);
        }
        // Show empty state so user can send messages
        if (!isClosed) {
          _safeEmit(ChatMessagesLoadedState(messages: []));
        }
      }
    } catch (e) {
      // After timeout, show error state
      final loadingDuration = _loadingStartTime != null 
          ? DateTime.now().difference(_loadingStartTime!)
          : Duration.zero;
      
      if (loadingDuration < _loadingTimeout) {
        await Future.delayed(_loadingTimeout - loadingDuration);
      }
      
      if (isClosed) return;
      
      // Show empty state so user can still send messages
      _safeEmit(ChatMessagesLoadedState(messages: []));
    }
  }

  /// Load messages for a conversation with caching and optimization
  Future<void> loadMessages(String conversationId, {bool forceRefresh = false}) async {
    if (isClosed) return;
    
    // Prevent duplicate calls
    if (_isLoadingMessages && !forceRefresh) return;
    
      // Check cache first (if same conversation and cache is still valid)
      if (!forceRefresh && 
          _cachedMessages != null && 
          _lastConversationId == conversationId &&
          _lastMessagesFetch != null &&
          DateTime.now().difference(_lastMessagesFetch!) < _cacheValidity) {
        if (!isClosed) {
          _safeEmit(ChatMessagesLoadedState(messages: _cachedMessages!));
        }
        // لا نبدأ polling تلقائياً - فقط عند الحاجة
        return;
      }
    
    _isLoadingMessages = true;
    final startTime = DateTime.now();
    
    // Only show loading if we don't have cached messages
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
      
      // Update cache
      _cachedMessages = messages;
      _lastMessagesFetch = DateTime.now();
      _lastConversationId = conversationId;
      
      // Calculate how long the API call took
      final apiDuration = DateTime.now().difference(startTime);
      
      // If API was fast and no messages, wait to show skeleton for at least 3 seconds
      if (messages.isEmpty && apiDuration < _loadingTimeout && _cachedMessages == null) {
        final remainingTime = _loadingTimeout - apiDuration;
        await Future.delayed(remainingTime);
      }
      
      if (isClosed) {
        _isLoadingMessages = false;
        return;
      }
      
      // Always emit ChatMessagesLoadedState (even with empty list) so user can send messages
      _safeEmit(ChatMessagesLoadedState(messages: messages));
      
      // لا نبدأ polling تلقائياً - فقط عند الحاجة (مثل بعد إرسال رسالة)
      // هذا يمنع الاستعلامات المتكررة غير الضرورية
    } catch (e) {
      if (isClosed) {
        _isLoadingMessages = false;
        return;
      }
      
      // If API call failed, wait for timeout then show empty state
      final apiDuration = DateTime.now().difference(startTime);
      
      if (apiDuration < _loadingTimeout && _cachedMessages == null) {
        final remainingTime = _loadingTimeout - apiDuration;
        await Future.delayed(remainingTime);
      }
      
      if (isClosed) {
        _isLoadingMessages = false;
        return;
      }
      
      // Show cached messages if available, otherwise empty
      if (_cachedMessages != null && _lastConversationId == conversationId) {
        _safeEmit(ChatMessagesLoadedState(messages: _cachedMessages!));
      } else {
        _safeEmit(ChatMessagesLoadedState(messages: []));
      }
    } finally {
      _isLoadingMessages = false;
    }
  }

  /// Send a message (optimized - doesn't reload all messages)
  /// This always sends to the current user's conversation
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || isClosed) return;
    
    // If no conversation ID, try to get/create one first
    // This will always get/create the conversation for the authenticated user
    if (_currentConversationId == null) {
      try {
        final conversation = await repo.getOrCreateConversation();
        if (isClosed) return;
        
        if (conversation != null) {
          // Security check: Verify conversation belongs to current user
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
    
    // Get current messages if available
    if (currentState is ChatMessagesLoadedState) {
      currentMessages = List<MessageModel>.from(currentState.messages);
    } else if (currentState is ChatLoadingState || currentState is ChatErrorState) {
      currentMessages = _cachedMessages ?? [];
    }

    // Add message optimistically
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
    
    // Update cache
    _cachedMessages = updatedMessages;
    _lastMessagesFetch = DateTime.now();
    
    if (isClosed) return;
    _safeEmit(ChatMessagesLoadedState(messages: updatedMessages, sending: true));
    
    // لا نبدأ polling تلقائياً - فقط نحدث الرسائل بعد الإرسال

    try {
      final success = await repo.sendMessage(_currentConversationId!, content);
      
      if (isClosed) return;
      
      if (success) {
        // Message sent successfully - reload messages once to get server response
        // ثم نتوقف - لا polling مستمر
        await loadMessages(_currentConversationId!, forceRefresh: true);
        
        // لا نبدأ polling - فقط جلب الرسائل مرة واحدة
      } else {
        // Remove optimistic message on failure
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
      
      // Remove optimistic message on error
      final messages = List<MessageModel>.from(updatedMessages);
      if (messages.isNotEmpty && messages.last.content == content) {
        messages.removeLast();
        _cachedMessages = messages;
        _safeEmit(ChatMessagesLoadedState(messages: messages));
      }
      _safeEmit(ChatErrorState("حدث خطأ: $e"));
    }
  }

  /// Optimized polling - stops after consecutive empty checks
  void _startPolling(String conversationId) {
    if (isClosed) return;
    
    _pollingTimer?.cancel();
    _consecutiveEmptyPolls = 0; // Reset counter
    
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) async {
      // Stop polling if cubit is closed
      if (isClosed) {
        timer.cancel();
        _pollingTimer = null;
        return;
      }
      
      // Stop polling if conversation changed
      if (_currentConversationId != conversationId) {
        timer.cancel();
        _pollingTimer = null;
        return;
      }
      
      // Stop polling after too many empty checks
      if (_consecutiveEmptyPolls >= _maxEmptyPolls) {
        timer.cancel();
        _pollingTimer = null;
        return;
      }
      
      // Prevent polling if already loading
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
          // Check if there are new messages (compare by length and last message ID)
          final hasNewMessages = messages.length != currentState.messages.length ||
              (messages.isNotEmpty && 
               currentState.messages.isNotEmpty &&
               messages.last.id != currentState.messages.last.id);
          
          if (hasNewMessages) {
            // Update cache
            _cachedMessages = messages;
            _lastMessagesFetch = DateTime.now();
            _consecutiveEmptyPolls = 0; // Reset counter
            
            // currentState is already ChatMessagesLoadedState (checked above)
            if (!currentState.sending) {
              _safeEmit(ChatMessagesLoadedState(messages: messages));
            } else {
              // If sending, merge optimistic message with server messages
              final serverMessageIds = messages.map((m) => m.id).toSet();
              final optimisticMessages = currentState.messages.where((m) => 
                !serverMessageIds.contains(m.id)
              ).toList();
              
              // Combine server messages with any optimistic messages not yet on server
              final mergedMessages = [...messages, ...optimisticMessages];
              _safeEmit(ChatMessagesLoadedState(messages: mergedMessages, sending: false));
            }
          } else {
            // No new messages - but if we're in sending state, mark as done
            if (currentState.sending) {
              _safeEmit(ChatMessagesLoadedState(messages: currentState.messages, sending: false));
            }
            _consecutiveEmptyPolls++;
          }
        } else {
          // If state is not ChatMessagesLoadedState, update anyway
          _cachedMessages = messages;
          _lastMessagesFetch = DateTime.now();
          _safeEmit(ChatMessagesLoadedState(messages: messages));
        }
      } catch (e) {
        // Silent fail for polling - increment counter
        _consecutiveEmptyPolls++;
      }
    });
  }

  /// Stop polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _consecutiveEmptyPolls = 0;
  }

  /// Clear cache (useful when switching conversations)
  void _clearCache() {
    _cachedMessages = null;
    _lastMessagesFetch = null;
    _lastConversationId = null;
    // Don't clear admin conversations cache - keep it for back navigation
  }

  /// Load admin conversations list
  Future<void> loadAdminConversations({bool forceRefresh = false}) async {
    // Always try to load - let the API handle authorization
    // Don't block based on _isAdmin cache which might be stale
    
    if (isClosed) return;
    
    // Check cache first (if cache is still valid and not forcing refresh)
    if (!forceRefresh && 
        _cachedAdminConversations != null &&
        _lastAdminConversationsFetch != null &&
        DateTime.now().difference(_lastAdminConversationsFetch!) < Duration(minutes: 1)) {
      // Show cached conversations immediately
      if (!isClosed) {
        _safeEmit(ChatAdminConversationsLoadedState(conversations: _cachedAdminConversations!));
      }
      // Still refresh in background
      _refreshAdminConversationsInBackground();
      return;
    }
    
    _loadingStartTime = DateTime.now();
    _safeEmit(ChatLoadingState());
    
    try {
      final conversations = await repo.getAdminConversations();
      
      if (isClosed) return;
      
      print("ChatCubit: Loaded ${conversations.length} conversations");
      
      // Update cache
      _cachedAdminConversations = conversations;
      _lastAdminConversationsFetch = DateTime.now();
      
      // Update _isAdmin based on successful API call
      _isAdmin = true;
      prefs.setBool("isAdmin", true);
      
      // Check if loading took more than timeout
      final loadingDuration = _loadingStartTime != null 
          ? DateTime.now().difference(_loadingStartTime!)
          : Duration.zero;
      
      // Don't wait if we have data - show it immediately
      if (conversations.isNotEmpty) {
        print("ChatCubit: Emitting ChatAdminConversationsLoadedState with ${conversations.length} conversations");
        _safeEmit(ChatAdminConversationsLoadedState(conversations: conversations));
        return;
      }
      
      // Only wait for timeout if no conversations
      if (loadingDuration < _loadingTimeout) {
        await Future.delayed(_loadingTimeout - loadingDuration);
      }
      
      if (isClosed) return;
      
      print("ChatCubit: Emitting ChatAdminConversationsLoadedState with empty list");
      _safeEmit(ChatAdminConversationsLoadedState(conversations: conversations));
    } catch (e) {
      print("Error loading admin conversations: $e");
      
      if (isClosed) return;
      
      // If we have cached conversations, show them even on error
      if (_cachedAdminConversations != null && _cachedAdminConversations!.isNotEmpty) {
        _safeEmit(ChatAdminConversationsLoadedState(conversations: _cachedAdminConversations!));
        return;
      }
      
      // If API call fails, might be because user is not admin
      // But don't block - let the error state show
      _isAdmin = false;
      prefs.setBool("isAdmin", false);
      
      // After timeout, show empty state
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
  
  /// Refresh admin conversations in background (without showing loading)
  Future<void> _refreshAdminConversationsInBackground() async {
    if (isClosed) return;
    
    try {
      final conversations = await repo.getAdminConversations();
      
      if (isClosed) return;
      
      // Update cache
      _cachedAdminConversations = conversations;
      _lastAdminConversationsFetch = DateTime.now();
      
      // Only emit if state is still ChatAdminConversationsLoadedState
      final currentState = state;
      if (currentState is ChatAdminConversationsLoadedState) {
        _safeEmit(ChatAdminConversationsLoadedState(conversations: conversations));
      }
    } catch (e) {
      // Silent fail for background refresh
      print("Background refresh failed: $e");
    }
  }

  /// Load messages for admin conversation
  Future<void> loadAdminConversationMessages(String conversationId) async {
    // Clear cache when switching conversations
    if (_lastConversationId != conversationId) {
      _clearCache();
    }
    await loadMessages(conversationId, forceRefresh: false);
  }

  /// Assign conversation to current admin
  Future<void> assignConversation(String conversationId) async {
    if (!_isAdmin || isClosed) return;
    
    try {
      final success = await repo.assignConversation(conversationId);
      if (isClosed) return;
      
      if (success) {
        await loadAdminConversations(); // Refresh list
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
