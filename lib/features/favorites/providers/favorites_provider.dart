import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/favorites/data/favorites_repository.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';

export 'package:liko_auto/features/favorites/data/favorites_repository.dart'
    show FavoritesRepository, favoriteKey;

/// Stream live des favoris, triés par date d'ajout descendante.
final favoritesProvider = StreamProvider<List<ListingCardData>>((ref) {
  return ref.watch(favoritesRepositoryProvider).watchAll();
});

/// Vrai si l'annonce donnée est dans les favoris.
final isFavoriteProvider = StreamProvider.family<bool, ListingCardData>((
  ref,
  data,
) {
  return ref.watch(favoritesRepositoryProvider).watchIsFavorite(data);
});

/// Compteur live de favoris — utilisé par le badge profile.
final favoritesCountProvider = Provider<int>((ref) {
  return ref
      .watch(favoritesProvider)
      .maybeWhen(data: (list) => list.length, orElse: () => 0);
});

/// Actions sur les favoris (toggle / remove / clear).
final favoritesActionsProvider = Provider<FavoritesRepository>((ref) {
  return ref.watch(favoritesRepositoryProvider);
});
