import 'package:flutter/material.dart';
import 'package:mpitana/screens/chat/models/message_model.dart';
import 'package:mpitana/screens/chat/utils/wave_from_painter.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF2C2C2E),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!message.isMe && message.senderName != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.senderName!,
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isMe ? Color(0xFF34C759) : Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: message.isVoiceMessage
                      ? _buildVoiceMessage()
                      : Text(
                          message.text,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
                SizedBox(height: 4),
                Text(
                  message.time,
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (message.isMe) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF2C2C2E),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVoiceMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: 24,
        ),
        SizedBox(width: 8),
        Container(
          width: 100,
          height: 20,
          child: CustomPaint(
            painter: WaveformPainter(),
          ),
        ),
        SizedBox(width: 8),
        Text(
          message.voiceDuration ?? "",
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
