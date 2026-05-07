import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';

/// Calcule une clé stable pour une annonce (en attendant l'id côté API).
String favoriteKey(ListingCardData data) =>
    '${data.title}__${data.priceFcfa}';

class FavoritesNotifier extends StateNotifier<List<ListingCardData>> {
  FavoritesNotifier() : super(const []);

  bool isFavorite(ListingCardData data) {
    final key = favoriteKey(data);
    return state.any((f) => favoriteKey(f) == key);
  }

  /// Ajoute ou retire selon l'état courant. Retourne `true` si ajouté.
  bool toggle(ListingCardData data) {
    final key = favoriteKey(data);
    final exists = state.any((f) => favoriteKey(f) == key);
    if (exists) {
      state = state.where((f) => favoriteKey(f) != key).toList();
      return false;
    }
    state = [data, ...state];
    return true;
  }

  void remove(ListingCardData data) {
    final key = favoriteKey(data);
    state = state.where((f) => favoriteKey(f) != key).toList();
  }

  void clearAll() => state = const [];
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<ListingCardData>>((ref) {
  return FavoritesNotifier();
});

/// Indique si une annonce précise est dans les favoris (utilisé par
/// `ListingCard` pour piloter l'icône cœur).
final isFavoriteProvider = Provider.family<bool, ListingCardData>((ref, data) {
  final key = favoriteKey(data);
  return ref
      .watch(favoritesProvider)
      .any((f) => favoriteKey(f) == key);
});

/// Compte total de favoris — utilisé par le badge du profil.
final favoritesCountProvider =
    Provider<int>((ref) => ref.watch(favoritesProvider).length);
