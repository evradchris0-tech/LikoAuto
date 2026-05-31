class MessageEntity {
  const MessageEntity({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.isRead = false,
  });
  final String id;
  final String text;
  final bool isMe;
  final String time;
  final bool isRead;
}
