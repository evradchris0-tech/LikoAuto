import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/chat/domain/message_entity.dart';

final chatMessagesProvider = Provider.family<List<MessageEntity>, String>((
  ref,
  chatId,
) {
  // In a real app, you'd fetch messages for this specific chatId.
  return const [
    MessageEntity(
      id: 'm1',
      text: "Bonjour, je suis intéressé par l'annonce.",
      isMe: true,
      time: '09:34',
      isRead: true,
    ),
    MessageEntity(
      id: 'm2',
      text: "D'accord, est-ce que le prix est négociable ?",
      isMe: true,
      time: '09:35',
      isRead: true,
    ),
    MessageEntity(
      id: 'm3',
      text:
          'Bonjour, la Toyota RAV4 est toujours disponible. Vous pouvez passer la voir ce soir au garage.',
      isMe: false,
      time: '09:42',
    ),
  ];
});
