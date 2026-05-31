import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/reviews/data/reviews_repository.dart';
import 'package:liko_auto/features/reviews/domain/review.dart';

export 'package:liko_auto/features/reviews/data/reviews_repository.dart'
    show ReviewsRepository;

/// Stream live des reviews ciblées sur un objet précis.
final reviewsForTargetProvider =
    StreamProvider.family<List<Review>, ({ReviewTargetType type, String id})>((
      ref,
      target,
    ) {
      return ref
          .watch(reviewsRepositoryProvider)
          .watchForTarget(type: target.type, id: target.id);
    });

/// Actions sur les reviews (publish / delete).
final reviewsActionsProvider = Provider<ReviewsRepository>((ref) {
  return ref.watch(reviewsRepositoryProvider);
});
