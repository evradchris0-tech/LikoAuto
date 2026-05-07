import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/favorites/providers/favorites_provider.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';

@immutable
class ViewedListing {
  const ViewedListing({required this.data, required this.viewedAt});

  final ListingCardData data;
  final DateTime viewedAt;
}

const _kMaxHistoryEntries = 50;

class ViewHistoryNotifier extends StateNotifier<List<ViewedListing>> {
  ViewHistoryNotifier() : super(const []);

  /// Enregistre une consultation. Si l'annonce est déjà connue, sa position
  /// est remontée et `viewedAt` mis à jour.
  void record(ListingCardData data) {
    final key = favoriteKey(data);
    final without =
        state.where((v) => favoriteKey(v.data) != key).toList(growable: true);
    final next = <ViewedListing>[
      ViewedListing(data: data, viewedAt: DateTime.now()),
      ...without,
    ];
    if (next.length > _kMaxHistoryEntries) {
      next.removeRange(_kMaxHistoryEntries, next.length);
    }
    state = next;
  }

  void remove(ListingCardData data) {
    final key = favoriteKey(data);
    state =
        state.where((v) => favoriteKey(v.data) != key).toList(growable: false);
  }

  void clearAll() => state = const [];
}

final viewHistoryProvider =
    StateNotifierProvider<ViewHistoryNotifier, List<ViewedListing>>((ref) {
  return ViewHistoryNotifier();
});

final viewHistoryCountProvider =
    Provider<int>((ref) => ref.watch(viewHistoryProvider).length);
