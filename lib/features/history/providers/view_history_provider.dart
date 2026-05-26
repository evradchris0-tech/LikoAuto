import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/history/data/view_history_repository.dart';

export 'package:liko_auto/features/history/data/view_history_repository.dart'
    show ViewHistoryRepository, ViewedListing;

/// Stream live de l'historique des consultations, ordre chronologique inverse.
final viewHistoryProvider = StreamProvider<List<ViewedListing>>((ref) {
  return ref.watch(viewHistoryRepositoryProvider).watchAll();
});

final viewHistoryCountProvider = Provider<int>((ref) {
  return ref.watch(viewHistoryProvider).maybeWhen(
        data: (list) => list.length,
        orElse: () => 0,
      );
});

/// Actions sur l'historique (record / remove / clearAll).
final viewHistoryActionsProvider = Provider<ViewHistoryRepository>((ref) {
  return ref.watch(viewHistoryRepositoryProvider);
});
