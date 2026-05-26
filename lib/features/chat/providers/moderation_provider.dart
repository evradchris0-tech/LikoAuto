import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/chat/data/chat_repository.dart';

export 'package:liko_auto/features/chat/data/chat_repository.dart'
    show ModerationRepository;

/// Stream live des identifiants utilisateur bloqués.
final blockedUsersProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(moderationRepositoryProvider).watchBlockedUsers();
});

/// Stream live des threads mutés.
final mutedThreadsProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(moderationRepositoryProvider).watchMutedThreads();
});

/// Actions de modération (block / unblock / mute / unmute).
final moderationActionsProvider = Provider<ModerationRepository>((ref) {
  return ref.watch(moderationRepositoryProvider);
});
