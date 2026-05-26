import 'package:drift/drift.dart' show OrderingMode, OrderingTerm, Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/db/app_database.dart';
import 'package:liko_auto/core/db/database_provider.dart';
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
  const NotificationsRepository(this._db);
  final AppDatabase _db;

  /// Stream chrono inverse. Sème la table si vide au premier appel.
  Stream<List<AppNotification>> watchAll() async* {
    final count = await _db
        .customSelect('SELECT COUNT(*) AS c FROM notifications')
        .getSingle();
    if ((count.data['c'] as int? ?? 0) == 0) {
      await _seed(_db);
    }
    final q = _db.select(_db.notifications)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);
    yield* q.watch().map((rows) => rows.map(_fromRow).toList());
  }

  Future<void> markRead(String id) async {
    await (_db.update(_db.notifications)..where((t) => t.id.equals(id)))
        .write(const NotificationsCompanion(isRead: Value(true)));
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

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(appDatabaseProvider));
});

Future<void> _seed(AppDatabase db) async {
  final now = DateTime.now();
  final seeds = <AppNotification>[
    AppNotification(
      id: 'N-001',
      type: NotifType.newMessage,
      title: 'Garage Auto Plus',
      body: 'Bonjour, la Toyota RAV4 est toujours disponible…',
      createdAt: now.subtract(const Duration(minutes: 32)),
      payload: const {'route': '/chat_detail', 'id': '1'},
    ),
    AppNotification(
      id: 'N-002',
      type: NotifType.priceDrop,
      title: 'Baisse de prix',
      body: '-500 000 FCFA sur Hyundai Tucson 2019',
      createdAt: now.subtract(const Duration(hours: 3)),
      payload: const {'route': '/vehicle_detail', 'listingKey': 'Hyundai Tucson 2019__11200000'},
    ),
    AppNotification(
      id: 'N-003',
      type: NotifType.appointment,
      title: 'RDV confirmé',
      body: 'Auto Plus — Diagnostic électronique, demain à 14h.',
      createdAt: now.subtract(const Duration(hours: 5)),
      payload: const {'route': '/my_bookings'},
    ),
    AppNotification(
      id: 'N-004',
      type: NotifType.listingApproved,
      title: 'Annonce approuvée',
      body: 'Votre Toyota RAV4 2020 est en ligne.',
      createdAt: now.subtract(const Duration(days: 1)),
      isRead: true,
      payload: const {'route': '/my_listings'},
    ),
    AppNotification(
      id: 'N-005',
      type: NotifType.listingRejected,
      title: 'Annonce refusée',
      body: 'Nissan Qashqai 2018 — VIN illisible sur les photos.',
      createdAt: now.subtract(const Duration(days: 1, hours: 6)),
      isRead: true,
      payload: const {'route': '/my_listings'},
    ),
    AppNotification(
      id: 'N-006',
      type: NotifType.review,
      title: 'Nouvel avis 5/5',
      body: 'Sophie B. a noté votre vente : « Vendeur sérieux et ponctuel. »',
      createdAt: now.subtract(const Duration(days: 3)),
      isRead: true,
    ),
    AppNotification(
      id: 'N-007',
      type: NotifType.system,
      title: 'Politique mise à jour',
      body: 'Nos conditions générales évoluent au 1er juin.',
      createdAt: now.subtract(const Duration(days: 6)),
      isRead: true,
      payload: const {'route': '/support'},
    ),
    AppNotification(
      id: 'N-008',
      type: NotifType.promo,
      title: 'Boost à -20%',
      body: 'Mettez votre annonce en avant ce week-end seulement.',
      createdAt: now.subtract(const Duration(days: 8)),
      isRead: true,
    ),
  ];
  await db.batch((b) {
    b.insertAll(db.notifications, seeds.map(_toCompanion).toList());
  });
}
