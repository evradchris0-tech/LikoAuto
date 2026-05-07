import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Override dans `main.dart` après chargement asynchrone.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

const _kOnboardingSeenKey = 'onboarding_seen_v1';

class OnboardingSeenNotifier extends StateNotifier<bool> {
  OnboardingSeenNotifier(this._prefs)
      : super(_prefs.getBool(_kOnboardingSeenKey) ?? false);

  final SharedPreferences _prefs;

  Future<void> markSeen() async {
    await _prefs.setBool(_kOnboardingSeenKey, true);
    state = true;
  }

  Future<void> reset() async {
    await _prefs.remove(_kOnboardingSeenKey);
    state = false;
  }
}

final onboardingSeenProvider =
    StateNotifierProvider<OnboardingSeenNotifier, bool>((ref) {
  return OnboardingSeenNotifier(ref.watch(sharedPreferencesProvider));
});
