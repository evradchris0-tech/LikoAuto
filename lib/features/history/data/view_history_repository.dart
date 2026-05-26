import 'package:drift/drift.dart' show OrderingMode, OrderingTerm, Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/db/app_database.dart';
import 'package:liko_auto/core/db/database_provider.dart';
import 'package:liko_auto/features/favorites/data/favorites_repository.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';

const _kMaxHistoryEntries = 50;

@immutable
class ViewedListing {
  const ViewedListing({required this.data, required this.viewedAt});
  final ListingCardData data;
  final DateTime viewedAt;
}

ViewedListing _fromRow(ViewHistoryRow r) => ViewedListing(
      data: ListingCardData(
        title: r.title,
        priceFcfa: r.priceFcfa,
        location: r.location,
        mileageKm: r.mileageKm,
        imageAsset: r.imageAsset,
        photoCount: r.photoCount,
        year: r.year,
        isVinVerified: r.isVinVerified,
        isPro: r.isPro,
      ),
      viewedAt: r.viewedAt,
    );

class ViewHistoryRepository {
  const ViewHistoryRepository(this._db);
  final AppDatabase _db;

  Stream<List<ViewedListing>> watchAll() {
    final q = _db.select(_db.viewHistory)
      ..orderBy([(t) => OrderingTerm(expression: t.viewedAt, mode: OrderingMode.desc)]);
    return q.watch().map((rows) => rows.map(_fromRow).toList());
  }

  /// Enregistre (ou met à jour) une consultation. Plafond à 50 entrées.
  Future<void> record(ListingCardData data) async {
    await _db.into(_db.viewHistory).insertOnConflictUpdate(
          ViewHistoryCompanion.insert(
            listingKey: favoriteKey(data),
            title: data.title,
            priceFcfa: data.priceFcfa,
            location: data.location,
            mileageKm: data.mileageKm,
            imageAsset: data.imageAsset,
            photoCount: data.photoCount,
            year: Value(data.year),
            isVinVerified: Value(data.isVinVerified),
            isPro: Value(data.isPro),
            viewedAt: DateTime.now(),
          ),
        );
    final count = await _db
        .customSelect('SELECT COUNT(*) AS c FROM view_history')
        .getSingle();
    final c = count.data['c'] as int? ?? 0;
    if (c > _kMaxHistoryEntries) {
      await _db.customStatement(
        'DELETE FROM view_history WHERE listing_key IN '
        '(SELECT listing_key FROM view_history '
        'ORDER BY viewed_at ASC '
        'LIMIT ${c - _kMaxHistoryEntries})',
      );
    }
  }

  Future<void> remove(ListingCardData data) async {
    await (_db.delete(_db.viewHistory)
          ..where((t) => t.listingKey.equals(favoriteKey(data))))
        .go();
  }

  Future<void> clearAll() => _db.delete(_db.viewHistory).go();
}

final viewHistoryRepositoryProvider = Provider<ViewHistoryRepository>((ref) {
  return ViewHistoryRepository(ref.watch(appDatabaseProvider));
});
