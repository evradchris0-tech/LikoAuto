import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/chat/data/chat_repository.dart';
import 'package:liko_auto/features/chat/domain/chat_thread.dart';
import 'package:liko_auto/features/chat/providers/moderation_provider.dart';

/// Threads chat — masque ceux dont l'utilisateur est bloqué.
final chatThreadsProvider = Provider<List<ChatThread>>((ref) {
  final blocked = ref.watch(blockedUsersProvider).valueOrNull ?? const {};
  return ref
      .watch(chatRepositoryProvider)
      .getThreads()
      .where((t) => !blocked.contains(t.id))
      .toList();
});

final chatFilterProvider = StateProvider<String>((ref) => 'Tous');
