import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/db/app_database.dart';
import 'package:liko_auto/core/db/database_provider.dart';

/// Stream live des identifiants utilisateur bloqués (`thread.id` en V1).
final blockedUsersProvider = StreamProvider<Set<String>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db
      .select(db.blockedUsers)
      .watch()
      .map((rows) => rows.map((r) => r.userId).toSet());
});

/// Stream live des threads mutés.
final mutedThreadsProvider = StreamProvider<Set<String>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db
      .select(db.mutedThreads)
      .watch()
      .map((rows) => rows.map((r) => r.threadId).toSet());
});

class ModerationActions {
  ModerationActions(this._db);
  final AppDatabase _db;

  Future<void> blockUser(String userId) async {
    await _db.into(_db.blockedUsers).insertOnConflictUpdate(
          BlockedUsersCompanion.insert(
            userId: userId,
            blockedAt: DateTime.now(),
          ),
        );
  }

  Future<void> unblockUser(String userId) async {
    await (_db.delete(_db.blockedUsers)
          ..where((t) => t.userId.equals(userId)))
        .go();
  }

  Future<void> muteThread(String threadId) async {
    await _db.into(_db.mutedThreads).insertOnConflictUpdate(
          MutedThreadsCompanion.insert(
            threadId: threadId,
            mutedAt: DateTime.now(),
          ),
        );
  }

  Future<void> unmuteThread(String threadId) async {
    await (_db.delete(_db.mutedThreads)
          ..where((t) => t.threadId.equals(threadId)))
        .go();
  }

}

final moderationActionsProvider = Provider<ModerationActions>((ref) {
  return ModerationActions(ref.watch(appDatabaseProvider));
});
