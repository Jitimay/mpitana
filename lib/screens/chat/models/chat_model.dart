class ChatItem {
  final String name;
  final String lastMessage;
  final String time;
  final String profileImage;
  final bool hasUnreadMessages;
  final int unreadCount;

  ChatItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.profileImage,
    this.hasUnreadMessages = false,
    this.unreadCount = 0,
  });
}