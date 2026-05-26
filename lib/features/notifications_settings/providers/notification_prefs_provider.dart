import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/features/notifications_settings/data/notification_prefs_repository.dart';

@immutable
class NotificationPrefs {
  const NotificationPrefs({
    this.pushEnabled = true,
    this.newMessages = true,
    this.priceDrops = true,
    this.appointments = true,
    this.systemAlerts = true,
    this.promotions = false,
    this.emailDigest = false,
    this.quietHoursEnabled = false,
    this.quietStartHour = 22,
    this.quietEndHour = 7,
  });

  final bool pushEnabled;
  final bool newMessages;
  final bool priceDrops;
  final bool appointments;
  final bool systemAlerts;
  final bool promotions;
  final bool emailDigest;
  final bool quietHoursEnabled;
  final int quietStartHour;
  final int quietEndHour;

  NotificationPrefs copyWith({
    bool? pushEnabled,
    bool? newMessages,
    bool? priceDrops,
    bool? appointments,
    bool? systemAlerts,
    bool? promotions,
    bool? emailDigest,
    bool? quietHoursEnabled,
    int? quietStartHour,
    int? quietEndHour,
  }) {
    return NotificationPrefs(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      newMessages: newMessages ?? this.newMessages,
      priceDrops: priceDrops ?? this.priceDrops,
      appointments: appointments ?? this.appointments,
      systemAlerts: systemAlerts ?? this.systemAlerts,
      promotions: promotions ?? this.promotions,
      emailDigest: emailDigest ?? this.emailDigest,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietStartHour: quietStartHour ?? this.quietStartHour,
      quietEndHour: quietEndHour ?? this.quietEndHour,
    );
  }
}

class NotificationPrefsNotifier extends StateNotifier<NotificationPrefs> {
  NotificationPrefsNotifier(this._repo) : super(_loadFromRepo(_repo));

  final NotificationPrefsRepository _repo;

  static NotificationPrefs _loadFromRepo(NotificationPrefsRepository r) {
    return NotificationPrefs(
      pushEnabled: r.pushEnabled,
      newMessages: r.newMessages,
      priceDrops: r.priceDrops,
      appointments: r.appointments,
      systemAlerts: r.systemAlerts,
      promotions: r.promotions,
      emailDigest: r.emailDigest,
      quietHoursEnabled: r.quietHoursEnabled,
      quietStartHour: r.quietStartHour,
      quietEndHour: r.quietEndHour,
    );
  }

  Future<void> _persist(NotificationPrefs next) async {
    state = next;
    await _repo.persistAll(
      pushEnabled: next.pushEnabled,
      newMessages: next.newMessages,
      priceDrops: next.priceDrops,
      appointments: next.appointments,
      systemAlerts: next.systemAlerts,
      promotions: next.promotions,
      emailDigest: next.emailDigest,
      quietHoursEnabled: next.quietHoursEnabled,
      quietStartHour: next.quietStartHour,
      quietEndHour: next.quietEndHour,
    );
  }

  Future<void> setPushEnabled({required bool value}) async =>
      _persist(state.copyWith(pushEnabled: value));
  Future<void> setNewMessages({required bool value}) async =>
      _persist(state.copyWith(newMessages: value));
  Future<void> setPriceDrops({required bool value}) async =>
      _persist(state.copyWith(priceDrops: value));
  Future<void> setAppointments({required bool value}) async =>
      _persist(state.copyWith(appointments: value));
  Future<void> setSystemAlerts({required bool value}) async =>
      _persist(state.copyWith(systemAlerts: value));
  Future<void> setPromotions({required bool value}) async =>
      _persist(state.copyWith(promotions: value));
  Future<void> setEmailDigest({required bool value}) async =>
      _persist(state.copyWith(emailDigest: value));
  Future<void> setQuietHoursEnabled({required bool value}) async =>
      _persist(state.copyWith(quietHoursEnabled: value));
  Future<void> setQuietStart(int hour) async =>
      _persist(state.copyWith(quietStartHour: hour));
  Future<void> setQuietEnd(int hour) async =>
      _persist(state.copyWith(quietEndHour: hour));
}

final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>((ref) {
  return NotificationPrefsNotifier(
    ref.watch(notificationPrefsRepositoryProvider),
  );
});
