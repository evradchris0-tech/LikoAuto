import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/bookings/data/bookings_repository.dart';
import 'package:liko_auto/features/bookings/domain/booking.dart';

export 'package:liko_auto/features/bookings/data/bookings_repository.dart'
    show BookingsRepository;

final bookingsProvider = StreamProvider<List<Booking>>((ref) async* {
  final repo = await ref.watch(bookingsRepositoryProvider.future);
  yield* repo.watchAll();
});

final upcomingBookingsCountProvider = Provider<int>((ref) {
  final now = DateTime.now();
  return ref
      .watch(bookingsProvider)
      .maybeWhen(
        data: (list) => list
            .where(
              (b) =>
                  b.status == BookingStatus.confirmed &&
                  b.scheduledAt.isAfter(now),
            )
            .length,
        orElse: () => 0,
      );
});

/// Nullable: returns null while mock data is still loading.
final bookingsActionsProvider = Provider<BookingsRepository?>((ref) {
  return ref.watch(bookingsRepositoryProvider).valueOrNull;
});
