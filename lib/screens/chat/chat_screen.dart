import 'package:flutter/material.dart';
import 'package:mpitana/screens/chat/message/message.dart';
import 'package:mpitana/screens/chat/models/chat_model.dart';
import 'package:mpitana/screens/chat/models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final ChatItem chatItem;

  ChatScreen({required this.chatItem});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [
    Message(
      text: "Hi, good to see you! We're starting work on a presentation for a new product today, right?",
      time: "8:34 PM",
      isMe: true,
    ),
    Message(
      text: "Yes, that's right. Let's discuss the main points and structure of the presentation",
      time: "8:35 PM",
      isMe: false,
      senderName: "Katy",
    ),
    Message(
      text: "",
      time: "8:40 PM",
      isMe: true,
      isVoiceMessage: true,
      voiceDuration: "1:04",
    ),
    Message(
      text: "Okay, then let's divide the presentation into a few main sections: introduction, product description, features and benefits, use cases, and conclusion",
      time: "8:42 PM",
      isMe: false,
      senderName: "Katy",
    ),
    Message(
      text: "It's a deal",
      time: "8:54 PM",
      isMe: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1C1C1E),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  "12",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Aysha Hayes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Online",
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1E),
        border: Border(
          top: BorderSide(color: Color(0xFF2C2C2E), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Color(0xFF8E8E93)),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Type your message...",
                  hintStyle: TextStyle(color: Color(0xFF8E8E93)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.emoji_emotions_outlined, color: Color(0xFF8E8E93)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.mic, color: Color(0xFF8E8E93)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
