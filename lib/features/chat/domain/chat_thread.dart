class ChatThread {

  const ChatThread({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isVerified = false,
    this.isOnline = false,
    this.avatarInitials,
    this.avatarUrl,
    this.avatarAsset = false,
  });
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isVerified;
  final bool isOnline;
  final String? avatarInitials;
  final String? avatarUrl;
  final bool avatarAsset;
}
