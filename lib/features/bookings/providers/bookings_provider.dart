import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/bookings/data/bookings_repository.dart';
import 'package:liko_auto/features/bookings/domain/booking.dart';

export 'package:liko_auto/features/bookings/data/bookings_repository.dart'
    show BookingsRepository;

/// Stream live des RDV, par date programmée descendante.
final bookingsProvider = StreamProvider<List<Booking>>((ref) {
  return ref.watch(bookingsRepositoryProvider).watchAll();
});

final upcomingBookingsCountProvider = Provider<int>((ref) {
  final now = DateTime.now();
  return ref.watch(bookingsProvider).maybeWhen(
        data: (list) => list
            .where((b) =>
                b.status == BookingStatus.confirmed &&
                b.scheduledAt.isAfter(now))
            .length,
        orElse: () => 0,
      );
});

/// Actions sur les réservations (create / changeStatus / delete).
final bookingsActionsProvider = Provider<BookingsRepository>((ref) {
  return ref.watch(bookingsRepositoryProvider);
});
