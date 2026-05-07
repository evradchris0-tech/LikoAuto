import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/chat/domain/chat_thread.dart';

final chatThreadsProvider = Provider<List<ChatThread>>((ref) {
  return const [
    ChatThread(
      id: '1',
      name: 'Garage Auto Plus',
      lastMessage: 'Bonjour, la Toyota RAV4 est...',
      time: '09:42',
      unreadCount: 1,
      isVerified: true,
      isOnline: true,
      avatarAsset: true,
    ),
    ChatThread(
      id: '2',
      name: 'Marc Tene',
      lastMessage: 'Pouvez-vous baisser le prix ...',
      time: 'Hier',
      unreadCount: 2,
      avatarInitials: 'MT',
    ),
    ChatThread(
      id: '3',
      name: 'Motors Cameroun',
      lastMessage: 'Rendez-vous confirmé pour de...',
      time: 'Mar.',
      isVerified: true,
      isOnline: true,
      avatarAsset: true,
    ),
    ChatThread(
      id: '4',
      name: 'Sophie B.',
      lastMessage: "D'accord, je vous recontact...",
      time: '04 Nov',
      avatarUrl: 'https://i.pravatar.cc/100?img=5',
    ),
    ChatThread(
      id: '5',
      name: 'Liko Auto Info',
      lastMessage: 'Votre annonce "Hyundai Tuc...',
      time: '01 Nov',
    ),
  ];
});

final chatFilterProvider = StateProvider<String>((ref) => 'Tous');
