import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/providers/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class _Keys {
  static const push = 'notif_push';
  static const messages = 'notif_messages';
  static const priceDrops = 'notif_price_drops';
  static const appointments = 'notif_appointments';
  static const system = 'notif_system';
  static const promos = 'notif_promos';
  static const emailDigest = 'notif_email_digest';
  static const quietOn = 'notif_quiet_on';
  static const quietStart = 'notif_quiet_start';
  static const quietEnd = 'notif_quiet_end';
}

class NotificationPrefsNotifier extends StateNotifier<NotificationPrefs> {
  NotificationPrefsNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static NotificationPrefs _load(SharedPreferences p) {
    return NotificationPrefs(
      pushEnabled: p.getBool(_Keys.push) ?? true,
      newMessages: p.getBool(_Keys.messages) ?? true,
      priceDrops: p.getBool(_Keys.priceDrops) ?? true,
      appointments: p.getBool(_Keys.appointments) ?? true,
      systemAlerts: p.getBool(_Keys.system) ?? true,
      promotions: p.getBool(_Keys.promos) ?? false,
      emailDigest: p.getBool(_Keys.emailDigest) ?? false,
      quietHoursEnabled: p.getBool(_Keys.quietOn) ?? false,
      quietStartHour: p.getInt(_Keys.quietStart) ?? 22,
      quietEndHour: p.getInt(_Keys.quietEnd) ?? 7,
    );
  }

  Future<void> _persist(NotificationPrefs next) async {
    state = next;
    await Future.wait<void>([
      _prefs.setBool(_Keys.push, next.pushEnabled),
      _prefs.setBool(_Keys.messages, next.newMessages),
      _prefs.setBool(_Keys.priceDrops, next.priceDrops),
      _prefs.setBool(_Keys.appointments, next.appointments),
      _prefs.setBool(_Keys.system, next.systemAlerts),
      _prefs.setBool(_Keys.promos, next.promotions),
      _prefs.setBool(_Keys.emailDigest, next.emailDigest),
      _prefs.setBool(_Keys.quietOn, next.quietHoursEnabled),
      _prefs.setInt(_Keys.quietStart, next.quietStartHour),
      _prefs.setInt(_Keys.quietEnd, next.quietEndHour),
    ]);
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
  return NotificationPrefsNotifier(ref.watch(sharedPreferencesProvider));
});
