abstract class ChatEvent {}

class LoadChatsEvent extends ChatEvent {}

class LoadMessagesEvent extends ChatEvent {
  final String chatId;
  
  LoadMessagesEvent({required this.chatId});
}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final String message;
  final String senderId;
  
  SendMessageEvent({
    required this.chatId,
    required this.message,
    required this.senderId,
  });
}

class CreateChatEvent extends ChatEvent {
  final String participantId;
  final String rideId;
  
  CreateChatEvent({
    required this.participantId,
    required this.rideId,
  });
}

class MarkMessageAsReadEvent extends ChatEvent {
  final String chatId;
  final String messageId;
  
  MarkMessageAsReadEvent({
    required this.chatId,
    required this.messageId,
  });
}
