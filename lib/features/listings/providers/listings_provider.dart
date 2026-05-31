import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/listings/data/listings_repository.dart';
import 'package:liko_auto/features/listings/domain/api_listing.dart';

/// Filtres actifs pour la recherche / home.
final listingFiltersProvider = StateProvider<ListingFilters>(
  (_) => const ListingFilters(status: ListingStatus.published),
);

/// Liste des annonces publiées (utilisée par HomeScreen + SearchScreen).
final listingsProvider =
    FutureProvider.family<List<ApiListing>, ListingFilters>(
      (ref, filters) =>
          ref.watch(listingsRepositoryProvider).getListings(filters),
    );

/// Annonces publiées par défaut — raccourci pour HomeScreen.
final publishedListingsProvider = FutureProvider<List<ApiListing>>((ref) {
  return ref
      .watch(listingsRepositoryProvider)
      .getListings(const ListingFilters(status: ListingStatus.published));
});

/// Détail d'une annonce par ID.
final listingDetailProvider = FutureProvider.family<ApiListing, int>(
  (ref, id) => ref.watch(listingsRepositoryProvider).getListing(id),
);
