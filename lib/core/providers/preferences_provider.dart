import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Override dans `main.dart` après chargement asynchrone.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  );
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

// ── Mock auth ──────────────────────────────────────────────────────────────
// Bypass temporaire de l'auth Firebase en attendant le backend NestJS.
// Quand `mockSignedIn` est `true`, le router considère l'utilisateur connecté
// même sans session Firebase. À supprimer dès que l'API est branchée.
const _kMockSignedInKey = 'mock_signed_in';

class MockSignedInNotifier extends StateNotifier<bool> {
  MockSignedInNotifier(this._prefs)
    : super(_prefs.getBool(_kMockSignedInKey) ?? false);

  final SharedPreferences _prefs;

  Future<void> signIn() async {
    await _prefs.setBool(_kMockSignedInKey, true);
    state = true;
  }

  Future<void> signOut() async {
    await _prefs.remove(_kMockSignedInKey);
    state = false;
  }
}

final mockSignedInProvider = StateNotifierProvider<MockSignedInNotifier, bool>((
  ref,
) {
  return MockSignedInNotifier(ref.watch(sharedPreferencesProvider));
});
