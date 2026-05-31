import 'package:drift/drift.dart' show OrderingMode, OrderingTerm, Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/db/app_database.dart';
import 'package:liko_auto/core/db/database_provider.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';

String favoriteKey(ListingCardData data) => '${data.title}__${data.priceFcfa}';

ListingCardData _fromRow(FavoriteRow r) => ListingCardData(
  id: 0,
  title: r.title,
  priceFcfa: r.priceFcfa,
  location: r.location,
  mileageKm: r.mileageKm,
  imageAsset: r.imageAsset,
  photoCount: r.photoCount,
  year: r.year,
  isVinVerified: r.isVinVerified,
  isPro: r.isPro,
);

FavoritesCompanion _toCompanion(ListingCardData d) => FavoritesCompanion.insert(
  listingKey: favoriteKey(d),
  title: d.title,
  priceFcfa: d.priceFcfa,
  location: d.location,
  mileageKm: d.mileageKm,
  imageAsset: d.imageAsset,
  photoCount: d.photoCount,
  year: Value(d.year),
  isVinVerified: Value(d.isVinVerified),
  isPro: Value(d.isPro),
  addedAt: DateTime.now(),
);

class FavoritesRepository {
  const FavoritesRepository(this._db);
  final AppDatabase _db;

  Stream<List<ListingCardData>> watchAll() {
    final q = _db.select(_db.favorites)
      ..orderBy([
        (t) => OrderingTerm(expression: t.addedAt, mode: OrderingMode.desc),
      ]);
    return q.watch().map((rows) => rows.map(_fromRow).toList());
  }

  Stream<bool> watchIsFavorite(ListingCardData data) {
    final key = favoriteKey(data);
    final q = _db.select(_db.favorites)..where((t) => t.listingKey.equals(key));
    return q.watch().map((rows) => rows.isNotEmpty);
  }

  Future<bool> toggle(ListingCardData data) async {
    final key = favoriteKey(data);
    final existing = await (_db.select(
      _db.favorites,
    )..where((t) => t.listingKey.equals(key))).getSingleOrNull();
    if (existing != null) {
      await (_db.delete(
        _db.favorites,
      )..where((t) => t.listingKey.equals(key))).go();
      return false;
    }
    await _db.into(_db.favorites).insert(_toCompanion(data));
    return true;
  }

  Future<void> remove(ListingCardData data) async {
    await (_db.delete(
      _db.favorites,
    )..where((t) => t.listingKey.equals(favoriteKey(data)))).go();
  }

  Future<void> clearAll() => _db.delete(_db.favorites).go();
}

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.watch(appDatabaseProvider));
});
