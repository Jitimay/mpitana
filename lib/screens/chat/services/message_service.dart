// import 'package:mpitana/common/database/objectbox_db.dart';
// import 'package:mpitana/screens/chat/models/message_entity.dart';
// import 'package:mpitana/screens/chat/models/chat_entity.dart';
// import 'package:objectbox/objectbox.dart';
//
// import '../../../objectbox.g.dart';
//
// class MessageService {
//   static final MessageService _instance = MessageService._internal();
//   factory MessageService() => _instance;
//   MessageService._internal();
//
//   // Get ObjectBox store
//   Store get _store => ObjectBoxDb.instance.store;
//
//   // Get message box
//   Box<MessageEntity> get _messageBox => _store.box<MessageEntity>();
//
//   // Get chat box
//   Box<ChatEntity> get _chatBox => _store.box<ChatEntity>();
//
//   // Send a message
//   Future<MessageEntity> sendMessage({
//     required String text,
//     required String senderId,
//     required String senderName,
//     required String receiverId,
//     required String receiverName,
//     String messageType = 'text',
//     String? voiceDuration,
//     String? imageUrl,
//     String? fileName,
//     String? fileUrl,
//   }) async {
//     try {
//       // Generate or get chat ID
//       final chatId = _generateChatId(senderId, receiverId);
//
//       // Create message entity
//       final message = MessageEntity.create(
//         text: text,
//         senderId: senderId,
//         senderName: senderName,
//         receiverId: receiverId,
//         receiverName: receiverName,
//         chatId: chatId,
//         messageType: messageType,
//         voiceDuration: voiceDuration,
//         imageUrl: imageUrl,
//         fileName: fileName,
//         fileUrl: fileUrl,
//       );
//
//       // Save message to database
//       _messageBox.put(message);
//
//       // Update or create chat
//       await _updateChat(
//         chatId: chatId,
//         participant1Id: senderId,
//         participant1Name: senderName,
//         participant2Id: receiverId,
//         participant2Name: receiverName,
//         lastMessage: text,
//         lastMessageSenderId: senderId,
//       );
//
//       return message;
//     } catch (e) {
//       throw Exception('Failed to send message: $e');
//     }
//   }
//
//   // Get messages for a chat
//   List<MessageEntity> getMessagesForChat(String chatId) {
//     try {
//       final query = _messageBox.query(MessageEntity_.chatId.equals(chatId))
//           .order(MessageEntity_.timestamp, flags: Order.descending)
//           .build();
//
//       final messages = query.find();
//       query.close();
//
//       return messages;
//     } catch (e) {
//       throw Exception('Failed to get messages: $e');
//     }
//   }
//
//   // Get all chats for a user
//   List<ChatEntity> getChatsForUser(String userId) {
//     try {
//       final query = _chatBox.query(
//         ChatEntity_.participant1Id.equals(userId)
//             .or(ChatEntity_.participant2Id.equals(userId))
//       ).order(ChatEntity_.updatedAt, flags: Order.descending).build();
//
//       final chats = query.find();
//       query.close();
//
//       return chats;
//     } catch (e) {
//       throw Exception('Failed to get chats: $e');
//     }
//   }
//
//   // Mark messages as read
//   Future<void> markMessagesAsRead(String chatId, String userId) async {
//     try {
//       final query = _messageBox.query(
//         MessageEntity_.chatId.equals(chatId)
//             .and(MessageEntity_.receiverId.equals(userId))
//             .and(MessageEntity_.isRead.equals(false))
//       ).build();
//
//       final messages = query.find();
//       query.close();
//
//       for (final message in messages) {
//         message.isRead = true;
//         message.status = 'read';
//       }
//
//       _messageBox.putMany(messages);
//
//       // Update chat unread count
//       final chat = getChatById(chatId);
//       if (chat != null) {
//         chat.resetUnreadCount(userId);
//         _chatBox.put(chat);
//       }
//     } catch (e) {
//       throw Exception('Failed to mark messages as read: $e');
//     }
//   }
//
//   // Get chat by ID
//   ChatEntity? getChatById(String chatId) {
//     try {
//       final query = _chatBox.query(ChatEntity_.chatId.equals(chatId)).build();
//       final chat = query.findFirst();
//       query.close();
//       return chat;
//     } catch (e) {
//       return null;
//     }
//   }
//
//   // Get or create chat between two users
//   Future<ChatEntity> getOrCreateChat({
//     required String user1Id,
//     required String user1Name,
//     required String user2Id,
//     required String user2Name,
//   }) async {
//     try {
//       final chatId = _generateChatId(user1Id, user2Id);
//
//       // Try to find existing chat
//       ChatEntity? existingChat = getChatById(chatId);
//
//       if (existingChat != null) {
//         return existingChat;
//       }
//
//       // Create new chat
//       final newChat = ChatEntity.create(
//         chatId: chatId,
//         participant1Id: user1Id,
//         participant1Name: user1Name,
//         participant2Id: user2Id,
//         participant2Name: user2Name,
//       );
//
//       _chatBox.put(newChat);
//       return newChat;
//     } catch (e) {
//       throw Exception('Failed to get or create chat: $e');
//     }
//   }
//
//   // Delete a message
//   Future<void> deleteMessage(int messageId) async {
//     try {
//       _messageBox.remove(messageId);
//     } catch (e) {
//       throw Exception('Failed to delete message: $e');
//     }
//   }
//
//   // Delete a chat and all its messages
//   Future<void> deleteChat(String chatId) async {
//     try {
//       // Delete all messages in the chat
//       final messageQuery = _messageBox.query(MessageEntity_.chatId.equals(chatId)).build();
//       final messages = messageQuery.find();
//       messageQuery.close();
//
//       for (final message in messages) {
//         _messageBox.remove(message.id);
//       }
//
//       // Delete the chat
//       final chatQuery = _chatBox.query(ChatEntity_.chatId.equals(chatId)).build();
//       final chat = chatQuery.findFirst();
//       chatQuery.close();
//
//       if (chat != null) {
//         _chatBox.remove(chat.id);
//       }
//     } catch (e) {
//       throw Exception('Failed to delete chat: $e');
//     }
//   }
//
//   // Search messages
//   List<MessageEntity> searchMessages(String searchTerm, String userId) {
//     try {
//       final query = _messageBox.query(
//         MessageEntity_.text.contains(searchTerm, caseSensitive: false)
//             .and(MessageEntity_.senderId.equals(userId)
//                 .or(MessageEntity_.receiverId.equals(userId)))
//       ).order(MessageEntity_.timestamp, flags: Order.descending).build();
//
//       final messages = query.find();
//       query.close();
//
//       return messages;
//     } catch (e) {
//       throw Exception('Failed to search messages: $e');
//     }
//   }
//
//   // Private helper methods
//   String _generateChatId(String user1Id, String user2Id) {
//     // Create consistent chat ID regardless of user order
//     final sortedIds = [user1Id, user2Id]..sort();
//     return '${sortedIds[0]}_${sortedIds[1]}';
//   }
//
//   Future<void> _updateChat({
//     required String chatId,
//     required String participant1Id,
//     required String participant1Name,
//     required String participant2Id,
//     required String participant2Name,
//     required String lastMessage,
//     required String lastMessageSenderId,
//   }) async {
//     try {
//       ChatEntity? existingChat = getChatById(chatId);
//
//       if (existingChat != null) {
//         // Update existing chat
//         existingChat.updateLastMessage(lastMessage, lastMessageSenderId);
//
//         // Increment unread count for receiver
//         final receiverId = lastMessageSenderId == participant1Id ? participant2Id : participant1Id;
//         existingChat.incrementUnreadCount(receiverId);
//
//         _chatBox.put(existingChat);
//       } else {
//         // Create new chat
//         final newChat = ChatEntity.create(
//           chatId: chatId,
//           participant1Id: participant1Id,
//           participant1Name: participant1Name,
//           participant2Id: participant2Id,
//           participant2Name: participant2Name,
//         );
//
//         newChat.updateLastMessage(lastMessage, lastMessageSenderId);
//
//         // Increment unread count for receiver
//         final receiverId = lastMessageSenderId == participant1Id ? participant2Id : participant1Id;
//         newChat.incrementUnreadCount(receiverId);
//
//         _chatBox.put(newChat);
//       }
//     } catch (e) {
//       throw Exception('Failed to update chat: $e');
//     }
//   }
// }
