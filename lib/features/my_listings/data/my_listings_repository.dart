import 'package:drift/drift.dart' show OrderingMode, OrderingTerm, Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/db/app_database.dart';
import 'package:liko_auto/core/db/database_provider.dart';
import 'package:liko_auto/core/fixtures/mock_vehicles.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';
import 'package:liko_auto/features/my_listings/domain/my_listing.dart';

MyListing _fromRow(MyListingRow r) => MyListing(
      id: r.id,
      card: ListingCardData(
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
      status: ListingStatus.values[r.status],
      views: r.views,
      contacts: r.contacts,
      publishedAt: r.publishedAt,
      expiresAt: r.expiresAt,
      rejectionReason: r.rejectionReason,
    );

MyListingsCompanion _toCompanion(MyListing l) => MyListingsCompanion.insert(
      id: l.id,
      title: l.card.title,
      priceFcfa: l.card.priceFcfa,
      location: l.card.location,
      mileageKm: l.card.mileageKm,
      imageAsset: l.card.imageAsset,
      photoCount: l.card.photoCount,
      year: Value(l.card.year),
      isVinVerified: Value(l.card.isVinVerified),
      isPro: Value(l.card.isPro),
      status: l.status.index,
      views: Value(l.views),
      contacts: Value(l.contacts),
      publishedAt: l.publishedAt,
      expiresAt: Value(l.expiresAt),
      rejectionReason: Value(l.rejectionReason),
    );

class MyListingsRepository {
  const MyListingsRepository(this._db);
  final AppDatabase _db;

  /// Stream trié par date de publication décroissante.
  /// Sème la table avec des données mock si elle est vide.
  Stream<List<MyListing>> watchAll() async* {
    final count = await _db
        .customSelect('SELECT COUNT(*) AS c FROM my_listings')
        .getSingle();
    if ((count.data['c'] as int? ?? 0) == 0) {
      await _seed(_db);
    }
    final q = _db.select(_db.myListings)
      ..orderBy([(t) => OrderingTerm(expression: t.publishedAt, mode: OrderingMode.desc)]);
    yield* q.watch().map((rows) => rows.map(_fromRow).toList());
  }

  Future<void> changeStatus(String id, ListingStatus next) async {
    await (_db.update(_db.myListings)..where((t) => t.id.equals(id)))
        .write(MyListingsCompanion(status: Value(next.index)));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.myListings)..where((t) => t.id.equals(id))).go();
  }

  Future<void> insert(MyListing listing) async {
    await _db.into(_db.myListings).insertOnConflictUpdate(_toCompanion(listing));
  }
}

final myListingsRepositoryProvider = Provider<MyListingsRepository>((ref) {
  return MyListingsRepository(ref.watch(appDatabaseProvider));
});

Future<void> _seed(AppDatabase db) async {
  final now = DateTime(2026, 5, 7);
  const v = MockVehicles.all;
  final seeds = <MyListing>[
    MyListing(
      id: 'L-001',
      card: v[0],
      status: ListingStatus.active,
      views: 312,
      contacts: 18,
      publishedAt: now.subtract(const Duration(days: 4)),
      expiresAt: now.add(const Duration(days: 26)),
      isBoosted: true,
    ),
    MyListing(
      id: 'L-002',
      card: v[1],
      status: ListingStatus.active,
      views: 87,
      contacts: 4,
      publishedAt: now.subtract(const Duration(days: 1)),
      expiresAt: now.add(const Duration(days: 29)),
    ),
    MyListing(
      id: 'L-003',
      card: v[4],
      status: ListingStatus.pending,
      views: 0,
      contacts: 0,
      publishedAt: now.subtract(const Duration(hours: 6)),
    ),
    MyListing(
      id: 'L-004',
      card: v[6],
      status: ListingStatus.sold,
      views: 1240,
      contacts: 42,
      publishedAt: now.subtract(const Duration(days: 38)),
    ),
    MyListing(
      id: 'L-005',
      card: v[5],
      status: ListingStatus.paused,
      views: 156,
      contacts: 9,
      publishedAt: now.subtract(const Duration(days: 12)),
      expiresAt: now.add(const Duration(days: 18)),
    ),
    MyListing(
      id: 'L-006',
      card: v[7],
      status: ListingStatus.rejected,
      views: 0,
      contacts: 0,
      publishedAt: now.subtract(const Duration(days: 2)),
      rejectionReason:
          'VIN illisible sur les photos. Veuillez ajouter un cliché net du numéro de châssis.',
    ),
  ];
  await db.batch((b) {
    b.insertAll(db.myListings, seeds.map(_toCompanion).toList());
  });
}
