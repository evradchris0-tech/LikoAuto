import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/providers/preferences_provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricRepository {
  const BiometricRepository(this._auth, this._prefs);

  final LocalAuthentication _auth;
  final SharedPreferences _prefs;

  static const _kEnabled = 'biometric_enabled';

  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } on Exception {
      return false;
    }
  }

  bool get isEnabled => _prefs.getBool(_kEnabled) ?? false;

  Future<void> setEnabled({required bool value}) =>
      _prefs.setBool(_kEnabled, value);

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Confirmez votre identité pour accéder à Liko Auto',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
    } on Exception {
      return false;
    }
  }
}

final _localAuthProvider = Provider<LocalAuthentication>(
  (_) => LocalAuthentication(),
);

final biometricRepositoryProvider = Provider<BiometricRepository>((ref) {
  return BiometricRepository(
    ref.watch(_localAuthProvider),
    ref.watch(sharedPreferencesProvider),
  );
});
