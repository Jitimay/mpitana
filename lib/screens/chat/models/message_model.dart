class Message {
  final String text;
  final String time;
  final bool isMe;
  final String? senderName;
  final bool isVoiceMessage;
  final String? voiceDuration;

  Message({
    required this.text,
    required this.time,
    required this.isMe,
    this.senderName,
    this.isVoiceMessage = false,
    this.voiceDuration,
  });
}