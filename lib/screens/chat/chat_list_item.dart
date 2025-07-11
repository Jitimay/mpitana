import 'package:flutter/material.dart';
import 'package:mpitana/screens/chat/chat_screen.dart';
import 'package:mpitana/screens/chat/models/chat_model.dart';

class ChatListItem extends StatelessWidget {
  final ChatItem chatItem;

  const ChatListItem({Key? key, required this.chatItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to chat screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(chatItem: chatItem),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Profile Image
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFF2C2C2E),
                  child: _buildProfileImage(),
                ),
                // Online indicator (green dot)
                if (chatItem.name == "John Smith" || chatItem.name == "Team Spruce")
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Color(0xFF34C759),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xFF1C1C1E),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12),
            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chatItem.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        chatItem.time,
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chatItem.lastMessage.isEmpty ? "No messages" : chatItem.lastMessage,
                          style: TextStyle(
                            color: chatItem.hasUnreadMessages 
                                ? Colors.white 
                                : Color(0xFF8E8E93),
                            fontSize: 14,
                            fontWeight: chatItem.hasUnreadMessages 
                                ? FontWeight.w500 
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chatItem.hasUnreadMessages)
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Color(0xFF007AFF),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chatItem.unreadCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    // Generate different colored avatars based on name
    Color avatarColor;
    String initial = chatItem.name[0];
    
    switch (chatItem.name) {
      case "John Smith":
        avatarColor = Colors.blue;
        break;
      case "Team Spruce":
        avatarColor = Colors.green;
        break;
      case "Alex Wright":
        avatarColor = Colors.orange;
        break;
      case "Jenny Jenks":
        avatarColor = Colors.purple;
        break;
      case "Matthew Bruno":
        avatarColor = Colors.red;
        break;
      default:
        avatarColor = Colors.grey;
    }

    return CircleAvatar(
      radius: 26,
      backgroundColor: avatarColor,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}