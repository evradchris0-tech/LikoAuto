import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/providers/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class _Keys {
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

/// Accès aux préférences de notification persistées dans SharedPreferences.
class NotificationPrefsRepository {
  const NotificationPrefsRepository(this._prefs);
  final SharedPreferences _prefs;

  bool get pushEnabled => _prefs.getBool(_Keys.push) ?? true;
  bool get newMessages => _prefs.getBool(_Keys.messages) ?? true;
  bool get priceDrops => _prefs.getBool(_Keys.priceDrops) ?? true;
  bool get appointments => _prefs.getBool(_Keys.appointments) ?? true;
  bool get systemAlerts => _prefs.getBool(_Keys.system) ?? true;
  bool get promotions => _prefs.getBool(_Keys.promos) ?? false;
  bool get emailDigest => _prefs.getBool(_Keys.emailDigest) ?? false;
  bool get quietHoursEnabled => _prefs.getBool(_Keys.quietOn) ?? false;
  int get quietStartHour => _prefs.getInt(_Keys.quietStart) ?? 22;
  int get quietEndHour => _prefs.getInt(_Keys.quietEnd) ?? 7;

  Future<void> setPushEnabled({required bool value}) =>
      _prefs.setBool(_Keys.push, value);
  Future<void> setNewMessages({required bool value}) =>
      _prefs.setBool(_Keys.messages, value);
  Future<void> setPriceDrops({required bool value}) =>
      _prefs.setBool(_Keys.priceDrops, value);
  Future<void> setAppointments({required bool value}) =>
      _prefs.setBool(_Keys.appointments, value);
  Future<void> setSystemAlerts({required bool value}) =>
      _prefs.setBool(_Keys.system, value);
  Future<void> setPromotions({required bool value}) =>
      _prefs.setBool(_Keys.promos, value);
  Future<void> setEmailDigest({required bool value}) =>
      _prefs.setBool(_Keys.emailDigest, value);
  Future<void> setQuietHoursEnabled({required bool value}) =>
      _prefs.setBool(_Keys.quietOn, value);
  Future<void> setQuietStartHour(int h) => _prefs.setInt(_Keys.quietStart, h);
  Future<void> setQuietEndHour(int h) => _prefs.setInt(_Keys.quietEnd, h);

  Future<void> persistAll({
    required bool pushEnabled,
    required bool newMessages,
    required bool priceDrops,
    required bool appointments,
    required bool systemAlerts,
    required bool promotions,
    required bool emailDigest,
    required bool quietHoursEnabled,
    required int quietStartHour,
    required int quietEndHour,
  }) async {
    await Future.wait<void>([
      _prefs.setBool(_Keys.push, pushEnabled),
      _prefs.setBool(_Keys.messages, newMessages),
      _prefs.setBool(_Keys.priceDrops, priceDrops),
      _prefs.setBool(_Keys.appointments, appointments),
      _prefs.setBool(_Keys.system, systemAlerts),
      _prefs.setBool(_Keys.promos, promotions),
      _prefs.setBool(_Keys.emailDigest, emailDigest),
      _prefs.setBool(_Keys.quietOn, quietHoursEnabled),
      _prefs.setInt(_Keys.quietStart, quietStartHour),
      _prefs.setInt(_Keys.quietEnd, quietEndHour),
    ]);
  }
}

final notificationPrefsRepositoryProvider =
    Provider<NotificationPrefsRepository>((ref) {
      return NotificationPrefsRepository(ref.watch(sharedPreferencesProvider));
    });
