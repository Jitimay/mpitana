// import 'package:flutter/material.dart';
// import 'package:mpitana/screens/chat/chat_screen.dart';
// import 'package:mpitana/screens/chat/models/chat_model.dart';
// import 'package:mpitana/screens/chat/services/message_service.dart';
//
// class TestChatScreen extends StatefulWidget {
//   @override
//   _TestChatScreenState createState() => _TestChatScreenState();
// }
//
// class _TestChatScreenState extends State<TestChatScreen> {
//   final MessageService _messageService = MessageService();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Test Chat'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Test Messaging Functionality',
//               style: Theme.of(context).textTheme.headlineSmall,
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 32),
//
//             ElevatedButton(
//               onPressed: () => _openTestChat('John Doe', 'john_doe_123'),
//               child: Text('Chat with John Doe'),
//             ),
//             SizedBox(height: 16),
//
//             ElevatedButton(
//               onPressed: () => _openTestChat('Jane Smith', 'jane_smith_456'),
//               child: Text('Chat with Jane Smith'),
//             ),
//             SizedBox(height: 16),
//
//             ElevatedButton(
//               onPressed: () => _openTestChat('Bob Johnson', 'bob_johnson_789'),
//               child: Text('Chat with Bob Johnson'),
//             ),
//             SizedBox(height: 32),
//
//             ElevatedButton(
//               onPressed: _showAllChats,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//               ),
//               child: Text('Show All Chats'),
//             ),
//             SizedBox(height: 16),
//
//             ElevatedButton(
//               onPressed: _clearAllChats,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//               ),
//               child: Text('Clear All Chats'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _openTestChat(String name, String userId) {
//     final chatItem = ChatItem(
//       id: userId,
//       name: name,
//       lastMessage: '',
//       time: '',
//       unreadCount: 0,
//       isOnline: true,
//     );
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ChatScreen(
//           chatItem: chatItem,
//           currentUserId: 'current_user_123',
//           currentUserName: 'Current User',
//         ),
//       ),
//     );
//   }
//
//   void _showAllChats() async {
//     try {
//       final chats = _messageService.getChatsForUser('current_user_123');
//
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('All Chats (${chats.length})'),
//           content: Container(
//             width: double.maxFinite,
//             height: 300,
//             child: chats.isEmpty
//                 ? Center(child: Text('No chats found'))
//                 : ListView.builder(
//                     itemCount: chats.length,
//                     itemBuilder: (context, index) {
//                       final chat = chats[index];
//                       final otherParticipant = chat.getOtherParticipant('current_user_123');
//
//                       return ListTile(
//                         title: Text(otherParticipant['name']!),
//                         subtitle: Text(chat.lastMessage ?? 'No messages'),
//                         trailing: chat.getUnreadCount('current_user_123') > 0
//                             ? CircleAvatar(
//                                 radius: 10,
//                                 backgroundColor: Colors.red,
//                                 child: Text(
//                                   '${chat.getUnreadCount('current_user_123')}',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               )
//                             : null,
//                         onTap: () {
//                           Navigator.pop(context);
//                           _openTestChat(otherParticipant['name']!, otherParticipant['id']!);
//                         },
//                       );
//                     },
//                   ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Close'),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading chats: $e')),
//       );
//     }
//   }
//
//   void _clearAllChats() async {
//     try {
//       final chats = _messageService.getChatsForUser('current_user_123');
//
//       for (final chat in chats) {
//         await _messageService.deleteChat(chat.chatId);
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('All chats cleared successfully!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error clearing chats: $e')),
//       );
//     }
//   }
// }
