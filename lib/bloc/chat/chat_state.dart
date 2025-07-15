class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}

class Chat {
  final String id;
  final String rideId;
  final List<String> participantIds;
  final List<String> participantNames;
  final ChatMessage? lastMessage;
  final int unreadCount;

  Chat({
    required this.id,
    required this.rideId,
    required this.participantIds,
    required this.participantNames,
    this.lastMessage,
    this.unreadCount = 0,
  });
}

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatsLoaded extends ChatState {
  final List<Chat> chats;
  
  ChatsLoaded({required this.chats});
}

class MessagesLoaded extends ChatState {
  final String chatId;
  final List<ChatMessage> messages;
  
  MessagesLoaded({
    required this.chatId,
    required this.messages,
  });
}

class MessageSent extends ChatState {
  final ChatMessage message;
  
  MessageSent({required this.message});
}

class ChatCreated extends ChatState {
  final Chat chat;
  
  ChatCreated({required this.chat});
}

class ChatError extends ChatState {
  final String message;
  
  ChatError({required this.message});
}
