import 'package:flutter/material.dart';
import 'package:mpitana/screens/chat/chat_list_item.dart';
import 'package:mpitana/screens/chat/models/chat_model.dart';
class MessagesScreen extends StatelessWidget {
  final List<ChatItem> chatItems = [
    ChatItem(
      name: "John Smith",
      lastMessage: "How are you today?",
      time: "2 min ago",
      profileImage: "assets/images/john.jpg",
      hasUnreadMessages: true,
      unreadCount: 3,
    ),
    ChatItem(
      name: "Team Spruce",
      lastMessage: "Don't miss to attend the meeting.",
      time: "2 min ago",
      profileImage: "assets/images/team.jpg",
      hasUnreadMessages: true,
      unreadCount: 1,
    ),
    ChatItem(
      name: "Alex Wright",
      lastMessage: "Hey! Can you join the meeting?",
      time: "3 min ago",
      profileImage: "assets/images/alex.jpg",
      hasUnreadMessages: false,
    ),
    ChatItem(
      name: "Jenny Jenks",
      lastMessage: "How are you today?",
      time: "4 min ago",
      profileImage: "assets/images/jenny.jpg",
      hasUnreadMessages: false,
    ),
    ChatItem(
      name: "Matthew Bruno",
      lastMessage: "",
      time: "5 min ago",
      profileImage: "assets/images/matthew.jpg",
      hasUnreadMessages: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: chatItems.length,
                itemBuilder: (context, index) {
                  return ChatListItem(chatItem: chatItems[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            "Messages",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}