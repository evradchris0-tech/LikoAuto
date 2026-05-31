import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/my_listings/data/my_listings_repository.dart';
import 'package:liko_auto/features/my_listings/domain/my_listing.dart';

export 'package:liko_auto/features/my_listings/data/my_listings_repository.dart'
    show MyListingsRepository;

/// Stream live des annonces personnelles, trié par date décroissante.
final myListingsProvider = StreamProvider<List<MyListing>>((ref) {
  return ref.watch(myListingsRepositoryProvider).watchAll();
});

/// Compte d'annonces actives — utilisé par le badge du profil.
final activeListingsCountProvider = Provider<int>((ref) {
  return ref
      .watch(myListingsProvider)
      .maybeWhen(
        data: (list) =>
            list.where((l) => l.status == ListingStatus.active).length,
        orElse: () => 0,
      );
});

/// Actions sur les annonces personnelles (changeStatus / delete / insert).
final myListingsActionsProvider = Provider<MyListingsRepository>((ref) {
  return ref.watch(myListingsRepositoryProvider);
});
