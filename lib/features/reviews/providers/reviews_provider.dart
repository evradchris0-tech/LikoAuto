import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/db/app_database.dart';
import 'package:liko_auto/core/db/database_provider.dart';
import 'package:liko_auto/features/reviews/domain/review.dart';

Review _fromRow(ReviewRow r) => Review(
      id: r.id,
      targetType: ReviewTargetType.values[r.targetType],
      targetId: r.targetId,
      authorName: r.authorName,
      rating: r.rating,
      body: r.body,
      tags: r.tags,
      verified: r.verified,
      createdAt: r.createdAt,
    );

ReviewsCompanion _toCompanion(Review r) => ReviewsCompanion.insert(
      id: r.id,
      targetType: r.targetType.index,
      targetId: r.targetId,
      authorName: r.authorName,
      rating: r.rating,
      body: drift.Value(r.body),
      tags: drift.Value(r.tags),
      verified: drift.Value(r.verified),
      createdAt: r.createdAt,
    );

/// Stream live des reviews ciblées sur un objet précis.
final reviewsForTargetProvider =
    StreamProvider.family<List<Review>, ({ReviewTargetType type, String id})>(
        (ref, target) {
  final db = ref.watch(appDatabaseProvider);
  final q = db.select(db.reviews)
    ..where((t) =>
        t.targetType.equals(target.type.index) &
        t.targetId.equals(target.id))
    ..orderBy([
      (t) => drift.OrderingTerm(
            expression: t.createdAt,
            mode: drift.OrderingMode.desc,
          ),
    ]);
  return q.watch().map((rows) => rows.map(_fromRow).toList());
});

class ReviewsActions {
  ReviewsActions(this._db);
  final AppDatabase _db;

  Future<void> publish(Review r) async {
    await _db.into(_db.reviews).insertOnConflictUpdate(_toCompanion(r));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.reviews)..where((t) => t.id.equals(id))).go();
  }
}

final reviewsActionsProvider = Provider<ReviewsActions>((ref) {
  return ReviewsActions(ref.watch(appDatabaseProvider));
});
