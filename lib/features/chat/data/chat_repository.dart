import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/db/app_database.dart';
import 'package:liko_auto/core/db/database_provider.dart';
import 'package:liko_auto/features/chat/domain/chat_thread.dart';

// ── Mock threads ───────────────────────────────────────────────────────────────

const _kThreads = <ChatThread>[
  ChatThread(
    id: '1',
    name: 'Garage Auto Plus',
    lastMessage: 'Bonjour, la Toyota RAV4 est…',
    time: '09:42',
    unreadCount: 1,
    isVerified: true,
    isOnline: true,
    avatarAsset: true,
  ),
  ChatThread(
    id: '2',
    name: 'Marc Tene',
    lastMessage: 'Pouvez-vous baisser le prix …',
    time: 'Hier',
    unreadCount: 2,
    avatarInitials: 'MT',
  ),
  ChatThread(
    id: '3',
    name: 'Motors Cameroun',
    lastMessage: 'Rendez-vous confirmé pour de…',
    time: 'Mar.',
    isVerified: true,
    isOnline: true,
    avatarAsset: true,
  ),
  ChatThread(
    id: '4',
    name: 'Sophie B.',
    lastMessage: "D'accord, je vous recontact…",
    time: '04 Nov',
    avatarUrl: 'https://i.pravatar.cc/100?img=5',
  ),
  ChatThread(
    id: '5',
    name: 'Liko Auto Info',
    lastMessage: 'Votre annonce "Hyundai Tuc…',
    time: '01 Nov',
  ),
];

// ── Chat repository (mock → API) ───────────────────────────────────────────────

class ChatRepository {
  const ChatRepository();

  List<ChatThread> getThreads() => _kThreads;
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return const ChatRepository();
});

// ── Moderation repository (Drift) ─────────────────────────────────────────────

class ModerationRepository {
  const ModerationRepository(this._db);
  final AppDatabase _db;

  Stream<Set<String>> watchBlockedUsers() {
    return _db
        .select(_db.blockedUsers)
        .watch()
        .map((rows) => rows.map((r) => r.userId).toSet());
  }

  Stream<Set<String>> watchMutedThreads() {
    return _db
        .select(_db.mutedThreads)
        .watch()
        .map((rows) => rows.map((r) => r.threadId).toSet());
  }

  Future<void> blockUser(String userId) async {
    await _db
        .into(_db.blockedUsers)
        .insertOnConflictUpdate(
          BlockedUsersCompanion.insert(
            userId: userId,
            blockedAt: DateTime.now(),
          ),
        );
  }

  Future<void> unblockUser(String userId) async {
    await (_db.delete(
      _db.blockedUsers,
    )..where((t) => t.userId.equals(userId))).go();
  }

  Future<void> muteThread(String threadId) async {
    await _db
        .into(_db.mutedThreads)
        .insertOnConflictUpdate(
          MutedThreadsCompanion.insert(
            threadId: threadId,
            mutedAt: DateTime.now(),
          ),
        );
  }

  Future<void> unmuteThread(String threadId) async {
    await (_db.delete(
      _db.mutedThreads,
    )..where((t) => t.threadId.equals(threadId))).go();
  }
}

final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  return ModerationRepository(ref.watch(appDatabaseProvider));
});
