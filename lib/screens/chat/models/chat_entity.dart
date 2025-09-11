import 'package:objectbox/objectbox.dart';

@Entity()
class ChatEntity {
  @Id()
  int id = 0;

  // Unique chat identifier
  @Unique()
  late String chatId;
  
  // Participants
  late String participant1Id;
  late String participant1Name;
  late String participant2Id;
  late String participant2Name;
  
  // Last message info
  String? lastMessage;
  String? lastMessageSenderId;
  
  @Property(type: PropertyType.date)
  DateTime? lastMessageTime;
  
  // Chat metadata
  @Index()
  @Property(type: PropertyType.date)
  late DateTime createdAt;
  
  @Property(type: PropertyType.date)
  DateTime? updatedAt;
  
  // Unread count for each participant
  late int unreadCountParticipant1;
  late int unreadCountParticipant2;
  
  // Chat status
  late bool isActive;
  
  ChatEntity();
  
  ChatEntity.create({
    required this.chatId,
    required this.participant1Id,
    required this.participant1Name,
    required this.participant2Id,
    required this.participant2Name,
    this.unreadCountParticipant1 = 0,
    this.unreadCountParticipant2 = 0,
    this.isActive = true,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }
  
  // Helper method to get other participant's info
  Map<String, String> getOtherParticipant(String currentUserId) {
    if (participant1Id == currentUserId) {
      return {
        'id': participant2Id,
        'name': participant2Name,
      };
    } else {
      return {
        'id': participant1Id,
        'name': participant1Name,
      };
    }
  }
  
  // Helper method to get unread count for current user
  int getUnreadCount(String currentUserId) {
    if (participant1Id == currentUserId) {
      return unreadCountParticipant1;
    } else {
      return unreadCountParticipant2;
    }
  }
  
  // Helper method to update last message
  void updateLastMessage(String message, String senderId) {
    lastMessage = message;
    lastMessageSenderId = senderId;
    lastMessageTime = DateTime.now();
    updatedAt = DateTime.now();
  }
  
  // Helper method to increment unread count
  void incrementUnreadCount(String forUserId) {
    if (participant1Id == forUserId) {
      unreadCountParticipant1++;
    } else {
      unreadCountParticipant2++;
    }
    updatedAt = DateTime.now();
  }
  
  // Helper method to reset unread count
  void resetUnreadCount(String forUserId) {
    if (participant1Id == forUserId) {
      unreadCountParticipant1 = 0;
    } else {
      unreadCountParticipant2 = 0;
    }
    updatedAt = DateTime.now();
  }
}
