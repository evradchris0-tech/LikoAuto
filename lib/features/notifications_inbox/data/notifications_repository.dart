import 'package:drift/drift.dart' show OrderingMode, OrderingTerm, Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/db/app_database.dart';
import 'package:liko_auto/core/db/database_provider.dart';
import 'package:liko_auto/core/services/mock_data_service.dart';
import 'package:liko_auto/features/notifications_inbox/domain/app_notification.dart';

AppNotification _fromRow(NotificationRow r) => AppNotification(
  id: r.id,
  type: NotifType.values[r.type],
  title: r.title,
  body: r.body,
  createdAt: r.createdAt,
  isRead: r.isRead,
  payload: r.payload,
);

NotificationsCompanion _toCompanion(AppNotification n) =>
    NotificationsCompanion.insert(
      id: n.id,
      type: n.type.index,
      title: n.title,
      body: n.body,
      createdAt: n.createdAt,
      isRead: Value(n.isRead),
      payload: Value(n.payload),
    );

class NotificationsRepository {
  const NotificationsRepository(this._db, {this.seeds = const []});
  final AppDatabase _db;
  final List<AppNotification> seeds;

  Stream<List<AppNotification>> watchAll() async* {
    final count = await _db
        .customSelect('SELECT COUNT(*) AS c FROM notifications')
        .getSingle();
    if ((count.data['c'] as int? ?? 0) == 0 && seeds.isNotEmpty) {
      await _db.batch((b) {
        b.insertAll(_db.notifications, seeds.map(_toCompanion).toList());
      });
    }
    final q = _db.select(_db.notifications)
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);
    yield* q.watch().map((rows) => rows.map(_fromRow).toList());
  }

  Future<void> markRead(String id) async {
    await (_db.update(_db.notifications)..where((t) => t.id.equals(id))).write(
      const NotificationsCompanion(isRead: Value(true)),
    );
  }

  Future<void> markAllRead() async {
    await _db
        .update(_db.notifications)
        .write(const NotificationsCompanion(isRead: Value(true)));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.notifications)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearAll() => _db.delete(_db.notifications).go();

  Future<void> push(AppNotification n) async {
    await _db.into(_db.notifications).insertOnConflictUpdate(_toCompanion(n));
  }
}

final notificationsRepositoryProvider = FutureProvider<NotificationsRepository>(
  (ref) async {
    final mockService = await ref.watch(mockDataServiceProvider.future);
    final db = ref.watch(appDatabaseProvider);
    return NotificationsRepository(db, seeds: mockService.notificationSeeds);
  },
);
