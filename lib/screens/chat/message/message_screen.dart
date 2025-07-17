import 'package:flutter/material.dart';
import 'package:mpitana/screens/chat/chat_list_item.dart';
import 'package:mpitana/screens/chat/models/chat_model.dart';
import 'package:mpitana/screens/chat/chatbot/chatbot_screen.dart';

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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatbotScreen(),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.smart_toy,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            "Messages",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
