import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/notifications_inbox/data/notifications_repository.dart';
import 'package:liko_auto/features/notifications_inbox/domain/app_notification.dart';

export 'package:liko_auto/features/notifications_inbox/data/notifications_repository.dart'
    show NotificationsRepository;

final notificationsInboxProvider = StreamProvider<List<AppNotification>>((
  ref,
) async* {
  final repo = await ref.watch(notificationsRepositoryProvider.future);
  yield* repo.watchAll();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref
      .watch(notificationsInboxProvider)
      .maybeWhen(
        data: (list) => list.where((n) => !n.isRead).length,
        orElse: () => 0,
      );
});

/// Nullable: returns null while mock data is still loading.
final notificationsActionsProvider = Provider<NotificationsRepository?>((ref) {
  return ref.watch(notificationsRepositoryProvider).valueOrNull;
});
