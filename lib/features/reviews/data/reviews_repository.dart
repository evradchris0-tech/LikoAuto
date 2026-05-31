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

class ReviewsRepository {
  const ReviewsRepository(this._db);
  final AppDatabase _db;

  Stream<List<Review>> watchForTarget({
    required ReviewTargetType type,
    required String id,
  }) {
    final q = _db.select(_db.reviews)
      ..where((t) => t.targetType.equals(type.index) & t.targetId.equals(id))
      ..orderBy([
        (t) => drift.OrderingTerm(
          expression: t.createdAt,
          mode: drift.OrderingMode.desc,
        ),
      ]);
    return q.watch().map((rows) => rows.map(_fromRow).toList());
  }

  Future<void> publish(Review r) async {
    await _db.into(_db.reviews).insertOnConflictUpdate(_toCompanion(r));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.reviews)..where((t) => t.id.equals(id))).go();
  }
}

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepository(ref.watch(appDatabaseProvider));
});
