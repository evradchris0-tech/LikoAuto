import 'package:drift/drift.dart' show OrderingMode, OrderingTerm, Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/db/app_database.dart';
import 'package:liko_auto/core/db/database_provider.dart';
import 'package:liko_auto/features/favorites/providers/favorites_provider.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';

@immutable
class ViewedListing {
  const ViewedListing({required this.data, required this.viewedAt});
  final ListingCardData data;
  final DateTime viewedAt;
}

const _kMaxHistoryEntries = 50;

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

/// Stream live de l'historique des consultations, ordre chronologique inverse.
final viewHistoryProvider = StreamProvider<List<ViewedListing>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final q = db.select(db.viewHistory)
    ..orderBy([(t) => OrderingTerm(expression: t.viewedAt, mode: OrderingMode.desc)]);
  return q.watch().map((rows) => rows.map(_fromRow).toList());
});

final viewHistoryCountProvider = Provider<int>((ref) {
  return ref.watch(viewHistoryProvider).maybeWhen(
        data: (list) => list.length,
        orElse: () => 0,
      );
});

class ViewHistoryActions {
  ViewHistoryActions(this._db);
  final AppDatabase _db;

  /// Enregistre (ou met à jour) une consultation. Cap à 50 entries.
  Future<void> record(ListingCardData data) async {
    final key = favoriteKey(data);
    await _db.into(_db.viewHistory).insertOnConflictUpdate(
          ViewHistoryCompanion.insert(
            listingKey: key,
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
    // Si on dépasse le cap, on supprime les plus anciens.
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
    final key = favoriteKey(data);
    await (_db.delete(_db.viewHistory)..where((t) => t.listingKey.equals(key)))
        .go();
  }

  Future<void> clearAll() => _db.delete(_db.viewHistory).go();
}

final viewHistoryActionsProvider = Provider<ViewHistoryActions>((ref) {
  return ViewHistoryActions(ref.watch(appDatabaseProvider));
});
