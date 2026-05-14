import 'package:drift/drift.dart' show OrderingMode, OrderingTerm, Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/db/app_database.dart';
import 'package:liko_auto/core/db/database_provider.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';

/// Clé stable pour une annonce — gardée pour compat avec l'historique et le
/// chat. Quand l'API arrivera, on aura un vrai `id` côté serveur.
String favoriteKey(ListingCardData data) => '${data.title}__${data.priceFcfa}';

ListingCardData _fromRow(FavoriteRow r) => ListingCardData(
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

/// Stream live des favoris, triés par date d'ajout descendante.
final favoritesProvider =
    StreamProvider<List<ListingCardData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.select(db.favorites)
    ..orderBy([(t) => OrderingTerm(expression: t.addedAt, mode: OrderingMode.desc)]);
  return query.watch().map((rows) => rows.map(_fromRow).toList());
});

/// Vrai si l'annonce donnée est dans les favoris (recharge en stream).
final isFavoriteProvider =
    StreamProvider.family<bool, ListingCardData>((ref, data) {
  final db = ref.watch(appDatabaseProvider);
  final key = favoriteKey(data);
  final query = db.select(db.favorites)..where((t) => t.listingKey.equals(key));
  return query.watch().map((rows) => rows.isNotEmpty);
});

/// Compteur live de favoris — utilisé par le badge profile.
final favoritesCountProvider = Provider<int>((ref) {
  return ref.watch(favoritesProvider).maybeWhen(
        data: (list) => list.length,
        orElse: () => 0,
      );
});

/// Actions sur les favoris (toggle / remove / clear).
class FavoritesActions {
  FavoritesActions(this._db);
  final AppDatabase _db;

  Future<bool> toggle(ListingCardData data) async {
    final key = favoriteKey(data);
    final existing = await (_db.select(_db.favorites)
          ..where((t) => t.listingKey.equals(key)))
        .getSingleOrNull();
    if (existing != null) {
      await (_db.delete(_db.favorites)..where((t) => t.listingKey.equals(key)))
          .go();
      return false;
    }
    await _db.into(_db.favorites).insert(_toCompanion(data));
    return true;
  }

  Future<void> remove(ListingCardData data) async {
    await (_db.delete(_db.favorites)
          ..where((t) => t.listingKey.equals(favoriteKey(data))))
        .go();
  }

  Future<void> clearAll() => _db.delete(_db.favorites).go();
}

final favoritesActionsProvider = Provider<FavoritesActions>((ref) {
  return FavoritesActions(ref.watch(appDatabaseProvider));
});
