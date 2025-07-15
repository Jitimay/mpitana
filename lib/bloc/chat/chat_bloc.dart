import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  // In a real app, you'd have a repository for chat data
  final List<Chat> _chats = [];
  final Map<String, List<ChatMessage>> _messages = {};

  ChatBloc() : super(ChatInitial()) {
    on<LoadChatsEvent>(_onLoadChats);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<CreateChatEvent>(_onCreateChat);
    on<MarkMessageAsReadEvent>(_onMarkMessageAsRead);
  }

  Future<void> _onLoadChats(LoadChatsEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: Replace with actual API call to load chats
      emit(ChatsLoaded(chats: List.from(_chats)));
    } catch (e) {
      emit(ChatError(message: 'Failed to load chats: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final messages = _messages[event.chatId] ?? [];
      emit(MessagesLoaded(
        chatId: event.chatId,
        messages: List.from(messages),
      ));
    } catch (e) {
      emit(ChatError(message: 'Failed to load messages: ${e.toString()}'));
    }
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: event.chatId,
        senderId: event.senderId,
        senderName: 'Current User', // TODO: Get from auth state
        message: event.message,
        timestamp: DateTime.now(),
      );

      // Add message to local storage
      if (_messages[event.chatId] == null) {
        _messages[event.chatId] = [];
      }
      _messages[event.chatId]!.add(message);

      // Update chat's last message
      final chatIndex = _chats.indexWhere((chat) => chat.id == event.chatId);
      if (chatIndex != -1) {
        final updatedChat = Chat(
          id: _chats[chatIndex].id,
          rideId: _chats[chatIndex].rideId,
          participantIds: _chats[chatIndex].participantIds,
          participantNames: _chats[chatIndex].participantNames,
          lastMessage: message,
          unreadCount: _chats[chatIndex].unreadCount,
        );
        _chats[chatIndex] = updatedChat;
      }

      emit(MessageSent(message: message));
      
      // Also emit updated messages
      emit(MessagesLoaded(
        chatId: event.chatId,
        messages: List.from(_messages[event.chatId]!),
      ));
    } catch (e) {
      emit(ChatError(message: 'Failed to send message: ${e.toString()}'));
    }
  }

  Future<void> _onCreateChat(CreateChatEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      final chat = Chat(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        rideId: event.rideId,
        participantIds: ['current_user_id', event.participantId],
        participantNames: ['You', 'Other User'], // TODO: Get actual names
      );

      _chats.add(chat);
      _messages[chat.id] = [];

      emit(ChatCreated(chat: chat));
      
      // Also emit updated chats list
      emit(ChatsLoaded(chats: List.from(_chats)));
    } catch (e) {
      emit(ChatError(message: 'Failed to create chat: ${e.toString()}'));
    }
  }

  Future<void> _onMarkMessageAsRead(MarkMessageAsReadEvent event, Emitter<ChatState> emit) async {
    try {
      // TODO: Implement mark as read functionality
      // This would typically update the message in the database
      
      // For now, just emit success
      final messages = _messages[event.chatId] ?? [];
      emit(MessagesLoaded(
        chatId: event.chatId,
        messages: List.from(messages),
      ));
    } catch (e) {
      emit(ChatError(message: 'Failed to mark message as read: ${e.toString()}'));
    }
  }
}
