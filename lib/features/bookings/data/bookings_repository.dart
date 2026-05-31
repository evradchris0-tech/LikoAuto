import 'package:drift/drift.dart' show OrderingMode, OrderingTerm, Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/db/app_database.dart';
import 'package:liko_auto/core/db/database_provider.dart';
import 'package:liko_auto/core/services/mock_data_service.dart';
import 'package:liko_auto/features/bookings/domain/booking.dart';
import 'package:liko_auto/features/garage_detail/domain/garage_detail.dart';

Booking _fromRow(BookingRow r) => Booking(
  id: r.id,
  garageName: r.garageName,
  garageLocation: r.garageLocation,
  garageImageAsset: r.garageImageAsset,
  service: GarageService(
    label: r.serviceLabel,
    priceFromFcfa: r.servicePriceFromFcfa,
    durationMin: r.serviceDurationMin,
  ),
  scheduledAt: r.scheduledAt,
  status: BookingStatus.values[r.status],
  note: r.note,
  createdAt: r.createdAt,
);

BookingsCompanion _toCompanion(Booking b) => BookingsCompanion.insert(
  id: b.id,
  garageName: b.garageName,
  garageLocation: b.garageLocation,
  garageImageAsset: b.garageImageAsset,
  serviceLabel: b.service.label,
  servicePriceFromFcfa: b.service.priceFromFcfa,
  serviceDurationMin: b.service.durationMin,
  scheduledAt: b.scheduledAt,
  status: b.status.index,
  note: Value(b.note),
  createdAt: b.createdAt,
);

class BookingsRepository {
  const BookingsRepository(this._db, {this.seeds = const []});
  final AppDatabase _db;
  final List<Booking> seeds;

  Stream<List<Booking>> watchAll() async* {
    final count = await _db
        .customSelect('SELECT COUNT(*) AS c FROM bookings')
        .getSingle();
    if ((count.data['c'] as int? ?? 0) == 0 && seeds.isNotEmpty) {
      await _db.batch((b) {
        b.insertAll(_db.bookings, seeds.map(_toCompanion).toList());
      });
    }
    final q = _db.select(_db.bookings)
      ..orderBy([
        (t) => OrderingTerm(expression: t.scheduledAt, mode: OrderingMode.desc),
      ]);
    yield* q.watch().map((rows) => rows.map(_fromRow).toList());
  }

  Future<void> create(Booking b) async {
    await _db.into(_db.bookings).insertOnConflictUpdate(_toCompanion(b));
  }

  Future<void> changeStatus(String id, BookingStatus next) async {
    await (_db.update(_db.bookings)..where((t) => t.id.equals(id))).write(
      BookingsCompanion(status: Value(next.index)),
    );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.bookings)..where((t) => t.id.equals(id))).go();
  }
}

final bookingsRepositoryProvider = FutureProvider<BookingsRepository>((
  ref,
) async {
  final mockService = await ref.watch(mockDataServiceProvider.future);
  final db = ref.watch(appDatabaseProvider);
  return BookingsRepository(db, seeds: mockService.bookingSeeds);
});
