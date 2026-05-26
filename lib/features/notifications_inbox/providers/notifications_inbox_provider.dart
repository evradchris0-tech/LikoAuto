import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/notifications_inbox/data/notifications_repository.dart';
import 'package:liko_auto/features/notifications_inbox/domain/app_notification.dart';

export 'package:liko_auto/features/notifications_inbox/data/notifications_repository.dart'
    show NotificationsRepository;

/// Stream live des notifications, ordre chrono inverse.
final notificationsInboxProvider = StreamProvider<List<AppNotification>>((ref) {
  return ref.watch(notificationsRepositoryProvider).watchAll();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsInboxProvider).maybeWhen(
        data: (list) => list.where((n) => !n.isRead).length,
        orElse: () => 0,
      );
});

/// Actions sur les notifications (markRead / markAllRead / delete / clearAll / push).
final notificationsActionsProvider = Provider<NotificationsRepository>((ref) {
  return ref.watch(notificationsRepositoryProvider);
});
