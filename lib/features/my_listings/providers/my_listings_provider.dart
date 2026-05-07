import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/fixtures/mock_vehicles.dart';
import 'package:liko_auto/features/my_listings/domain/my_listing.dart';

class MyListingsNotifier extends StateNotifier<List<MyListing>> {
  MyListingsNotifier() : super(_seed());

  static List<MyListing> _seed() {
    final now = DateTime(2026, 5, 7);
    final vehicles = MockVehicles.all;
    return [
      MyListing(
        id: 'L-001',
        card: vehicles[0],
        status: ListingStatus.active,
        views: 312,
        contacts: 18,
        publishedAt: now.subtract(const Duration(days: 4)),
        expiresAt: now.add(const Duration(days: 26)),
      ),
      MyListing(
        id: 'L-002',
        card: vehicles[1],
        status: ListingStatus.active,
        views: 87,
        contacts: 4,
        publishedAt: now.subtract(const Duration(days: 1)),
        expiresAt: now.add(const Duration(days: 29)),
      ),
      MyListing(
        id: 'L-003',
        card: vehicles[4],
        status: ListingStatus.pending,
        views: 0,
        contacts: 0,
        publishedAt: now.subtract(const Duration(hours: 6)),
      ),
      MyListing(
        id: 'L-004',
        card: vehicles[6],
        status: ListingStatus.sold,
        views: 1240,
        contacts: 42,
        publishedAt: now.subtract(const Duration(days: 38)),
      ),
      MyListing(
        id: 'L-005',
        card: vehicles[5],
        status: ListingStatus.paused,
        views: 156,
        contacts: 9,
        publishedAt: now.subtract(const Duration(days: 12)),
        expiresAt: now.add(const Duration(days: 18)),
      ),
      MyListing(
        id: 'L-006',
        card: vehicles[7],
        status: ListingStatus.rejected,
        views: 0,
        contacts: 0,
        publishedAt: now.subtract(const Duration(days: 2)),
        rejectionReason:
            'VIN illisible sur les photos. Veuillez ajouter un cliché net du numéro de châssis.',
      ),
    ];
  }

  void changeStatus(String id, ListingStatus next) {
    state = [
      for (final l in state)
        if (l.id == id) _copyWithStatus(l, next) else l,
    ];
  }

  void delete(String id) {
    state = state.where((l) => l.id != id).toList();
  }

  MyListing _copyWithStatus(MyListing l, ListingStatus s) => MyListing(
        id: l.id,
        card: l.card,
        status: s,
        views: l.views,
        contacts: l.contacts,
        publishedAt: l.publishedAt,
        expiresAt: l.expiresAt,
        rejectionReason: l.rejectionReason,
      );
}

final myListingsProvider =
    StateNotifierProvider<MyListingsNotifier, List<MyListing>>((ref) {
  return MyListingsNotifier();
});

/// Compte d'annonces actives — utilisé par le badge du profil.
final activeListingsCountProvider = Provider<int>((ref) {
  return ref
      .watch(myListingsProvider)
      .where((l) => l.status == ListingStatus.active)
      .length;
});
