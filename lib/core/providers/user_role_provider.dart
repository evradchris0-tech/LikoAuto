import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/providers/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { buyer, seller, garage }

const _kRoleKey = 'user_role_v1';

class UserRoleNotifier extends StateNotifier<UserRole> {
  UserRoleNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static UserRole _load(SharedPreferences prefs) {
    final raw = prefs.getString(_kRoleKey) ?? '';
    return switch (raw) {
      'seller' => UserRole.seller,
      'garage' => UserRole.garage,
      _ => UserRole.buyer,
    };
  }

  UserRole get role => state;

  set role(UserRole value) {
    _prefs.setString(_kRoleKey, value.name);
    state = value;
  }
}

final userRoleProvider = StateNotifierProvider<UserRoleNotifier, UserRole>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserRoleNotifier(prefs);
});
