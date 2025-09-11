import 'package:objectbox/objectbox.dart';

@Entity()
class MessageEntity {
  @Id()
  int id = 0;

  // Message content
  late String text;
  
  // Sender information
  late String senderId;
  late String senderName;
  
  // Receiver information
  late String receiverId;
  late String receiverName;
  
  // Chat/conversation ID
  late String chatId;
  
  // Message metadata
  @Index()
  @Property(type: PropertyType.date)
  late DateTime timestamp;
  
  @Index()
  late bool isRead;
  
  // Message type
  late String messageType; // 'text', 'voice', 'image', 'file'
  
  // Optional fields for different message types
  String? voiceDuration;
  String? imageUrl;
  String? fileName;
  String? fileUrl;
  
  // Message status
  late String status; // 'sent', 'delivered', 'read', 'failed'
  
  MessageEntity();
  
  MessageEntity.create({
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.chatId,
    this.messageType = 'text',
    this.voiceDuration,
    this.imageUrl,
    this.fileName,
    this.fileUrl,
    this.isRead = false,
    this.status = 'sent',
  }) {
    timestamp = DateTime.now();
  }
  
  // Helper method to check if message is from current user
  bool isFromCurrentUser(String currentUserId) {
    return senderId == currentUserId;
  }
  
  // Helper method to format timestamp
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays == 0) {
      // Same day - show time
      final hour = timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[timestamp.weekday - 1];
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
