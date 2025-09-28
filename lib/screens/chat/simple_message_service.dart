import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Message {
  final String id;
  final String text;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'senderId': senderId,
    'receiverId': receiverId,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    text: json['text'],
    senderId: json['senderId'],
    receiverId: json['receiverId'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class SimpleMessageService {
  static Future<void> sendMessage(String text, String receiverId) async {
    final prefs = await SharedPreferences.getInstance();
    final messages = await getMessages();
    
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      senderId: 'current_user',
      receiverId: receiverId,
      timestamp: DateTime.now(),
    );
    
    messages.add(message);
    await prefs.setString('messages', jsonEncode(messages.map((m) => m.toJson()).toList()));
  }

  static Future<List<Message>> getMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString('messages') ?? '[]';
    final List<dynamic> messagesList = jsonDecode(messagesJson);
    return messagesList.map((json) => Message.fromJson(json)).toList();
  }
}
